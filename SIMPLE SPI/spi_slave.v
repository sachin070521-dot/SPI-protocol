module spi_slave (
    input  wire sclk,
    input  wire mosi,
    input  wire cs,
    output wire [7:0] dout,
    output reg  done
);

    // State Encoding
    parameter idle   = 1'b0;
    parameter sample = 1'b1;

    reg state = idle;

    reg [7:0] data  = 8'b0;
    reg [3:0] count = 0;

/////////////////////////////////////////////////////////////
// SPI Sampling Logic (Mode-0 style: sample on falling edge)
/////////////////////////////////////////////////////////////
always @(negedge sclk) begin
    case (state)

        idle: begin
            done <= 1'b0;
            if (cs == 1'b0)
                state <= sample;
            else
                state <= idle;
        end

        sample: begin
            if (count < 8) begin
                count <= count + 1;
                data  <= {data[6:0], mosi};  // Shift left, MSB first
                state <= sample;
            end
            else begin
                count <= 0;
                state <= idle;
                done  <= 1'b1;  // 1 byte received
            end
        end

        default: state <= idle;

    endcase
end

assign dout = data;

endmodule
