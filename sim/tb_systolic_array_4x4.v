`timescale 1ns/1ps
module tb_systolic_array_4x4;

    reg clk, reset, start;
    reg [7:0] A_mem [0:15];
    reg [7:0] B_mem [0:15];

    reg [127:0] A_flat, B_flat;
    wire [255:0] C_flat;
    wire done;

    systolic_array_4x4 DUT (
        .clk(clk),
        .reset(reset),
        .start(start),
        .A_flat(A_flat),
        .B_flat(B_flat),
        .C_flat(C_flat),
        .done(done)
    );reg [7:0] A2D [0:3][0:3];
reg [7:0] B2D [0:3][0:3];

integer r, c;

always @(*) begin
    for (r = 0; r < 4; r = r + 1) begin
        for (c = 0; c < 4; c = c + 1) begin
            A2D[r][c] = A_flat[(r*4 + c)*8 +: 8];
            B2D[r][c] = B_flat[(r*4 + c)*8 +: 8];
        end
    end
end

    
    

    always #4.7 clk = ~clk;

    integer i;

    initial begin
        $dumpfile("tb_array.vcd");
        $dumpvars(0, tb_systolic_array_4x4);

        clk = 0;
        reset = 1;
        start = 0;

        $readmemh("A.hex", A_mem);
        $readmemh("B.hex", B_mem);

        // FIX: Use i*8 instead of (15-i)*8 to match RTL unpacking
        for (i=0; i<16; i=i+1) begin
            A_flat[i*8 +: 8] = A_mem[i];
            B_flat[i*8 +: 8] = B_mem[i];
        end

        #20 reset = 0;
        
        // Trigger the systolic calculation
        #20 start = 1;
        #10 start = 0; // Pulse is enough, or keep high, logic handles it

        #500; // Wait for calculation

        $display("A_flat = %h", A_flat);
        $display("B_flat = %h", B_flat);
        
        $display("\nMatrix A (Normal Order):");
for (r = 0; r < 4; r = r + 1) begin
    $display("%3d  %3d  %3d  %3d",
        A2D[r][0], A2D[r][1], A2D[r][2], A2D[r][3]);
end

$display("\nMatrix B (Normal Order):");
for (r = 0; r < 4; r = r + 1) begin
    $display("%3d  %3d  %3d  %3d",
        B2D[r][0], B2D[r][1], B2D[r][2], B2D[r][3]);
end

        
        // Print Matrix C in 4x4 format for easier reading
        $display("\nMatrix C Result:");
        for(i=0; i<4; i=i+1) begin
             $display("%d %d %d %d", 
                C_flat[(i*4+0)*16 +: 16],
                C_flat[(i*4+1)*16 +: 16],
                C_flat[(i*4+2)*16 +: 16],
                C_flat[(i*4+3)*16 +: 16]
             );
        end

        $finish;
    end
endmodule
