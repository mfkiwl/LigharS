`timescale 1ns/1ps

`define MEM_LIKE_MODULE .clk(clk), .reset(reset),
`define COMB_ONLY_MODULE

`define i(xinstr) instr_mem.inner[instr_idx] = xinstr; instr_idx = instr_idx + 1;

module tb_Riscv();
  reg clk, reset;

  wire [31:0] instr_addr;
  wire [31:0] instr;

  wire [31:0] data_addr;
  wire [31:0] mem_read_data;
  wire [31:0] mem_write_data;
  wire should_read_mem;
  wire should_write_mem;

  InstructionMemory instr_mem(`COMB_ONLY_MODULE
    // in
    .addr(instr_addr),
    // out
    .instr(instr)
  );

  DataMemory data_mem(`MEM_LIKE_MODULE
    // in
    .addr(data_addr),
    .should_write(should_write_mem),
    .write_data(mem_write_data),
    // out
    .read_data(mem_read_data)
  );


  Riscv uut(`MEM_LIKE_MODULE
    // in
    .instr(instr),
    .mem_read_data(mem_read_data),
    // out
    .instr_addr(instr_addr),
    .data_addr(data_addr),
    .should_write_mem(should_write_mem),
    .should_read_mem(should_read_mem),
    .mem_write_data(mem_write_data)
  );

  always #5 clk = ~clk;

  always @(posedge clk) begin
    // Execute until the instruction memory is out of instructions.
    if (uut.pc.pc >= 2 * 4)
      uut.pc.pc = 0;
  end

  integer instr_idx;
  initial begin
    clk = 0;
    reset = 1; #10 reset = 0;
    instr_idx = 0;
    // Initialize the instruction memory with instruction data.







`i(32'b00000000000100000000001010010011); // addi t0, x0, 1
`i(32'b00000000001000101000001100010011); // addi t1, t0, 2
`i(32'b00000000001000101000001100010011); // addi t1, t0, 2





  end

endmodule
