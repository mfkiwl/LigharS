`timescale 1ns/1ps

module DataMemory(
  input clk,
  input reset,

  input [31:0] addr,
  input should_write,
  input [31:0] write_data,

  output [31:0] read_data
);

  reg [31:0] inner [1023:0];

  wire word_aligned_addr = { 2'b00, addr[31:2] };
  
  assign read_data = inner[word_aligned_addr]; 

  integer i;
  always @(posedge clk, posedge reset) begin
    if (reset) begin
      for (i = 0; i < 1024; i = i + 1) begin
        inner[i] = 0;
      end
    end
  end

  always @(negedge clk) begin
    if (should_write)
      inner[word_aligned_addr] <= write_data;
    else
      inner[word_aligned_addr] <= inner[word_aligned_addr];
  end

endmodule
