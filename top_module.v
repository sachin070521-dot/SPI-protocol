module top_module(
    input wire clk,           // System Clock (100MHz)
    input wire reset,         // Global Reset
    input wire tx_enable,     // Start transmission trigger
    output wire [7:0] slave_received_data, // Slave ke paas aaya hua data (Target: 181)
    output wire [7:0] master_received_data, // Master ke paas aaya hua data (Target: 200)
    output wire slave_done,   // Signal jab 8-bit transfer pura ho jaye
    output wire sclk,         // SPI Clock wire
    output wire mosi,         // Master Out Slave In wire
    output wire miso,         // Master In Slave Out wire
    output wire chip_select    // Slave Select wire
);

    // Master Instance: Yeh SCLK aur MOSI generate karta hai
    spi_master master_inst (
        .clk(clk),
        .reset(reset),
        .tx_enable(tx_enable),
        .miso(miso),                  // Slave se input le raha hai
        .mosi(mosi),                  // Slave ko data bhej raha hai
        .sclk(sclk),
        .chip_select(chip_select),
        .master_rx_data(master_received_data)
    );

    // Slave Instance: Yeh Master ki clock par respond karta hai
    spi_slave slave_inst (
        .sclk(sclk),
        .mosi(mosi),                  // Master se input le raha hai
        .chip_select(chip_select),
        .miso(miso),                  // Master ko data bhej raha hai
        .data_received(slave_received_data),
        .done(slave_done)
    );

endmodule