`timescale 1ns / 1ps

module tb_spi();

    // Inputs to Top Module
    reg clk;
    reg reset;
    reg tx_enable;
    
    // Outputs from Top Module
    wire [7:0] slave_received_data;
    wire [7:0] master_received_data;
    wire slave_done;
    wire sclk, mosi, miso, chip_select;

    // Instantiate the Top Module
    top_module uut (
        .clk(clk),
        .reset(reset),
        .tx_enable(tx_enable),
        .slave_received_data(slave_received_data),
        .master_received_data(master_received_data),
        .slave_done(slave_done),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .chip_select(chip_select)
    );

    // Clock Generation: 100MHz (10ns period)
    always #5 clk = ~clk;

    initial begin
        // --- Initialize ---
        clk = 0;
        reset = 1;
        tx_enable = 0;

        // --- Apply Reset ---
        #50 reset = 0;
        $display("Time: %0t | Reset released. System ready.", $time);
        
        // --- Trigger SPI Transfer ---
        #20 tx_enable = 1;
        #10 tx_enable = 0;
        $display("Time: %0t | Transmission Triggered.", $time);

        // --- Wait for Completion ---
        wait(slave_done == 1);
        
        // Stabilize signals
        #100;

        // --- Result Verification ---
        $display("\n================================================");
        $display("FINAL REPORT:");
        $display("Master to Slave (Target 181): %d", slave_received_data);
        $display("Slave to Master (Target 200): %d", master_received_data);
        
        if (slave_received_data == 181 && master_received_data == 200)
            $display("STATUS: SUCCESS! All data matched.");
        else
            $display("STATUS: FAILURE! Check timing or wiring.");
        $display("================================================\n");

        #100 $finish;
    end

    // Monitor internal bits (Optional for debugging)
    initial begin
        $monitor("Bit Transfer: MOSI=%b, MISO=%b, SCLK=%b", mosi, miso, sclk);
    end

endmodule