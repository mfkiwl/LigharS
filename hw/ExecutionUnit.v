module ExecutionUnit (
  input en,
  input clk,
  input [3:0] op,
  input operand0,
  input operand1,

  // Output of this execution unit.
  output [31:0] res,
);
  // -- Control variables.
  wire en_alu;
  wire en_fpu;

  wire [3:0] op_alu;
  wire [2:0] op_fpu;



  // -- Submodules.
  reg zero_alu;
  reg neg_alu;
  reg [31:0] res_alu;
  Alu alu(
    .en(en_alu),
    .clk(clk),
    .op(op_alu),
    .operand0(operand0),
    .operand1(operand1),
    .zero(zero),
    .neg(neg)
    .res(res_alu),
  );

  reg nan_fpu;
  reg [31:0] res_fpu;
  Fpu fpu(
    .en(en_fpu),
    .clk(clk),
    .op(op_fpu),
    .operand0(operand0),
    .operand1(operand1),
    .nan(nan_fpu)
    .res(res_fpu),
  );



  // -- Behaviors.
  assign en_alu = en & !op[3]; // 0XXX -> ALU
  assign en_fpu = en & op[3];  // 1XXX -> FPU

  assign op_alu = op[3:0];
  assign op_fpu = op[2:0];

  assign res = res_alu | res_fpu;

endmodule
