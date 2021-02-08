`timescale 1ns/1ps

module BranchMux(
  input should_branch,
  input should_jump,

  input [31:0] alu_res,
  input [31:0] instr_addr,
  input [31:0] branch_offset,
  input [31:0] jump_offset,

  output [31:0] next_pc,
) begin

  always @(*) begin
    case ({should_branch, should_jump}) begin
      3'b00: next_pc = instr_addr + 4;
      2'b01: next_pc = instr_addr + jump_offset;
      2'b10: next_pc = alu_res == 0 ? instr_addr + branch_offset : instr_addr + 4;
      default: next_pc = 32{X};
    end
  end

endmodule
