`timescale 1ns/1ps

module Alu(
  // Issue a new operation and terminate any existing operation.
  input en,
  // Clock signal.
  input clk,
  // ALU operation.
  input [3:0] op,
  // Left arithmatic operand in 32-bit integer number.
  input [31:0] operand0,
  // Right arithmatic operand in 32-bit integer number.
  input [31:0] operand1,

  // Result of the last operation is zero.
  output zero,
  // Last integral operation gives an negative result.
  output neg,

  // Result of the last ALU operation.
  output reg [31:0] res,
);

  // -- Control variables.
  wire [4:0] shift_amount;



  // -- Behaviors.
  assign zero = res == 32'b0;
  assign neg = res[31] == 1;
  assign shift_amount = operand1[4:0]; // TODO: Check this.

  always @(posedge clk) begin
    if (en) begin
      case (op)
      // Integral arithmatics.
      3'b000: res = operand0 + operand1;
      3'b001: res = operand0 - operand1;
      // 1-bit shifter
      3'b010: res = operand0 << shift_amount; // Left-shift.
      3'b011: res = operand0 >> shift_amount; // Right-shift.
      // Pure bit-wise logic functions.
      3'b100: res = operand0 not operand1;
      3'b101: res = operand0 and operand1;
      3'b110: res = operand0 or  operand1;
      3'b111: res = operand0 xor operand1;

      default: res = X;
      endcase
    end
    else begin
      res = 0;
    end
  end

endmodule