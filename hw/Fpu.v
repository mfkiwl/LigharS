`timescale 1ns/1ps

module Fpu(
  // Issue a new operation and terminate any existing operation.
  input en,
  // Clock signal.
  input clk,
  // FPU operation.
  input [1:0] op,
  // Left arithmatic operand in 32-bit floating-point number.
  input [31:0] operand0,
  // Right arithmatic operand in 32-bit floating-point number.
  input [31:0] operand1,

  // Last floating-point operation threw an NaN result exception.
  output nan,

  // Result of FPU.
  output reg [31:0] res,
);

  // -- Behaviors.
  always @(posedge clk) begin
    if (en) begin
      case (op) begin
      2'b00: res = X; // Addition.
      2'b01: res = X; // Subtraction.
      2'b10: res = X; // Multiplication.
      2'b11: res = X; // Division.

      default: res = X;
      endcase
    end
    else begin
      res = 0;
    end
  end

endmodule
