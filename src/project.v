/*
 * Copyright (c) 2024 Ayla Lin and other students
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_led_matrix_ayla_lin(
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

wire reset;
wire enable_n;
assign reset = !rst_n;
assign enable_n = !ena;

TOP top_inst(
    .sysclk(clk),
    .reset(reset),
    .enable_n(enable_n),
    .spi_clk(uo_out[0]),
    .spi_cs_n(uo_out[1]),
    .spi_mosi(uo_out[2])
);

// All output pins must be assigned. If not used, assign to 0.
assign uo_out[7:3]  = 0;
assign uio_out = 0;
assign uio_oe  = 0;

// List all unused inputs to prevent warnings
wire _unused = &{ui_in, uio_in, 1'b0};
endmodule
