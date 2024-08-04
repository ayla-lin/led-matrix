module CONTROLLER(
    input clk,
    input reset,
    input enable,
    input spi_ready,
    output reg [6:0] address,
    output reg spi_load);

reg [2:0] state;
reg [21:0] counter;
reg spi_load_next;
reg spi_load_pending;
reg spi_ready_delay;

// States
// IDLE:
//   Wait for `spi_ready` to become 1.
//   Set `address` to the first for setup and
//   chage state to STEUP.
// STEUP:
//   Send instructions for setup to LED Driver.
//   This is done by sending addresses of setup
//   instructions to ROM, and `spi_load` to SPI.
// DISPLAY:
//   Send bitmaps to LED Dr
//   Each column of a bitmap is loaded from ROM
//   and sent to SPI once. At the end of each
//   bitmap, SPI is paused by several seconds.
// PAUSE:
//   Pause SPI by 2^21 clocks.
localparam IDLE = 3'b000;
localparam SETUP = 3'b001;
localparam DISPLAY = 3'b010;
localparam PAUSE = 3'b011;

always @(posedge clk) begin
  spi_ready_delay <= spi_ready;
  spi_load_pending <= spi_load_next;
  spi_load <= spi_load_pending;
  if (reset || !enable) begin
    state <= IDLE;
    counter <= 0;
    spi_load_next <= 1'b0;

  end else begin
    case (state)
      IDLE: begin
        spi_load_next <= 1'b0;
        if (spi_ready) begin
          address <= 7'b1111111;
          state <= SETUP;
          counter <= 64;
        end
      end
        
      SETUP: begin
        if (spi_ready && !spi_load_next && counter > 62) begin
          address <= address + 1;
          spi_load_next <= 1'b1;
          counter <= 0;
          if (address == 7'b0000011) begin
            state <= DISPLAY;
          end
        end else begin
          spi_load_next <= 1'b0;
          counter <= counter + 1;
        end
      end
          
      DISPLAY: begin
        if (spi_ready && !spi_load_next && counter > 62) begin
          spi_load_next <= 1'b1;
          counter <= 0;
          
          // At the end of each bitmap, change state
          // to PAUSE so the bitmap will be displayed
          // for a few seconds.
          if (address == 7'b0001011 ||
              address == 7'b0010011) begin
            state <= PAUSE;
          end

          // If it's at the end of the last bitmap
          // move to the begining of the first bitmap;
          // otherwise, move to next column of the
          // same bitmap or the first column of the next
          // bitmap.
          if (address == 7'b0010011) begin
              address <= 7'b0000011;
          end else begin
            address <= address + 1;
          end
        end else begin
          spi_load_next <= 1'b0;
          counter <= counter + 1;
        end
      end

      PAUSE: begin
        spi_load_next <= 1'b0;
        counter <= counter + 1;
        if (counter == 22'b1111111111111111111111) begin
          state <= DISPLAY;
        end
      end

      default: begin
        state <= IDLE;
        counter <= 22'b0000000000000000000000;
        spi_load_next <= 1'b0;
      end
    endcase
  end
  end

endmodule
