`timescale 1ns/1ps

module BranchMux(
  input should_branch,
  input should_jump,

  input [31:0] instr,
  input [31:0] instr_addr,

  output [31:0] next_pc
);

  wire [31:0] branch_offset = { {20{ instr[31] }},     instr[7], instr[30:25],  instr[11:8], 1'b0 };
  wire [31:0] jump_offset   = { {12{ instr[31] }}, instr[19:12],    instr[20], instr[30:21], 1'b0 };

  assign next_pc = instr_addr + 4; // TODO: (penguinliong) Do actual branching.
endmodule
