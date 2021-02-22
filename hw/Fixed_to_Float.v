`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2021 01:40:44 AM
// Design Name: 
// Module Name: Fixed_to_Float
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Fixed_to_Float(
    input [63:0] fixed_point,
    output reg [31:0] float 
    );
    
    reg [63:0] fx;         //fixed point      
    reg sign = 0;          //floating point sign
    reg [7:0] fl_e;        // floating point exponent
    reg [22:0] fl_m;       // floating point mantissa
    integer i, index;
    
 initial begin
    fx = fixed_point;
    if (fx[63] == 1) begin
        sign = 1;
        fx = -fx; //2's complement
    end
    for(i = 0; i < 63; i = i+1) begin
        
        if(fx[i] == 1) begin
            index = i;
        end
    end
    
    fl_e = (index - 48) + 127; // gives exponent value
    fx = fx << (63 - index); // moves mantissa to front of fx
    fl_m = fx[62:40];
    
    float = {sign, fl_e, fl_m}; // combines all into float
    
   
   end
endmodule
