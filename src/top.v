module TOP(
    input sysclk,
    input reset,
    input enable_n,
    output spi_clk,
    output spi_cs_n,
    output spi_mosi);

wire enable;
wire [6:0] address;
wire [47:0] data;
wire spi_ready;
wire spi_load;
reg [4:0] counter;
wire clk;

assign enable = ~enable_n;
assign spi_clk = clk;

// To ensure SPI work correctly with level shifter,
// reduce clock frequencye to 1/32.
// Zybo Z7 FPGA has output clock rate of 33MHZ
// TinyTapeout has output colock rate of 33MHZ
assign clk = counter[4];
always @(posedge sysclk) begin
  if (reset) begin
    counter <= 0;
  end else begin
    counter <= counter + 1;
  end
end

CONTROLLER controller_inst (
  .clk(clk),
  .reset(reset),
  .enable(enable),
  .spi_ready(spi_ready),
  .address(address),
  .spi_load(spi_load)
);

ROM rom_inst (
  .clk(clk),
  .address(address),
  .data(data)
);

SPI spi_inst (
    .clk(clk),
    .reset(reset),
    .load(spi_load),
    .data(data),
    .ready(spi_ready),
    .cs_n(spi_cs_n),
    .mosi(spi_mosi)
);

endmodule
