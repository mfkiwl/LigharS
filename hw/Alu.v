`timescale 1ns/1ps

// ALU opcode table:
// ___________________________________
// |        |                        |
// | ALU OP | Description            |
// |--------|------------------------|
// |   0000 | addition               |
// |   0001 | subtranction           |
// |--------|------------------------|
// |   0100 | shift left             |
// |   0110 | shift right unsigned   |
// |   0111 | shift right signed     |
// |--------|------------------------|
// |   1001 | and                    |
// |   1010 | or                     |
// |   1011 | xor                    |
// |--------|------------------------|
// |   1100 | set-less-than unsigned |
// |   1101 | set-less-than signed   |
// |________|________________________|
//
module Alu(
  input [3:0] alu_op,
  input [31:0] a_data,
  input [31:0] b_data,

  output [31:0] alu_res
);

  assign alu_res =
    alu_op == 4'b0000 ? a_data - b_data :
    alu_op == 4'b0001 ? a_data + b_data :

    alu_op == 4'b0100 ? a_data << b_data :
    alu_op == 4'b0110 ? a_data >> b_data :
    alu_op == 4'b0111 ? $signed(a_data) >>> $signed(b_data) :

    alu_op == 4'b1001 ? a_data & b_data :
    alu_op == 4'b1010 ? a_data | b_data :
    alu_op == 4'b1011 ? a_data ^ b_data :

    alu_op == 4'b1100 ? a < b ? 1 : 0 :
    alu_op == 4'b1101 ? $signed(a) < $signed(b) ? 1 : 0 :
    {32'bX};

endmodule
