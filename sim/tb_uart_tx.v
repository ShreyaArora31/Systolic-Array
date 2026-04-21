`timescale 1ns/1ps
module tb_uart_tx;

    reg clk, reset, start;
    reg [7:0] data_in;
    wire tx, busy;

    uart_tx #(.BAUD_TICK(11082)) UUT (
        .clk(clk), .reset(reset),
        .data_in(data_in),
        .start(start),
        .tx(tx),
        .busy(busy)
    );

    always #4.7 clk = ~clk;

    initial begin
        $dumpfile("tb_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        clk = 0; reset = 1; start = 0; data_in = 8'h41;  // ASCII 'A'
        #20 reset = 0;

        #10 start = 1;
        #10 start = 0;

        #30000 $finish;
    end
endmodule
