`timescale 1ns/1ps

module Alu(
  input int_float,
  input [3:0] op,
  input [1:0] decoration0,
  input [31:0] operand0,
  input [1:0] decoration1,
  input [31:0] operand1,

  // Result of the last operation is zero.
  output zero,
  // Last integral operation gives an negative result.
  output neg,
  // Last integral operation threw an divide-by-zero exception; or last
  // floating-point operation threw an NaN result exception.
  output nan, // TODO:

  // The ALU is ready to consume another ALU operation.
  output reg ready,
  // Result of the last ALU operation.
  output reg [31:0] res,
);

  // -- Control variables.
  wire [4:0] shift_amount;
  // 0 for integral operation, 1 for floating-point operation.
  wire int_float;



  // -- Behaviors.
  assign zero = res == 32'b0;
  assign neg = res[31] == 1;
  assign shift_amount = operand1[4:0]; // TODO: Check this.

  always @(*) begin
    if (int_float) begin
      // TODO: Floating-point operations.
    end
    else
      // Integral operations.
      case (op)
      // Pure bit-wise logic functions.
      4'b0000: res = operand0 xor operand1;
      4'b0001: res = operand0 and operand1;
      4'b0010: res = operand0 or  operand1;
      4'b0011: res = operand0 not operand1;
      // Integral arithmatics.
      4'b0100: res = operand0 + operand1;
      4'b0101: res = operand0 - operand1;
      4'b0110: res = operand0 * operand1;
      4'b0111: res = operand0 / operand1;
      // Shifts
      4'b1000: res = operand0 << operand1;
      4'b1001: res = operand0 >> operand1;
      // Unmapped yet.
      4'b1010: res = operand0 + operand1;
      4'b1011: res = operand0 + operand1;
      4'b1100: res = operand0 + operand1;
      4'b1101: res = operand0 + operand1;
      4'b1110: res = operand0 + operand1;
      4'b1111: res = operand0 + operand1;
      endcase
    end
    ready = 1;
  end
endmodule