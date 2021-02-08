`timescale 1ns/1ps

// # Alu Input Selection Table
// ___________________________________________________________
// |            |                                            |
// | ALU Source | Description                                |
// |------------|--------------------------------------------|
// |     3'b000 | Zero                                       |
// |     3'b001 | Four (Used for JAL and JALR)               |
// |     3'b010 | Current instruction address (PC)           |
// |     3'b011 | Register data                              |
// |     3'b100 | Sign-extended 12-bit instruction immediate |
// |     3'b101 | Zero-padded 20-bit instruction immediate   |
// |____________|____________________________________________|
module AluInputMux(
  input [2:0] src,

  input [31:0] instr_addr,
  input [31:0] instr,
  input [31:0] rs_data,

  output [31:0] data
);

  wire sign = instr[31];

  wire [31:0] imm12 = { {20{ sign }}, instr[31:20]             };
  wire [31:0] imm20 = {               instr[31:12], {12'b0 } };

  assign data = 
    src == 3'b000 ? 0 :
    src == 3'b001 ? 4 :
    src == 3'b010 ? instr_addr :
    src == 3'b011 ? rs_data :
    src == 3'b100 ? imm12 :
    src == 3'b101 ? imm20 :
    32'bX;

endmodule