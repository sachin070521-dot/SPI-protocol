module spi_slave(
    input wire sclk, mosi, chip_select,
    output reg miso,
    output reg [7:0] data_received,
    output reg done
);
    reg [7:0] shift_reg;
    reg [3:0] bit_count;
    reg [7:0] slave_tx_data = 8'd200;

    // Data Receiving on Rising Edge
    always @(posedge sclk or posedge chip_select) begin
        if (chip_select) begin
            bit_count <= 0; shift_reg <= 0; done <= 0;
        end else begin
            if (bit_count < 8) begin
                shift_reg <= {shift_reg[6:0], mosi};
                bit_count <= bit_count + 1;
                if (bit_count == 7) done <= 1;
                else done <= 0;
            end
        end
    end

    // Data Sending on Falling Edge (Critical for Full Duplex)
    always @(negedge sclk or posedge chip_select) begin
        if (chip_select) miso <= 0;
        else if (bit_count < 8) miso <= slave_tx_data[7 - bit_count];
    end

    always @(posedge done) data_received <= shift_reg;
endmodule