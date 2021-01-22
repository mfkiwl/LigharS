`timescale 1ns/1ps

module IntegerDecorator (
  input en,
  input [1:0] deco,
  input [31:0] data,
  output [31:0] res
);
  always @(*) begin
    if (en) begin
      case (deco)
        2'b00: res <= data;
        2'b01: res <= -data;             // Negate.
        2'b10: res <= data != 0;         // Saturate.
        2'b11: res <= { 0, data[30:0] }; // Absolute.
      endcase
    end
  end
endmodule

module FloatDecorator(
  input en,
  input [1:0] deco,
  input [31:0] data,
  output [31:0] res
);
  always @(*) begin
    if (en) begin
      // TODO: Floating point decorations here.
    end
  end
endmodule


module OperandDecorator(
  input int_float,
  input [1:0] deco,
  input [31:0] data,
  // Decorated data output.
  output [31:0] res,
); begin
  // -- Control variables.
  wire [31:0] int_res;
  wire [31:0] float_res;

  // -- Modules.
  IntegerDecorator int_deco(
    .en(!int_float),
    .deco(deco),
    .data(data),
    .res(int_res),
  );
  FloatDecorator float_deco(
    .en(int_float),
    .deco(deco),
    .data(data),
    .res(float_res),
  );

  // -- Behaviors.
  assign res = int_float ? float_res : int_res;

endmodule