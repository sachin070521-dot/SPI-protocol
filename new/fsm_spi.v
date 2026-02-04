module fsm_spi(
    input wire clk,
    input wire rst,
    input wire tx_enable,
    output reg mosi,
    output reg cs,
    output wire sclk
);

    // State Encoding (Verilog style)
    parameter idle     = 2'b00;
    parameter start_tx = 2'b01;
    parameter tx_data  = 2'b10;
    parameter end_tx   = 2'b11;

    reg [1:0] state, next_state;

    reg [7:0] din = 8'b10101010;

    reg spi_sclk = 0;
    reg [2:0] count = 0;
    integer bit_count = 0;

/////////////////////////////////////////////////////////////
// SCLK Generation
/////////////////////////////////////////////////////////////
always @(posedge clk) begin
    case(next_state)
        idle: spi_sclk <= 0;

        start_tx:
            if(count < 3'b011 || count == 3'b111)
                spi_sclk <= 1'b1;
            else
                spi_sclk <= 1'b0;

        tx_data:
            if(count < 3'b011 || count == 3'b111)
                spi_sclk <= 1'b1;
            else
                spi_sclk <= 1'b0;

        end_tx:
            if(count < 3'b011)
                spi_sclk <= 1'b1;
            else
                spi_sclk <= 1'b0;

        default: spi_sclk <= 0;
    endcase
end

/////////////////////////////////////////////////////////////
// State Register
/////////////////////////////////////////////////////////////
always @(posedge clk) begin
    if (rst)
        state <= idle;
    else
        state <= next_state;
end

/////////////////////////////////////////////////////////////
// Next State Logic
/////////////////////////////////////////////////////////////
always @(*) begin
    next_state = state;  // default

    case(state)

        idle: begin
            mosi = 1'b0;
            cs   = 1'b1;
            if(tx_enable)
                next_state = start_tx;
        end

        start_tx: begin
            cs = 1'b0;
            if(count == 3'b111)
                next_state = tx_data;
        end

        tx_data: begin
            mosi = din[7-bit_count];
            if(bit_count == 8) begin
                next_state = end_tx;
                mosi = 1'b0;
            end
        end

        end_tx: begin
            cs   = 1'b1;
            mosi = 1'b0;
            if(count == 3'b111)
                next_state = idle;
        end

    endcase
end

/////////////////////////////////////////////////////////////
// Counter Logic
/////////////////////////////////////////////////////////////
always @(posedge clk) begin
    case(state)

        idle: begin
            count <= 0;
            bit_count <= 0;
        end

        start_tx:
            count <= count + 1;

        tx_data: begin
            if(bit_count != 8) begin
                if(count < 3'b111)
                    count <= count + 1;
                else begin
                    count <= 0;
                    bit_count <= bit_count + 1;
                end
            end
        end

        end_tx: begin
            count <= count + 1;
            bit_count <= 0;
        end

        default: begin
            count <= 0;
            bit_count <= 0;
        end
    endcase
end

assign sclk = spi_sclk;

endmodule
