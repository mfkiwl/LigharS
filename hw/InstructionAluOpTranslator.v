`timescale 1ns/1ps

module InstructionAluOpTranslator(
  input [31:0] instr,
  output [3:0] alu_op
);

  wire [2:0] funct3; assign funct3 = instr[14:12];

  always (*) begin
    case (instr[6:2]) begin
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
      default: alu_op <= 4'b0000; // addi
    end
  end


endmodule
