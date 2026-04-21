`timescale 1ns/1ps
module pe (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  a_in,
    input  wire [7:0]  b_in,
    input  wire [15:0] acc_in,
    output reg  [7:0]  a_out,
    output reg  [7:0]  b_out,
    output reg  [15:0] acc_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        a_out  <= 0;
        b_out  <= 0;
        acc_out <= 0;
    end else begin
        a_out  <= a_in;
        b_out  <= b_in;
        acc_out <= acc_in + (a_in * b_in);
    end
end
    
endmodule
