module StageRegister #(parameter WIDTH = 1) (
  input clk, reset,
  input [WIDTH - 1:0] d,
  output reg [WIDTH - 1:0] q
);

  always @(posedge clk or posedge reset) begin
    if (reset)
      q = 0;
    else
      q = d;
  end

endmodule

`define declr_stage_reg(width, prev_stage, next_stage, name) \
  StageRegister #(.WIDTH(width)) prev_stage``_``next_stage``_``name``_reg( \
    .clk(clk), .reset(reset), \
    .d(prev_stage``_``name), \
    .q(next_stage``_``name), \
  );

module Riscv(
  input clk,
  input reset,
);

// |          | branch_taken <- |              |            |
// |          |         jump <- |              |            |
// |IF        |ID               |EX            |MEM         |WB
// | -> pc    | -> pc           |              |            |
// | -> instr |                 |              |            |
// |          | -> alu_op       |              |            |
// |          | -> rd_addr      | -> rd_addr   | -> rd_addr |
// |          | -> rs1_data     |              |            |
// |          | -> rs2_data     | -> rs2_data  |            |
// |          | -> mem_read     | -> mem_read  |            |
// |          | -> mem_write    | -> mem_write |            |
// |          |                 | -> alu_res   |            |
// |          |                 |              | -> res     |




// -- RISC-V Datapath.

// IF stage.
  assign if_pc = pc;
  StageIF if_stage(
    .pc(pc),
    .instr(if_instr),
  );

  wire [31:0] if_pc;
  wire [31:0] if_instr;

  `declr_stage_reg(32, if, id, pc);
  `declr_stage_reg(32, if, id, instr);

// ID stage.
  wire [31:0] id_pc;
  wire [31:0] id_instr;

  StageID stage_id(
    .id_pc(),
  );

  wire [3:0] id_alu_op;
  wire [4:0] id_rd_addr;
  wire [31:0] id_rs1_data;
  wire [31:0] id_rs2_data;
  wire id_mem_read;
  wire id_mem_write;

  `declr_stage_reg(5, id, ex, rd_addr);
  `declr_stage_reg(32, id, ex, rs1_data);
  `declr_stage_reg(32, id, ex, rs2_data);
  `declr_stage_reg(1, id, ex, mem_read);
  `declr_stage_reg(1, id, ex, mem_write);

// EX stage.
  wire [3:0] ex_alu_op;
  wire [4:0] ex_rd_addr;
  wire [31:0] ex_rs1_data;
  wire [31:0] ex_rs2_data;
  wire ex_mem_read;
  wire ex_mem_write;

  wire [31:0] ex_alu_res;

  `declr_stage_reg(5, ex, mem, rd_addr);
  `declr_stage_reg(32, ex, mem, rs2_data);
  `declr_stage_reg(1, ex, mem, mem_read);
  `declr_stage_reg(1, ex, mem, mem_write);
  `declr_stage_reg(32, ex, mem, alu_res);

// MEM stage.
  wire [4:0] mem_rd_addr;
  wire [31:0] mem_rs2_data;
  wire mem_mem_read;
  wire mem_mem_write;
  wire [31:0] mem_alu_res;

  wire [31:0] mem_res;

  `declr_stage_reg(5, mem, wb, rd_addr);
  `declr_stage_reg(32, mem, wb, res);

// WB stage.
  wire [31:0] wb_rd_addr;
  wire [31:0] wb_res;



// -- Components used by the datapath.

//L2Cache icache_l1();
//L2Cache dcache();
ProgramCounter prog_counter();
Memory unified_mem();
Alu alu();
RegisterFile reg_file();
HazardDetector hazard_detector();

endmodule
