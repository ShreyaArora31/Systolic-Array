`timescale 1ns/1ps
module systolic_array_4x4 (
    input  wire clk,
    input  wire reset,
    input  wire start,          // NEW: Trigger to start calculation
    input  wire [127:0] A_flat,
    input  wire [127:0] B_flat,
    output wire [255:0] C_flat,
    output wire done            // Optional: Indicates calc is finished
);

    // 1. Unpack Flat Inputs into 2D Arrays for easy indexing
    wire [7:0] A_matrix [0:3][0:3];
    wire [7:0] B_matrix [0:3][0:3];

    genvar i, j;
    generate
        for (i = 0; i < 4; i = i + 1) begin
            for (j = 0; j < 4; j = j + 1) begin
                // Map flat to 4x4. 
                // Assumes Row-Major input: A[0,0], A[0,1]...
                assign A_matrix[i][j] = A_flat[(i*4 + j)*8 +: 8];
                assign B_matrix[i][j] = B_flat[(i*4 + j)*8 +: 8];
            end
        end
    endgenerate

    // 2. Global Counter for Data Feeding
    reg [4:0] count;
    reg running;
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 0;
            running <= 0;
        end else begin
            if (start) running <= 1;
            
            // Run for enough cycles to flush data through (4x4 array needs ~10-12 cycles)
            if (running && count < 20) 
                count <= count + 1;
            else if (!running)
                count <= 0;
        end
    end

    assign done = (count == 20);

    // 3. Skew Logic: Select inputs based on time and row/col index
    // A flows from Left (feeds rows), B flows from Top (feeds cols)
    wire [7:0] a_feed [0:3];
    wire [7:0] b_feed [0:3];

    genvar r, c;
    generate
        for (r = 0; r < 4; r = r + 1) begin : ROW_FEED
            // Row r needs data starting at T = r
            // Index to fetch = current_time - row_index
            wire [4:0] idx = count - r;
            
            // Check if idx is valid (0 to 3)
            assign a_feed[r] = (running && count >= r && idx < 4) ? A_matrix[r][idx[1:0]] : 8'd0;
        end

        for (c = 0; c < 4; c = c + 1) begin : COL_FEED
            // Col c needs data starting at T = c
            wire [4:0] idx = count - c;
            
            assign b_feed[c] = (running && count >= c && idx < 4) ? B_matrix[idx[1:0]][c] : 8'd0;
        end
    endgenerate

    // 4. Instantiate PEs
    wire [7:0]  a_w [0:15];
    wire [7:0]  b_w [0:15];
    wire [15:0] acc_w [0:15];

    generate
        for (r = 0; r < 4; r = r + 1) begin : ROWS
            for (c = 0; c < 4; c = c + 1) begin : COLS
                localparam IDX = r*4 + c;

                // Connect Inputs:
                // If Column 0, take from Skew Feeder. Else take from neighbor to left.
                wire [7:0] pe_a_in = (c == 0) ? a_feed[r] : a_w[IDX-1];
                
                // If Row 0, take from Skew Feeder. Else take from neighbor above.
                wire [7:0] pe_b_in = (r == 0) ? b_feed[c] : b_w[IDX-4];

                // Accumulator Feedback:
                // Connect output back to input to accumulate in place.
                // Reset will clear it.
                wire [15:0] pe_acc_in = acc_w[IDX]; 

                pe U_PE (
                    .clk(clk),
                    .reset(reset),
                    .a_in(pe_a_in),
                    .b_in(pe_b_in),
                    .acc_in(pe_acc_in),
                    .a_out(a_w[IDX]),
                    .b_out(b_w[IDX]),
                    .acc_out(acc_w[IDX])
                );
                
                assign C_flat[IDX*16 +: 16] = acc_w[IDX];
            end
        end
    endgenerate

endmodule
