module spi_master(
    input wire clk, reset, tx_enable,
    input wire miso,
    output reg mosi, sclk, chip_select,
    output reg [7:0] master_rx_data
);
    parameter idle=0, tx_start=1, tx_data=2, tx_end=3;
    reg [1:0] state;
    reg [2:0] count;
    reg [3:0] bit_count;
    reg [7:0] send_data = 8'd181; 
    reg [7:0] rx_buffer;

    always @(posedge clk) begin
        if (reset) begin
            state <= idle; mosi <= 0; sclk <= 0; chip_select <= 1;
            count <= 0; bit_count <= 0; rx_buffer <= 0; master_rx_data <= 0;
        end else begin
            case (state)
                idle: begin
                    chip_select <= 1; sclk <= 0; count <= 0; bit_count <= 0;
                    if (tx_enable) state <= tx_start;
                end
                tx_start: begin
                    chip_select <= 0;
                    mosi <= send_data[7]; // MSB setup
                    if (count == 7) begin state <= tx_data; count <= 0; end
                    else count <= count + 1;
                end
                tx_data: begin
                    // SCLK Toggle
                    if (count == 3) sclk <= 1;
                    else if (count == 7) sclk <= 0;

                    // MISO Sampling (Sample when SCLK is high)
                    if (count == 5) rx_buffer <= {rx_buffer[6:0], miso};

                    // MOSI Shifting (Change when SCLK is low)
                    if (count == 7) begin
                        count <= 0;
                        if (bit_count == 7) state <= tx_end;
                        else begin
                            bit_count <= bit_count + 1;
                            mosi <= send_data[6 - bit_count]; 
                        end
                    end else count <= count + 1;
                end
                tx_end: begin
                    master_rx_data <= rx_buffer;
                    if (count == 7) state <= idle;
                    else count <= count + 1;
                end
            endcase
        end
    end
endmodule