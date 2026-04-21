`timescale 1ns/1ps
module tb_pe;

    reg clk, reset;
    reg [7:0] a_in, b_in;
    reg [15:0] acc_in;
    wire [7:0] a_out, b_out;
    wire [15:0] acc_out;

    // Instantiate PE
    pe UUT (
        .clk(clk),
        .reset(reset),
        .a_in(a_in),
        .b_in(b_in),
        .acc_in(acc_in),
        .a_out(a_out),
        .b_out(b_out),
        .acc_out(acc_out)
    );

    // 9.4 ns period → 106.4 MHz clock
    always #4.7 clk = ~clk;

    // Memory for hex file input
    reg [7:0] A_mem [0:15];
    reg [7:0] B_mem [0:15];

    integer i;

    initial begin
        $dumpfile("tb_pe.vcd");
        $dumpvars(0, tb_pe);

        clk = 0;
        reset = 1;
        a_in = 0;
        b_in = 0;
        acc_in = 0;

        // Read hex files
        $readmemh("A.hex", A_mem);
        $readmemh("B.hex", B_mem);

        #20 reset = 0;

        // Apply 16 input pairs (one per cycle)
        for (i = 0; i < 16; i = i + 1) begin
            a_in = A_mem[i];
            b_in = B_mem[i];
            acc_in = acc_out;    // accumulate over time
            #10;                 // wait 1 cycle
        end

        #50 $finish;
    end

endmodule
