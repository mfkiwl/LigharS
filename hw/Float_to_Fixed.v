`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/22/2021 12:57:26 AM
// Design Name: 
// Module Name: Float_to_Fixed
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


module Float_to_Fixed(
    input [31:0] float,
    output reg [63:0] fixed_point
    );
    
          
    reg sign;          //floating point sign
    reg [22:0] fl_m;       // floating point mantissa
    integer  index, exponent;
    reg [63:0] temp_fixed_point;
    
    initial begin
        fl_m = float[22:0]; //retrieves mantissa
        exponent = float[30:23] - 127; // retrieves exponent
        sign = float[31]; // retrieves sign
        temp_fixed_point = {1'b1, fl_m, 31'b0}; //puts it all together
        
        index = 64 - (exponent + 48); //find the shift
        
        if (index > 0) 
            temp_fixed_point = temp_fixed_point >> index;
        else
            temp_fixed_point = temp_fixed_point << -index;
        
        
        
    if(sign == 1) begin
        temp_fixed_point = -temp_fixed_point;
    end
    fixed_point = temp_fixed_point;
    end
endmodule
