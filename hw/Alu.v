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
      3'b0000: res = operand0 + operand1;
      3'b1000: res = operand0 - operand1;
      3'b0001: res = operand0 << shift_amount;
      3'b0010: res = $signed(operand0) < $signed(operand1) ? 1 : 0;
      3'b0011: res = operand0 < operand1 ? 1 : 0;
      3'b0100: res = operand0 ^ operand1;
      3'b0101: res = operand0 >> shift_amount;
      3'b1101: res = $signed(operand0) >>> shift_amount;
      3'b0110: res = operand0 | operand1;
      3'b0111: res = operand0 & operand1;

      default: res = 32'bX;
      endcase
    end
    else begin
      res = 32'bX;
    end
  end

endmodule
