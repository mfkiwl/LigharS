`timescale 1ns/1ps
// This is not a Floating-point Processing Unit but a Fixed-point Processing
// Unit. This is expected to achieve better precision then floating point
// arithmetics while retaining better performance.

// FPU opcode table:
// ____________________________________
// |         |                        |
// | ALU OP  | Description            |
// |---------|------------------------|
// | 4'b0000 | addition               |
// | 4'b0001 | subtranction           |
// | 4'b0010 | multiplication         |
// | 4'b0011 | division               |
// |---------|------------------------|
// | 4'b0100 | maximum                |
// | 4'b0101 | minimum                |
// |---------|------------------------|
// | 4'b1011 | xor                    |
// |---------|------------------------|
// | 4'b1101 | set-less-than signed   |
// |_________|________________________|
//
module Fpu (
  input [3:0] alu_op,
  input signed [63:0] a_data,
  input signed [63:0] b_data,
  input signed [63:0] c_data,

  output [63:0] alu_res,
  output zero
);

  assign alu_res =
    alu_op == 4'b000 ? a_data + b_data :
    alu_op == 4'b001 ? a_data - b_data :
    alu_op == 4'b010 ? a_data * b_data :
    alu_op == 4'b011 ? a_data / b_data :
    alu_op == 4'b100 ? 
    alu_op == 4'b101 ?
    alu_op == 4'b110 ?
    alu_op == 4'b111 ?

endmodule