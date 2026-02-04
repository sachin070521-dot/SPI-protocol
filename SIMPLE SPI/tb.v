`timescale 1ns / 1ps
module tb;

    reg clk = 0;
    reg rst = 0;
    reg tx_enable = 0;
    wire [7:0] dout;
    wire done;

    // Clock generation (100 MHz → period = 10ns)
    always #5 clk = ~clk;

    // Reset
    initial begin
        rst = 1;
        #50;
        rst = 0;
    end

    // Transmission trigger
    initial begin
        tx_enable = 0;
        #100;
        tx_enable = 1;
        #1000;
        $finish;
    end

    // DUT Instantiation
    top dut (
        .clk(clk),
        .rst(rst),
        .tx_enable(tx_enable),
        .dout(dout),
        .done(done)
    );

endmodule

