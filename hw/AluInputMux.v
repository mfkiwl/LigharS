`timescale 1ns/1ps

// # Alu Input Selection Table
// ___________________________________________________________
// |            |                                            |
// | ALU Source | Description                                |
// |------------|--------------------------------------------|
// |     3'b000 | Zero                                       |
// |     3'b001 | Current instruction address                |
// |     3'b010 | Sign-extended 7-bit instruction immediate  |
// |     3'b011 | Sign-extended 12-bit instruction immediate |
// |     3'b100 | Zero-padded 20-bit instruction immediate   |
// |     3'b101 | Branch offset                              |
// |     3'b110 | JAL jump offset                            |
// |     3'b111 | Register data                              |
// |____________|____________________________________________|
module AluInputMux(
  input [2:0] src,

  input [31:0] instr_addr,
  input [31:0] instr,
  input [31:0] rs_data,

  output data
);

  wire sign = instr[31];

  wire [31:0] imm7  = { {25{ sign }}, instr[31:25]             };
  wire [31:0] imm12 = { {20{ sign }}, instr[31:20]             };
  wire [31:0] imm20 = {               instr[31:12], {12'b0 } };
  wire [31:0] branch_offset = { {20{ instr[31] }},     instr[7], instr[30:25],  instr[11:8], 1'b0 };
  wire [31:0] jump_offset   = { {12{ instr[31] }}, instr[19:12],    instr[20], instr[30:21], 1'b0 };

  assign data = 
    src == 3'b000 ? 0 :
    src == 3'b001 ? instr_addr :
    src == 3'b010 ? imm7 :
    src == 3'b011 ? imm12 :
    src == 3'b100 ? imm20 :
    src == 3'b101 ? branch_offset :
    src == 3'b110 ? jump_offset :
    src == 3'b111 ? rs_data :
    32'bX;

endmodule