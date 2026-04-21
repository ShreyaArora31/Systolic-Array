`timescale 1ns/1ps
module uart_rx #(
    parameter BAUD_TICK = 11082   // set based on your clock
)(
    input  wire clk,
    input  wire reset,
    input  wire rx,
    output reg  [7:0] data_out,
    output reg        data_valid
);

reg [31:0] baud_cnt;
reg [3:0]  bit_cnt;
reg [7:0]  shift_reg;
reg        receiving;
reg rx_d1, rx_d2;

always @(posedge clk) begin
    rx_d1 <= rx;
    rx_d2 <= rx_d1;
end

always @(posedge clk or posedge reset) begin
    if (reset) begin
        baud_cnt   <= 0;
        bit_cnt    <= 0;
        shift_reg  <= 0;
        receiving  <= 0;
        data_out   <= 0;
        data_valid <= 0;
    end else begin
        data_valid <= 0;

        if (!receiving) begin
            if (rx_d2 == 0) begin
                receiving <= 1;
                baud_cnt  <= BAUD_TICK >> 1;
                bit_cnt   <= 0;
            end
        end else begin
            if (baud_cnt == 0) begin
                baud_cnt <= BAUD_TICK - 1;

                if (bit_cnt < 8) begin
                    shift_reg <= {rx_d2, shift_reg[7:1]};
                    bit_cnt <= bit_cnt + 1;
                end else begin
                    receiving <= 0;
                    data_out <= shift_reg;
                    data_valid <= 1;
                end
            end else begin
                baud_cnt <= baud_cnt - 1;
            end
        end
    end
end

endmodule
