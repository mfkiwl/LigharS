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
  output reg [4:0] alu_op,
  // Report that the decoder is ready to consume another instruction.
  output reg ready,
  // The instruction used a unsupported opcode.
  output reg unimpl_opcode,
);
  // -- Control variables.
  wire [6:0] opcode;
  wire [4:0] rd;
  wire [4:0] rs1;
  wire [4:0] rs2;
  wire [2:0] funct3;
  wire [6:0] funct7;

  wire is_r_type;
  wire is_i_type;
  wire is_s_type;
  wire is_u_type;
  wire [31:0] imm,

  // -- Modules.
  SignExtension sign_ext {
    .imm(0),
    .res(imm),
  };

  // -- Behaviors.
  always @(*) begin
    case (opcode[6:2])
      5'h00: // Memory read access.
      5'h03: // Fences.
      5'h04: // Immediate-value operations.
      5'h05: // auipc
      5'h08: // Memory write access.
      5'h0c: // ALU operations.
      5'h0d: // lui
      5'h18: // Branch instructions.
      5'h19: // jalr
      5'h1b: // jal
    endcase
  end

endmodule