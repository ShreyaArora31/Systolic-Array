`timescale 1ns/1ps
module uart_tx #(
    parameter BAUD_TICK = 11082
)(
    input  wire clk,
    input  wire reset,
    input  wire [7:0] data_in,
    input  wire start,
    output reg  tx,
    output reg  busy
);

reg [31:0] baud_cnt;
reg [3:0]  bit_cnt;
reg [9:0]  shift_reg;

always @(posedge clk or posedge reset) begin
    if (reset) begin
        tx <= 1;
        busy <= 0;
        baud_cnt <= 0;
        bit_cnt <= 0;
        shift_reg <= 10'b1111111111;
    end else begin
        if (!busy) begin
            if (start) begin
                shift_reg <= {1'b1, data_in, 1'b0};
                busy <= 1;
                baud_cnt <= BAUD_TICK - 1;
                bit_cnt <= 0;
                tx <= 0;
            end
        end else begin
            if (baud_cnt == 0) begin
                baud_cnt <= BAUD_TICK - 1;
                tx <= shift_reg[0];
                shift_reg <= {1'b1, shift_reg[9:1]};
                bit_cnt <= bit_cnt + 1;

                if (bit_cnt == 9) begin
                    busy <= 0;
                end
            end else begin
                baud_cnt <= baud_cnt - 1;
            end
        end
    end
end

endmodule
