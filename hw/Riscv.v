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






// Program counter which records the current instruction memory address for the
// entire RV core.
module ProgramCounter(
  input clk,
  input reset,

  input [31:0] next_pc,

  output [31:0] instr_addr,
);

  reg [31:0] pc;

  assign instr_addr = pc;

  always @(posedge reset) begin
    pc <= 0;
  end

  always @(negedge clk) begin
    if (!reset)
      pc <= next_pc;
  end

endmodule

module InstructionMemory(
  input clk,
  input reset,

  input [31:0] addr,

  output [31:0] instr
);

  reg [31:0] inner [255:0];

  assign instr = inner[addr];

  initial begin
    // TODO: (penguinliong) Initialize instruction memory with data.
  end

  always @(posedge clk) begin
    // TODO: (penguinliong) Fetch from lower cache hierarchy?
  end

endmodule

module InstructionDecoder(
  input [31:0] instr,

  output [3:0] alu_op,
  output should_read_mem,
  output should_write_mem,
  output should_write_reg,
  output should_branch,
  output should_jump,
  output should_use_imm_as_b,
  output [31:0] branch_offset,
  output [31:0] jump_offset,
  output [4:0] rs1_addr,
  output [4:0] rs2_addr,
  output [4:0] rd_addr
);
  // -- Control variables.
  wire [6:0] opcode;
  wire [2:0] funct3;
  wire [6:0] funct7;
  wire [11:0] imm12;

  // -- Modules.
  SignExtension sign_ext {
    .imm(0),
    .res(imm),
  };

  // -- Behaviors.
  assign opcode = instr[0:6];
  assign funct3 = instr[12:14];
  assign funct7 = instr[25:31];
  assign imm7 = instr[31:25];
  assign imm12 = instr[31:20];
  assign imm20 = instr[31:12];

  assign rs1_addr = instr[15:19];
  assign rs2_addr = instr[20:24];
  assign rd_addr = instr[7:11];
  assign branch_offset = { 20{ instr[31] }, instr[7], instr[30:25], instr[11:8], 1'b0 };

  assign imm =
    should_use_imm7  ? { 25{ imm7[6] }, imm7 } :
    should_use_imm20 ? { imm20, 12{ 1'b0 } } :
                       { 20{ imm12[11] }, imm12 };

  always @(*) begin
    case (opcode[6:2])
      5'h00: // Memory read access.
        alu_op = 0; // addi
        should_read_mem = 1;
        should_write_mem = 0;
        should_write_reg = 1;
        should_branch = 0;
        should_jump = 0;
        should_use_imm7 = 0;
        should_use_imm20 = 0;
        should_use_imm_as_b = 0;
        jump_offset = 0;
      5'h03: // Fences.
        // FIXME: (penguinliong) Just a nop for now.
        alu_op = 0; // addi
        should_read_mem = 0;
        should_write_mem = 0;
        should_write_reg = 0;
        should_branch = 0;
        should_jump = 0;
        should_use_imm7 = 0;
        should_use_imm20 = 0;
        should_use_imm_as_b = 0;
        jump_offset = 0;
      5'h04: // Immediate-value operations.
        case (funct3) begin
          0'b000: alu_op = 4'b0000;
          0'b001: alu_op = 4'b0100;
          0'b010: alu_op = 4'b1101;
          0'b011: alu_op = 4'b1100;
          0'b100: alu_op = 4'b1011;
          0'b101: alu_op = funct7[5] ? 4'b0111 : 4'b0110;
          0'b110: alu_op = 4'b1010;
          0'b111: alu_op = 4'b1001;
        end
        should_read_mem = 0;
        should_write_mem = 0;
        should_write_reg = 1;
        should_branch = 0;
        should_jump = 0;
        should_use_imm7 = 0;
        should_use_imm20 = 0;
        should_use_imm_as_b = 1;
        jump_offset = 0;
      5'h05: // auipc
        alu_op = 0; // addi
        should_read_mem = 0;
        should_write_mem = 1;
        should_write_reg = 0;
        should_branch = 0;
        should_jump = 0;
        should_use_imm7 = 0;
        should_use_imm20 = 1;
        should_use_imm_as_b = 1;
        jump_offset = 0;
      5'h08: // Memory write access.
        alu_op = 0; // addi
        should_read_mem = 0;
        should_write_mem = 1;
        should_write_reg = 0;
        should_branch = 0;
        should_jump = 0;
        should_use_imm7 = 0;
        should_use_imm20 = 0;
        should_use_imm_as_b = 1;
        jump_offset = 0;
      5'h0c: // ALU operations.
        case (funct3) begin
          0'b000: alu_op = funct7[5] ? 4'b0001 : 4'b0000;
          0'b001: alu_op = 4'b0100;
          0'b010: alu_op = 4'b1101;
          0'b011: alu_op = 4'b1100;
          0'b100: alu_op = 4'b1011;
          0'b101: alu_op = funct7[5] ? 4'b0111 : 4'b0110;
          0'b110: alu_op = 4'b1010;
          0'b111: alu_op = 4'b1001;
        end
        should_read_mem = 0;
        should_write_mem = 0;
        should_write_reg = 1;
        should_branch = 0;
        should_jump = 0;
        should_use_imm7 = 0;
        should_use_imm20 = 0;
        should_use_imm_as_b = 0;
        jump_offset = 0;
      5'h0d: // lui
        alu_op = 0; // addi
        should_read_mem = 0;
        should_write_mem = 1;
        should_write_reg = 0;
        should_branch = 0;
        should_jump = 0;
        should_use_imm7 = 0;
        should_use_imm20 = 1;
        should_use_imm_as_b = 1;
        jump_offset = 0;
      5'h18: // Branch instructions.
      5'h19: // jalr
      5'h1b: // jal
      default:
    endcase
  end
endmodule

module RegisterFile(
  input clk,
  input reset,

  input [4:0] read_addr1,
  input [4:0] read_addr2,
  input should_write,
  input [31:0] write_data,

  output reg [31:0] read_data1,
  output reg [31:0] read_data2,
);

  reg [31:0] inner [31:0];

  assign read_data1 = inner[read_addr1];
  assign read_data2 = inner[read_addr2];

  integer i;
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      for (i = 0; i < 32; i += 1) begin
        inner[i] = 0;
      end
    end
  end

  always @(negedge clk) begin
    if (should_write)
      inner[addr] <= write_data;
    else
      inner[addr] <= inner[addr];
  end

endmodule

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

module DataMemory(
  input clk,
  input reset,

  input [31:0] addr,
  input should_write,
  input [31:0] write_data,

  output reg [31:0] read_data,
);

  reg [31:0] inner [1023:0];

  assign read_data = inner[addr];

  integer i;
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      for (i = 0; i < 1024; i += 1) begin
        inner[i] = 0;
      end
    end
  end

  always @(negedge clk) begin
    if (should_write)
      inner[addr] <= write_data;
    else
      inner[addr] <= inner[addr];
  end

endmodule

module RegisterWriteMux(
  input should_read_mem,
  input [31:0] alu_res,
  input [31:0] mem_read_data,

  input [31:0] reg_write_data,
) begin

  always @(*) begin
    if (should_read_mem)
      reg_write_data <= mem_read_data;
    else
      reg_write_data <= alu_res;
  end

endmodule
