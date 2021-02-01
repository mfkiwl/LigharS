`timescale 1ns/1ps

module SignExtension(
  input [19:0] imm,
  output reg [31:0] res,
);
  // -- Control variables.
  wire sign = imm[19];

  // -- Behaviors.
  always @(*) begin
    res = { { 16{ sign } }, imm };
  end

endmodule

module InstructionDecoder(
  input [31:0] instr,
  output reg [3:0] alu_op,
  output reg [4:0] rd_addr,
  output [4:0] rs1_addr,
  output [4:0] rs2_addr,
  output [31:0] imm,
  output reg imm_as_rs2,
  output reg pc_as_rs2,
  output reg mem_read,
  output reg mem_write,
  output reg branch,
  output reg jump,
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
  assign imm12 = instr[31:20];
  assign imm20 = instr[31:12];
  assign rs1_addr = instr[15:19];
  assign rs2_addr = instr[20:24];


  assign imm = { 20{ imm12[11] }, imm12 };

  always @(*) begin
    case (opcode[6:2])
      5'h00: // Memory read access.
        alu_op = 0; // addi
        rd_addr = instr[7:11];
        imm_as_rs2 = 1;
        pc_as_rs2 = 0;
        mem_read = 1;
        mem_write = 0;
        branch = 0;
        jump = 0;
      5'h03: // Fences.
      5'h04: // Immediate-value operations.
        alu_op = { (funct3 == 0 ? 0 : instr[31]), funct3 };
        rd_addr = instr[7:11];
        imm_as_rs2 = 1;
        pc_as_rs2 = 0;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        jump = 0;
      5'h05: // auipc
      5'h08: // Memory write access.
        alu_op = 0; // addi
        rd_addr = instr[7:11];
        imm_as_rs2 = 1;
        pc_as_rs2 = 0;
        mem_read = 0;
        mem_write = 1;
        branch = 0;
        jump = 0;
      5'h0c: // ALU operations.
        alu_op = { instr[31], funct3 };
        imm_as_rs2 = 0;
        pc_as_rs2 = 0;
        mem_read = 0;
        mem_write = 0;
        branch = 0;
        jump = 0;
      5'h0d: // lui
      5'h18: // Branch instructions.
      5'h19: // jalr
      5'h1b: // jal
      default:
        alu_op = 4'bX;
        imm_as_rs2 = 1'bX;
        mem_read = 1'bX;
        mem_write = 1'bX;
    endcase
  end

endmodule
