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
  output reg [31:0] res
);

  // -- Control variables.
  wire [4:0] shift_amount;



  // -- Behaviors.
  assign zero = res == 32'b0 ? 1 : 0;
  assign neg = res[31] == 1 ? 1 : 0;
  assign shift_amount = operand1[4:0]; // TODO: Check this.

  always @(posedge clk) begin
    if (en) begin
      case (op)
      // Integral arithmatics.
      4'b0000: res = operand0 + operand1;
      4'b0001: res = operand0 - operand1;
      4'b0010: res = operand0 * operand1; // Left-shift.
      4'b0011: res = operand0 / operand1; // Right-shift.
      // Pure bit-wise logic functions.
      4'b1000: res = !operand0;
      4'b1001: res = operand0 & operand1;
      4'b1010: res = operand0 | operand1;
      4'b1011: res = operand0 ^ operand1;
      // Bit shifter
      4'b1100: res = operand0 << shift_amount; // Left-shift logic.
      4'b1101: res = operand0 >> shift_amount; // Right-shift logic.
      //4'b1110: res = signed'(operand0) <<< shift_amount; // Left-shift arithmetic. The same as logical left-shift.
      4'b1111: res = $signed(operand0) >>> shift_amount; // Right-shift arithmetic.

      default: res = 32'bX;
      endcase
    end
    else begin
      res = 32'bX;
    end
  end

endmodule