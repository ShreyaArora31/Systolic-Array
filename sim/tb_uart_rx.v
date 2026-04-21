`timescale 1ns/1ps
module tb_uart_rx;

    reg clk, reset;
    reg rx;
    wire [7:0] data_out;
    wire data_valid;

    uart_rx #(.BAUD_TICK(11082)) UUT (
        .clk(clk), .reset(reset),
        .rx(rx),
        .data_out(data_out), .data_valid(data_valid)
    );

    always #4.7 clk = ~clk;

    task send_byte(input [7:0] b);
        integer i;
        begin
            rx = 0; #(104000); // start bit (at 9600 baud)
            for (i = 0; i < 8; i++) begin
                rx = b[i];
                #(104000);
            end
            rx = 1; #(104000); // stop bit
        end
    endtask

    initial begin
        $dumpfile("tb_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        clk = 0; reset = 1; rx = 1;
        #20 reset = 0;

        send_byte(8'h55);
        #20000;

        send_byte(8'hA3);
        #20000;

        $finish;
    end

endmodule
