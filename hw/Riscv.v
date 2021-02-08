`timescale 1ns/1ps
// In this project the modules are classified into two categories: Memory-like,
// and Combination-only.
//
// Memory-like modules are like memory components, they MUST hold their
// computation result in registers within a cycle. Memory-like components should
// be reading on the positive edge while being written on the negative edge.
//
// Combination-only modules are pure combinational circuits, they MUST NOT
// use any register to hold their result.

`define MEM_LIKE_MODULE .clk(clk), .reset(reset),
`define COMB_ONLY_MODULE

module Riscv(
  input clk,
  input reset
);

// Components.

ProgramCounter pc(`MEM_LIKE_MODULE
  // in
  .next_pc(next_pc),
  // out
  .instr_addr(instr_addr),
);
InstructionMemory instr_mem(`MEM_LIKE_MODULE
  // in
  .addr(instr_addr),
  // out
  .instr(instr),
);
InstructionControlExtractor instr_ctrl_extract(`COMB_ONLY_MODULE
  // in
  .instr(instr),
  // out
  .should_read_mem(should_read_mem),
  .should_write_mem(should_write_mem),
  .should_write_reg(should_write_reg),
  .should_branch(should_branch),
  .should_jump(should_jump),
  .should_use_pc_as_a(should_use_pc_as_a),
  .should_use_zero_as_a(should_use_zero_as_a),
  .should_use_imm7_as_b(should_use_imm7_as_b),
  .should_use_imm20_as_b(should_use_imm20_as_b),
  .should_use_imm12_as_b(should_use_imm12_as_b),
  .should_use_jump_offset_as_b(should_use_jump_offset_as_b),
  .should_use_branch_offset_as_b(should_use_branch_offset_as_b),
);
InstructionAluOpTranslator instr_alu_op_trans(`COMB_ONLY_MODULE
  // in
  .instr(instr),
  // out
  .alu_op(alu_op),
);
RegisterFile reg_file(`MEM_LIKE_MODULE
  // in
  .read_addr1(rs1_addr),
  .read_addr2(rs2_addr),
  .write_addr(rd_addr),
  .should_write(should_write_reg),
  .write_data(reg_write_data),
  // out
  .read_data1(rs1_data),
  .read_data2(rs2_data)
);
AluInputMux alu_in_mux(`COMB_ONLY_MODULE
  // in
  .instr(instr),
  .rs1_data(rs1_data),
  .rs2_data(rs2_data),
  .should_use_pc_as_a(should_use_pc_as_a),
  .should_use_zero_as_a(should_use_zero_as_a),
  .should_use_imm7_as_b(should_use_imm7_as_b),
  .should_use_imm20_as_b(should_use_imm20_as_b),
  .should_use_imm12_as_b(should_use_imm12_as_b),
  .should_use_jump_offset_as_b(should_use_jump_offset_as_b),
  .should_use_branch_offset_as_b(should_use_branch_offset_as_b),
  // out
  .a_data(a_data),
  .b_data(b_data),
);
Alu alu(`COMB_ONLY_MODULE
  // in
  .alu_op(alu_op),
  .a_data(a_data),
  .b_data(b_data),
  // out
  .alu_res(alu_res),
);
BranchMux branch_mux(`COMB_ONLY_MODULE
  // in
  .should_branch(should_branch),
  .should_jump(should_jump),
  .alu_res(alu_res),
  .instr_addr(instr_addr),
  .branch_offset(branch_offset),
  .jump_offset(jump_offset),
  // out
  .next_pc(next_pc),
);
assign data_addr = alu_res;
assign mem_write_data = rs2_data;
DataMemory data_mem(`MEM_LIKE_MODULE
  // in
  .addr(data_addr),
  .should_write(should_write_mem),
  .write_data(mem_write_data),
  // out
  .read_data(mem_read_data)
);
RegisterWriteMux reg_write_mux(`COMB_ONLY_MODULE
  // in
  .should_read_mem(should_read_mem),
  .alu_res(alu_res),
  .mem_read_data(mem_read_data),
  // out
  .reg_write_data(reg_write_data)
);

endmodule
