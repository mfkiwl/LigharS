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

  output data,
);

  wire [31:0] imm7;
  wire [31:0] imm12;
  wire [31:0] imm20;
  wire [31:0] branch_offset;
  wire [31:0] jump_offset;

  assign imm7  = { 25{ instr[31] }, instr[31:25]             };
  assign imm12 = { 20{ instr[31] }, instr[31:20]             };
  assign imm20 = {                  instr[31:12], 12{ 1'b0 } };
  assign branch_offset = { 20{ instr[31] },     instr[7], instr[30:25],  instr[11:8], 1'b0 };
  assign jump_offset   = { 12{ instr[31] }, instr[19:12],    instr[20], instr[30:21], 1'b0 };

  always @(*) begin
    case (src) begin
      3'b000: data <= 0;
      3'b001: data <= instr_addr;
      3'b010: data <= imm7;
      3'b011: data <= imm12;
      3'b100: data <= imm20;
      3'b101: data <= branch_offset;
      3'b110: data <= jump_offset;
      3'b111: data <= rs_data;
    end
  end

endmodule