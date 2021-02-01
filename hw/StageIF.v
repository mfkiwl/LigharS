module StageIF(
  input en,
  input clk,
  input reset,
  input do_branch,
  input [31:0] branch_addr,
  input do_jump,
  input [31:0] jump_addr,
  output [31:0] pc_plus4,
);
  reg [31:0] pc;



  assign pc_plus4 = pc + 4;

  always @(posedge clk or posedge reset) begin
    if (reset)
      pc = 0;
    else
      pc = en ? (do_jump ? jump_addr : (do_branch ? branch_addr : pc_plus4)) : pc;
  end

endmodule
