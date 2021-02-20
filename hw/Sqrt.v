`timescale 1ns/1ps

module Sqrt(
	input en,
	input clk,
	
	// 1 sign bit, 15 integer bits, 48 decimal bits
	// v needs to be positive
	input [63:0] v,
	
	// result
	output [63:0] res
);

	reg [63:0] t;
	reg [63:0] r = v;
	reg [63:0] b = 0x4000000000000000;
	reg [63:0] q = 0;

	always @(posedge clk) begin
		if (en) begin
	
			// need to find up to how many bits need to be checked
			while( b > 0x40 ) begin 
				
				t = q + b;
				if( r >= t) begin
					r = r - t;
					q = t + b;		
				end
				
				r = r << 1;
				b = b >> 1;
			end
			
			// since theres 15 integer bits, the result will be at most 8 integer bits
			q = q >> 8;
			res = q; 
			
		end
		else begin
			res = 0;
		end
	end
	
endmodule