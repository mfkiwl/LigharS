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
  input reset,

  input [31:0] instr,
  input [31:0] mem_read_data,

  output [31:0] instr_addr,
  output [31:0] data_addr,
  output should_read_mem,
  output should_write_mem,
  output [31:0] mem_write_data
);

wire [31:0] next_pc;
wire [2:0] alu_a_src, alu_b_src;
wire [3:0] alu_op;
wire [4:0] rs1_addr, rs2_addr, rd_addr;
wire [31:0] rs1_data, rs2_data;
wire [31:0] a_data, b_data;
wire [31:0] alu_res;
wire should_write_reg, should_branch, should_jump;
wire [31:0] reg_write_data;


assign data_addr = alu_res;
assign mem_write_data = rs2_data;


// Components.

ProgramCounter pc(`MEM_LIKE_MODULE
  // in
  .next_pc(next_pc),
  // out
  .instr_addr(instr_addr)
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
  .rs1_addr(rs1_addr),
  .rs2_addr(rs2_addr),
  .rd_addr(rd_addr),
  .alu_a_src(alu_a_src),
  .alu_b_src(alu_b_src)
);
InstructionAluOpTranslator instr_alu_op_trans(`COMB_ONLY_MODULE
  // in
  .instr(instr),
  // out
  .alu_op(alu_op)
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
AluInputMux alu_a_mux(`COMB_ONLY_MODULE
  // in
  .src(alu_a_src),
  .instr_addr(instr_addr),
  .instr(instr),
  .rs_data(rs1_data),
  // out
  .data(a_data)
);
AluInputMux alu_b_mux(`COMB_ONLY_MODULE
  // in
  .src(alu_b_src),
  .instr_addr(instr_addr),
  .instr(instr),
  .rs_data(rs2_data),
  // out
  .data(b_data)
);
Alu alu(`COMB_ONLY_MODULE
  // in
  .alu_op(alu_op),
  .a_data(a_data),
  .b_data(b_data),
  // out
  .alu_res(alu_res)
);
BranchMux branch_mux(`COMB_ONLY_MODULE
  // in
  .should_branch(should_branch),
  .should_jump(should_jump),
  .instr(instr),
  .instr_addr(instr_addr),
  // out
  .next_pc(next_pc)
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
