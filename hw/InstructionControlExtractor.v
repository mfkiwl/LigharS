`timescale 1ns/1ps

module InstructionControlExtractor(
  input [31:0] instr,

  output should_read_mem,
  output should_write_mem,
  output should_write_reg,
  output should_branch,
  output should_jump,

  output [2:0] alu_a_src,
  output [2:0] alu_b_src
); begin

  always @(*) begin
    case (instr[6:2]) begin
      // ## Memory Read Access
      //
      // A word will be extracted from address position `rs1 + imm12`.
      5'h00:
        should_read_mem  <= 1;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b111;
        alu_b_src        <= 3'b011;
      // ## Fences
      5'h03:
        // FIXME: (penguinliong) Just a nop for now.
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 0;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b000;
        alu_b_src        <= 3'b000;
      // ## Immediate-value Arithmetic Operations
      5'h04:
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b111;
        alu_b_src        <= 3'b011;
      // ## Add Upper Immediate to PC
      5'h05:
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b001;
        alu_b_src        <= 3'b100;
      // ## Memory Write Access
      //
      // A word in `rs2` will be written back to adress position `rs1 + imm12`.
      5'h08:
        should_read_mem  <= 0;
        should_write_mem <= 1;
        should_write_reg <= 0;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b111;
        alu_b_src        <= 3'b011;
      // ## Register-register Arithmetic Operations
      5'h0c:
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b111;
        alu_b_src        <= 3'b111;
      // ## Load Upper Immediate
      5'h0d:
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b000;
        alu_b_src        <= 3'b100;
      // ## Branch instructions
      5'h18:
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 0;
        should_branch    <= 1;
        should_jump      <= 0;
        alu_a_src        <= 3'b001;
        alu_b_src        <= 3'b101;
      // ## Jump and Link Register
      //
      // The return address will be written to `rd`.
      5'h19:
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 1;
        alu_a_src        <= 3'b001;
        alu_b_src        <= 3'b011;
      // ## Jump and Link
      //
      // The return address will be written to `rd`.
      5'h1b:
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 1;
        alu_a_src        <= 3'b001;
        alu_b_src        <= 3'b110;

    end
  end

endmodule
