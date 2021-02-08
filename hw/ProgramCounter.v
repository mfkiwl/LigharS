`timescale 1ns/1ps

// Program counter which records the current instruction memory address for the
// entire RV core.
module ProgramCounter(
  input clk,
  input reset,

  input [31:0] next_pc,

  output [31:0] instr_addr
);

  reg [31:0] pc;

  assign instr_addr = pc;

  always @(posedge clk, posedge reset) begin
    if (reset)
      pc <= 0;
  end

  always @(negedge clk) begin
    if (!reset)
      pc <= next_pc;
    else
      pc <= pc;
  end

endmodule
