`timescale 1ns/1ps

module InstructionControlExtractor(
  input [31:0] instr,

  output should_read_mem,
  output should_write_mem,
  output should_write_reg,
  output should_branch,
  output should_jump,

  output reg [2:0] alu_a_src,
  output reg [2:0] alu_b_src
);

  always @(*) begin
    case (instr[6:2])
      // ## Memory Read Access
      //
      // A word will be extracted from address position `rs1 + imm12`.
      5'h00: begin
        should_read_mem  <= 1;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b111;
        alu_b_src        <= 3'b011;
      end
      // ## Fences
      5'h03: begin
        // FIXME: (penguinliong) Just a nop for now.
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 0;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b000;
        alu_b_src        <= 3'b000;
      end
      // ## Immediate-value Arithmetic Operations
      5'h04: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b111;
        alu_b_src        <= 3'b011;
      end
      // ## Add Upper Immediate to PC
      5'h05: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b001;
        alu_b_src        <= 3'b100;
      end
      // ## Memory Write Access
      //
      // A word in `rs2` will be written back to adress position `rs1 + imm12`.
      5'h08: begin
        should_read_mem  <= 0;
        should_write_mem <= 1;
        should_write_reg <= 0;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b111;
        alu_b_src        <= 3'b011;
      end
      // ## Register-register Arithmetic Operations
      5'h0c: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b111;
        alu_b_src        <= 3'b111;
      end
      // ## Load Upper Immediate
      5'h0d: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b000;
        alu_b_src        <= 3'b100;
      end
      // ## Branch instructions
      5'h18: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 0;
        should_branch    <= 1;
        should_jump      <= 0;
        alu_a_src        <= 3'b001;
        alu_b_src        <= 3'b101;
      end
      // ## Jump and Link Register
      //
      // The return address will be written to `rd`.
      5'h19: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 1;
        alu_a_src        <= 3'b001;
        alu_b_src        <= 3'b011;
      end
      // ## Jump and Link
      //
      // The return address will be written to `rd`.
      5'h1b: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 1;
        should_branch    <= 0;
        should_jump      <= 1;
        alu_a_src        <= 3'b001;
        alu_b_src        <= 3'b110;
      end
      default: begin
        should_read_mem  <= 0;
        should_write_mem <= 0;
        should_write_reg <= 0;
        should_branch    <= 0;
        should_jump      <= 0;
        alu_a_src        <= 3'b000;
        alu_b_src        <= 3'b000;
      end
    endcase
  end

endmodule
