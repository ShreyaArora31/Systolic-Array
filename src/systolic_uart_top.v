`timescale 1ns/1ps
module systolic_uart_top (
    input  wire clk,
    input  wire reset,
    input  wire rx,
    output wire tx
);

wire [7:0] rx_data;
wire       rx_valid;

uart_rx #(.BAUD_TICK(11082)) U_RX (
    .clk(clk),
    .reset(reset),
    .rx(rx),
    .data_out(rx_data),
    .data_valid(rx_valid)
);

reg [127:0] A_flat, B_flat;
reg [5:0]   rx_count;
reg         matrices_ready;

wire [255:0] C_flat;
reg          start_calc;
wire         calc_done;

systolic_array_4x4 U_MAT (
    .clk(clk),
    .reset(reset),
    .start(start_calc),
    .A_flat(A_flat),
    .B_flat(B_flat),
    .C_flat(C_flat),
    .done(calc_done)
);

reg  [7:0] tx_data;
reg        tx_start;
wire       tx_busy;

uart_tx #(.BAUD_TICK(11082)) U_TX (
    .clk(clk),
    .reset(reset),
    .data_in(tx_data),
    .start(tx_start),
    .tx(tx),
    .busy(tx_busy)
);

reg sending;
reg [5:0] tx_index;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        rx_count       <= 0;
        matrices_ready <= 0;
        A_flat         <= 0;
        B_flat         <= 0;
        sending        <= 0;
        tx_index       <= 0;
        tx_start       <= 0;
        tx_data	       <= 0;
        start_calc     <= 0;
    end else begin
        tx_start   <= 0;
        start_calc <= 0;

        // -------------------- RECEIVE 32 BYTES --------------------
        if (rx_valid && !matrices_ready) begin
            if (rx_count < 16)
                A_flat[rx_count*8 +: 8] <= rx_data;
            else if (rx_count < 32)
                B_flat[(rx_count-16)*8 +: 8] <= rx_data;

            rx_count <= rx_count + 1;

            if (rx_count == 31) begin
                matrices_ready <= 1;
                rx_count       <= 0;
            end
        end

        // ------------------ START CALCULATION ---------------------
        if (matrices_ready && !sending) begin
            start_calc <= 1;

            if (calc_done) begin
                sending        <= 1;
                matrices_ready <= 0;
                tx_index       <= 0;
            end
        end

        // ------------------ UART TRANSMISSION ---------------------
        if (sending) begin
            if (!tx_busy && tx_index < 32) begin
                tx_data  <= C_flat[tx_index*8 +: 8];
                tx_start <= 1;
                tx_index <= tx_index + 1;

                if (tx_index == 31)
                    sending <= 0;
            end
        end
    end
end

endmodule
