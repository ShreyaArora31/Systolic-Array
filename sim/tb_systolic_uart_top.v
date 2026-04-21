`timescale 1ns/1ps
module tb_systolic_uart_top;
reg clk;
reg reset;
reg rx;
wire tx;

parameter CLK_PERIOD = 9.4;
integer BIT_TIME = 11082 * CLK_PERIOD; // Actual bit time in ns

	task send_uart_byte(input [7:0] b);
	integer j;
	begin
	rx = 0;
	#(BIT_TIME);
	
	for (j = 0; j < 8; j = j + 1) begin
	rx = b[j];
	#(BIT_TIME);
	end
	
	rx = 1;
	#(BIT_TIME);
	end
	endtask
	
	reg [7:0] A [0:15];
	reg [7:0] B [0:15];
	
	systolic_uart_top DUT (
	.clk(clk), .reset(reset), .rx(rx), .tx(tx)
	);
	
	always #(CLK_PERIOD/2.0) clk = ~clk;
	
	integer k, i;
	initial begin
	
	$dumpfile("tb_top.vcd");
	$dumpvars(0, tb_systolic_uart_top);
	
	clk = 0;
	reset = 1;
	rx = 1;
	
	#100 reset = 0;
	
	for (i = 0; i< 16; i++) begin
	A[i] = (i == 0 || i == 5 || i == 10 || i == 15) ? 1 : 1;
	B[i] = (i == 0) ? 2 : (i == 5) ? 3 : (i == 10) ? 4 : (i == 15) ? 5 : 0;
	end
	
	for (k = 15; k >= 0; k = k-1) begin
	send_uart_byte(A[k]);
	#(BIT_TIME);
	end
	
	for( i = 15; i>=0;i = i-1) begin
	send_uart_byte(B[i]);
	#(BIT_TIME);
	end
	
	#5_000_000;
	$finish;
	end
	endmodule
