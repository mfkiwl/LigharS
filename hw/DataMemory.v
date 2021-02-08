`timescale 1ns/1ps

module DataMemory(
  input clk,
  input reset,

  input [31:0] addr,
  input should_write,
  input [31:0] write_data,

  output reg [31:0] read_data
);

  reg [31:0] inner [1023:0];

  integer i;
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      for (i = 0; i < 1024; i = i + 1) begin
        inner[i] = 0;
      end
    end else begin
      read_data <= inner[addr];
    end
  end

  always @(negedge clk) begin
    if (should_write)
      inner[addr] <= write_data;
    else
      inner[addr] <= inner[addr];
  end

endmodule
