module SPI(
    input clk,
    input reset,
    input load,
    input [47:0] data,
    output ready,
    output cs_n,
    output mosi);

localparam BUFFER_WIDTH = 64;

// States
// IDLE:
//   Set `ready` to 1.
//   Wait for `load` input to become 1.
//   When it happens, load `data` into `buffer`.
// SEND:
//   Send `buffer` bit-by-bit to `mosi`.
//   Set `cs_n` to 0 (active).
// PAUSE:
//   Pause (do not accept new `data`) for some time
//   to give the LED Driver time to finish processing.
localparam IDLE = 2'b00;
localparam SEND = 2'b01;
localparam PAUSE = 2'b10;

reg [63:0] buffer;
reg [6:0] counter;
reg [1:0] state;

assign mosi = buffer[BUFFER_WIDTH-1];
assign cs_n = !(state == SEND);
assign ready = (state == IDLE);

wire clk_copy;
assign clk_copy = clk;

always @(posedge clk_copy) begin
  if (reset) begin
    buffer <= 0;
    counter <= 0;
    state <= IDLE;
    end

  else begin
    case (state)
      IDLE: begin
        counter <= 0;
        if (load) begin
          buffer[11:0] <= data[11:0];
          buffer[15:12] <= 0;
          buffer[27:16] <= data[23:12];
          buffer[31:28] <= 0;
          buffer[43:32] <= data[35:24];
          buffer[47:44] <= 0;
          buffer[59:48] <= data[47:36];
          buffer[63:60] <= 0;
          state <= SEND;
        end
      end

      SEND: begin
        buffer[BUFFER_WIDTH-1:1] <= buffer[BUFFER_WIDTH-2:0];
        counter <= counter + 1;
        if (counter == BUFFER_WIDTH - 1) begin
          state <= IDLE;
        end
      end

      PAUSE: begin
        buffer[BUFFER_WIDTH-1:1] <= buffer[BUFFER_WIDTH-2:0];
        counter <= counter + 1;
        if (counter == 7'b1111111) begin
          state <= IDLE;
        end
      end

      default: begin
        buffer <= 0;
        counter <= 0;
        state <= IDLE;
      end
    endcase
  end
end

endmodule
