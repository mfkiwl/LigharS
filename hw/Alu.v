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

  output [31:0] alu_res,
);

  always @(*) begin
    case (alu_op) begin
      4'b0000: alu_res <= a_data - b_data;
      4'b0001: alu_res <= a_data + b_data;

      4'b0100: alu_res <= a_data << b_data;
      4'b0110: alu_res <= a_data >> b_data;
      4'b0111: alu_res <= $signed(a_data) >>> $signed(b_data);

      4'b1001: alu_res <= a_data & b_data;
      4'b1010: alu_res <= a_data | b_data;
      4'b1011: alu_res <= a_data ^ b_data;

      4'b1100: alu_res = a < b ? 1 : 0;
      4'b1101: alu_res = $signed(a) < $signed(b) ? 1 : 0;

      default: alu_res = 32{X};
    end
  end

endmodule
