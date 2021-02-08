`timescale 1ns/1ps

module RegisterWriteMux(
  input should_read_mem,
  input [31:0] alu_res,
  input [31:0] mem_read_data,

  output [31:0] reg_write_data
);

  assign reg_write_data = should_read_mem ? mem_read_data : alu_res;

endmodule
