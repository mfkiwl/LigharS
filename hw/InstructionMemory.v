`timescale 1ns/1ps

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
