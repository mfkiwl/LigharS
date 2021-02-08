`timescale 1ns/1ps

module BranchMux(
  input should_branch,
  input should_jump,

  input [31:0] alu_res,
  input [31:0] instr_addr,
  input [31:0] branch_offset,
  input [31:0] jump_offset,

  output [31:0] next_pc
);

  wire sel = {should_branch, should_jump};
  assign next_pc =
    sel == 3'b00 ? instr_addr + 4:
    sel == 2'b01 ? instr_addr + jump_offset:
    sel == 2'b10 ? alu_res == 0 ? instr_addr + branch_offset : instr_addr + 4:
    32'bX;

endmodule
