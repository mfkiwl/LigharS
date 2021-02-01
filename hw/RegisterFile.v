`timescale 1ns/1ps

module RegisterFile(
  input clk, reset,
  // Write access.
  input write_en,
  input [4:0] dst_addr,
  input [31:0] dst_data,
  // Read access.
  input [4:0] src_addr1,
  input [4:0] src_addr2,
  output [31:0] src_data1,
  output [31:0] src_data2
);
  // -- Storage.
  reg [31:0] reg_fields [31:0];



  // -- Control variables.
  integer i;
  wire write_to_zero;



  // -- Behaviors.
  // All write access are done on negative edge.
  assign write_to_zero = dst_addr == 32'b0;

  // Hardwired output.
  assign src_data1 = reg_fields[src_addr1];
  assign src_data2 = reg_fields[src_addr2];

  // Reset and initialize all register fields.
  always @(negedge clk) begin
    if (reset) begin
      for (i = 0; i < 32; i = i + 1)
        reg_fields[i] <= 32'b0;
    end
  end

  // If the reset signal is not set and the destination address is not zero,
  // write the data to the specified register field.
  always @(negedge clk) begin
    if (!reset & write_en & !write_to_zero) begin
      reg_fields[dst_addr] <= dst_data;
    end
  end

endmodule
