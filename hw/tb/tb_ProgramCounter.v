`timescale 1ns/1ps

`define assert(signal, value) \
  if (signal !== value) begin \
      $display("ASSERTION FAILED in %m: %b != %b", signal, value); \
      $finish; \
  end

module tb_ProgramCounter();

  reg clk;
  reg reset;

  reg [31:0] next_pc;
  wire [31:0] instr_addr;

  ProgramCounter uut(
    .clk(clk),
    .reset(reset),
    .next_pc(next_pc),
    .instr_addr(instr_addr)
  );

  initial begin
    clk = 1;
    reset = 1;
    #5 clk = ~clk; #5 clk = ~clk;
    #5 clk = ~clk; #5 clk = ~clk;
    reset = 0;

    // Ensure reset zeros the counter.
    `assert(instr_addr, 0);
    #10;

    // Write in with `next_pc` on negative edge.
    next_pc = instr_addr + 4;
    #5 clk = ~clk;
    `assert(instr_addr, 0);
    #5 clk = ~clk;
    `assert(instr_addr, 4);

    $display("UNIT TEST PASSED: %m");
  end

endmodule
