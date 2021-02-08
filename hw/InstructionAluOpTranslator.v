`timescale 1ns/1ps

module InstructionAluOpTranslator(
  input [31:0] instr,
  output reg [3:0] alu_op
);

  wire [2:0] funct3; assign funct3 = instr[14:12];

  always @(*) begin
    case (instr[6:2])
      5'h04: // Immediate-value operations.
        case (funct3)
          3'b000: alu_op = 4'b0000;
          3'b001: alu_op = 4'b0100;
          3'b010: alu_op = 4'b1101;
          3'b011: alu_op = 4'b1100;
          3'b100: alu_op = 4'b1011;
          3'b101: alu_op = funct7[5] ? 4'b0111 : 4'b0110;
          3'b110: alu_op = 4'b1010;
          3'b111: alu_op = 4'b1001;
        endcase
      5'h0c: // ALU operations.
        case (funct3)
          3'b000: alu_op = funct7[5] ? 4'b0001 : 4'b0000;
          3'b001: alu_op = 4'b0100;
          3'b010: alu_op = 4'b1101;
          3'b011: alu_op = 4'b1100;
          3'b100: alu_op = 4'b1011;
          3'b101: alu_op = funct7[5] ? 4'b0111 : 4'b0110;
          3'b110: alu_op = 4'b1010;
          3'b111: alu_op = 4'b1001;
        endcase
      default: alu_op <= 4'b0000; // addi
    endcase
  end


endmodule
