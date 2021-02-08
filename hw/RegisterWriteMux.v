`timescale 1ns/1ps

module RegisterWriteMux(
  input should_read_mem,
  input [31:0] alu_res,
  input [31:0] mem_read_data,

  input [31:0] reg_write_data,
) begin

  always @(*) begin
    if (should_read_mem)
      reg_write_data <= mem_read_data;
    else
      reg_write_data <= alu_res;
  end

endmodule
