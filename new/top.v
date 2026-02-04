module top (
    input  wire clk,
    input  wire rst,
    input  wire tx_enable,
    output wire [7:0] dout,
    output wire done
);

    // Internal SPI signals
    wire mosi;
    wire ss;     // Chip Select
    wire sclk;

    // SPI Master Instance
    fsm_spi spi_m (
        .clk(clk),
        .rst(rst),
        .tx_enable(tx_enable),
        .mosi(mosi),
        .cs(ss),
        .sclk(sclk)
    );

    // SPI Slave Instance
    spi_slave spi_s (
        .sclk(sclk),
        .mosi(mosi),
        .cs(ss),
        .dout(dout),
        .done(done)
    );

endmodule
