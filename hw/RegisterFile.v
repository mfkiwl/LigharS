`timescale 1ns/1ps

module RegisterFile(
  input clk,
  input reset,

  input [4:0] read_addr1,
  input [4:0] read_addr2,
  input should_write,
  input [31:0] write_data,

  output reg [31:0] read_data1,
  output reg [31:0] read_data2,
);

  reg [31:0] inner [31:0];

  assign read_data1 = inner[read_addr1];
  assign read_data2 = inner[read_addr2];

  
  // All write access are done on negative edge.
  assign write_to_zero = dst_addr == 32'b0;

  integer i;
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      for (i = 0; i < 32; i += 1) begin
        inner[i] = 0;
      end
    end
  end

  always @(negedge clk) begin
    if (should_write & !write_to_zero)
      inner[addr] <= write_data;
    else
      inner[addr] <= inner[addr];
  end

endmodule
