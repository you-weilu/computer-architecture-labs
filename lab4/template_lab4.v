// Template for Northwestern - CompEng 361 - Lab4
// Groupname:
// NetIDs:
// Compile: iverilog -o pipeline template_lab4.v lab4_tb.v

// Some useful defines...please add your own
`define WORD_WIDTH 32
`define NUM_REGS 32
`define OPCODE_COMPUTE    7'b0110011
`define OPCODE_IMM        7'b0010011
`define OPCODE_BRANCH     7'b1100011
`define OPCODE_LOAD       7'b0000011
`define OPCODE_STORE      7'b0100011
`define NOP_INST          32'h00000013
`define FUNC_ADD          3'b000
`define AUX_FUNC_ADD      7'b0000000
`define AUX_FUNC_SUB      7'b0100000
`define SIZE_BYTE         2'b00
`define SIZE_HWORD        2'b01
`define SIZE_WORD         2'b10

module PipelinedCPU(halt, clk, rst);
   output halt;
   input  clk, rst;

   // -----------------------------------------------------------------------
   // Pipeline Stall / Squash Control Wires
   //
   // IMPORTANT PIPELINE RULES:
   // 1. MEM and WB NEVER stall. A global pipeline freeze on a load-use
   //    hazard is NOT allowed: on a load-use hazard, only IF and ID hold
   //    (stall_if = 1, stall_id = 1) and a bubble is inserted into ID/EX
   //    (squash_id_ex = 1), while EX/MEM and MEM/WB continue advancing.
   // 2. PipeReg resets/squashes to its `init` parameter, and an all-zero
   //    instruction word/opcode (0x00000000) decodes as illegal in RV32I.
   //    Instruction-word fields in pipeline registers reset to NOP
   //    (32'h00000013 = addi x0, x0, 0), and all fault/halt detection MUST
   //    be gated by the stage's `valid` bit (e.g., `wb_valid && wb_invalid_op`)
   //    so pipeline bubbles (valid == 0) never trigger a false halt.
   //
   // TODO: Replace these tied-off 1'b0 wires with your hazard detection,
   //       branch/jump flush, and precise-exception squash logic.
   // -----------------------------------------------------------------------
   wire stall_if      = 1'b0; // TODO: stall PC update on load-use hazard
   wire stall_id      = 1'b0; // TODO: hold IF/ID on load-use hazard
   wire squash_if_id  = 1'b0; // TODO: flush IF/ID on taken branch/jump
   wire stall_ex      = 1'b0; // TODO: keep 1'b0 (EX does not stall in standard RV32I)
   wire squash_id_ex  = 1'b0; // TODO: insert bubble into ID/EX on load-use hazard or branch flush
   wire squash_ex_mem = 1'b0; // TODO: squash EX/MEM on exception if needed
   wire squash_mem_wb = 1'b0; // TODO: squash MEM/WB on exception if needed

   // -----------------------------------------------------------------------
   // Stage 1: Instruction Fetch (IF)
   // -----------------------------------------------------------------------
   wire [`WORD_WIDTH-1:0] if_pc, if_npc, if_pc_plus_4, if_inst;
   wire                   if_valid;

   assign if_valid     = 1'b1;
   assign if_pc_plus_4 = if_pc + 32'd4;
   assign if_npc       = if_pc_plus_4; // TODO: mux in branch/jump targets

   Reg #(.width(`WORD_WIDTH), .init(32'h00000000)) PC_REG (
      .Din(if_npc), .Qout(if_pc), .WE(~stall_if), .CLK(clk), .RST(rst)
   );

   // IF/ID Pipeline Register: valid resets to 0, PC resets to 0, inst resets to NOP (32'h00000013)
   wire                   id_valid;
   wire [`WORD_WIDTH-1:0] id_pc, id_inst;

   PipeReg #(.width(1 + `WORD_WIDTH + `WORD_WIDTH), .init({1'b0, 32'h00000000, `NOP_INST})) IF_ID (
      .Din({if_valid, if_pc, if_inst}),
      .Qout({id_valid, id_pc, id_inst}),
      .WE(~stall_id),
      .Squash(squash_if_id),
      .CLK(clk),
      .RST(rst)
   );

   // -----------------------------------------------------------------------
   // Stage 2: Instruction Decode & Register File Read (ID)
   // -----------------------------------------------------------------------
   wire [6:0]             id_opcode = id_inst[6:0];
   wire [4:0]             id_rd     = id_inst[11:7];
   wire [2:0]             id_funct3 = id_inst[14:12];
   wire [4:0]             id_rs1    = id_inst[19:15];
   wire [4:0]             id_rs2    = id_inst[24:20];
   wire [6:0]             id_funct7 = id_inst[31:25];
   wire [`WORD_WIDTH-1:0] id_imm_i  = {{20{id_inst[31]}}, id_inst[31:20]};

   wire [`WORD_WIDTH-1:0] id_rdata1, id_rdata2;

   // Baseline decode supports R-type ADD/SUB and NOP (addi x0, x0, 0 = 32'h00000013)
   // TODO: Extend decode and fault detection to full RV32I + alignment checks
   wire id_is_r_addsub = (id_opcode == `OPCODE_COMPUTE) && (id_funct3 == `FUNC_ADD) &&
                         ((id_funct7 == `AUX_FUNC_ADD) || (id_funct7 == `AUX_FUNC_SUB));
   wire id_is_nop      = (id_inst == `NOP_INST);
   wire id_reg_write   = id_is_r_addsub;
   wire id_use_imm     = id_is_nop;

   // ID/EX Pipeline Register
   wire                   ex_valid;
   wire [`WORD_WIDTH-1:0] ex_pc, ex_rdata1, ex_rdata2, ex_imm_i;
   wire [6:0]             ex_opcode;
   wire [4:0]             ex_rd;
   wire [2:0]             ex_funct3;
   wire [6:0]             ex_funct7;
   wire                   ex_reg_write, ex_use_imm;

   PipeReg #(.width(1 + 32 + 32 + 32 + 32 + 7 + 5 + 3 + 7 + 2), .init(153'd0)) ID_EX (
      .Din({id_valid, id_pc, id_rdata1, id_rdata2, id_imm_i, id_opcode, id_rd, id_funct3, id_funct7,
            id_reg_write, id_use_imm}),
      .Qout({ex_valid, ex_pc, ex_rdata1, ex_rdata2, ex_imm_i, ex_opcode, ex_rd, ex_funct3, ex_funct7,
             ex_reg_write, ex_use_imm}),
      .WE(~stall_ex),
      .Squash(squash_id_ex),
      .CLK(clk),
      .RST(rst)
   );

   // -----------------------------------------------------------------------
   // Stage 3: Execute (EX)
   // -----------------------------------------------------------------------
   // TODO: Add EX/MEM and MEM/WB forwarding muxes for ex_opA and ex_opB
   wire [`WORD_WIDTH-1:0] ex_opA      = ex_rdata1;
   wire [`WORD_WIDTH-1:0] ex_opB      = ex_use_imm ? ex_imm_i : ex_rdata2;
   wire [6:0]             ex_aux_func = ex_use_imm ? `AUX_FUNC_ADD : ex_funct7;
   wire [`WORD_WIDTH-1:0] ex_alu_out;

   ExecutionUnit EU (
      .out(ex_alu_out),
      .opA(ex_opA),
      .opB(ex_opB),
      .func(ex_funct3),
      .auxFunc(ex_aux_func)
   );

   // EX/MEM Pipeline Register (MEM never stalls: WE is tied to 1'b1)
   wire                   mem_valid;
   wire [`WORD_WIDTH-1:0] mem_pc, mem_alu_out, mem_store_data;
   wire [6:0]             mem_opcode;
   wire [4:0]             mem_rd;
   wire [2:0]             mem_funct3;
   wire [6:0]             mem_funct7;
   wire                   mem_reg_write;

   PipeReg #(.width(1 + 32 + 32 + 32 + 7 + 5 + 3 + 7 + 1), .init(120'd0)) EX_MEM (
      .Din({ex_valid, ex_pc, ex_alu_out, ex_rdata2, ex_opcode, ex_rd, ex_funct3, ex_funct7, ex_reg_write}),
      .Qout({mem_valid, mem_pc, mem_alu_out, mem_store_data, mem_opcode, mem_rd, mem_funct3, mem_funct7, mem_reg_write}),
      .WE(1'b1),
      .Squash(squash_ex_mem),
      .CLK(clk),
      .RST(rst)
   );

   // -----------------------------------------------------------------------
   // Stage 4: Memory (MEM)
   // -----------------------------------------------------------------------
   wire [`WORD_WIDTH-1:0] DataAddr  = mem_alu_out;
   wire [`WORD_WIDTH-1:0] StoreData = mem_store_data;
   wire [`WORD_WIDTH-1:0] DataWord;
   wire [1:0]             MemSize   = `SIZE_WORD;
   wire                   MemWrEn   = 1'b0; // TODO: Enable for valid stores when not halting/faulting

   // MEM/WB Pipeline Register (WB never stalls: WE is tied to 1'b1)
   wire                   wb_valid;
   wire [`WORD_WIDTH-1:0] wb_pc, wb_result;
   wire [6:0]             wb_opcode;
   wire [4:0]             wb_rd;
   wire [2:0]             wb_funct3;
   wire [6:0]             wb_funct7;
   wire                   wb_reg_write;

   PipeReg #(.width(1 + 32 + 32 + 7 + 5 + 3 + 7 + 1), .init(88'd0)) MEM_WB (
      .Din({mem_valid, mem_pc, mem_alu_out, mem_opcode, mem_rd, mem_funct3, mem_funct7, mem_reg_write}),
      .Qout({wb_valid, wb_pc, wb_result, wb_opcode, wb_rd, wb_funct3, wb_funct7, wb_reg_write}),
      .WE(1'b1),
      .Squash(squash_mem_wb),
      .CLK(clk),
      .RST(rst)
   );

   // -----------------------------------------------------------------------
   // Stage 5: Writeback (WB) & Retirement
   // -----------------------------------------------------------------------
   wire wb_is_r_addsub = (wb_opcode == `OPCODE_COMPUTE) && (wb_funct3 == `FUNC_ADD) &&
                         ((wb_funct7 == `AUX_FUNC_ADD) || (wb_funct7 == `AUX_FUNC_SUB));
   wire wb_is_nop      = (wb_opcode == `OPCODE_IMM) && (wb_funct3 == `FUNC_ADD) && (wb_rd == 5'd0);
   wire wb_invalid_op  = !(wb_is_r_addsub || wb_is_nop);

   // NOTE: Fault detection MUST be gated by wb_valid so reset/flushed bubbles
   //       (where wb_valid == 0 and wb_opcode == 7'b0000000) do not halt!
   assign halt = wb_valid && wb_invalid_op;

   wire                   wb_rf_wen   = wb_valid && wb_reg_write && !halt;
   wire [4:0]             wb_rf_addr  = wb_rd;
   wire [`WORD_WIDTH-1:0] wb_rf_wdata = wb_result;

   // Required architectural state & retirement instances
   Mem MEM (
      .InstAddr(if_pc),
      .InstOut(if_inst),
      .DataAddr(DataAddr),
      .DataSize(MemSize),
      .DataIn(StoreData),
      .DataOut(DataWord),
      .WE(MemWrEn),
      .CLK(clk)
   );

   RegFile RF (
      .AddrA(id_rs1),
      .DataOutA(id_rdata1),
      .AddrB(id_rs2),
      .DataOutB(id_rdata2),
      .AddrW(wb_rf_addr),
      .DataInW(wb_rf_wdata),
      .WenW(wb_rf_wen),
      .CLK(clk)
   );

   Retire RETIRE (
      .Valid(wb_valid),
      .PC(wb_pc)
   );

endmodule // PipelinedCPU


// Incomplete version of Lab2 execution unit
// You will need to extend it. Feel free to modify the interface also
module ExecutionUnit(out, opA, opB, func, auxFunc);
   output [`WORD_WIDTH-1:0] out;
   input  [`WORD_WIDTH-1:0] opA, opB;
   input  [2:0]             func;
   input  [6:0]             auxFunc;

   wire [`WORD_WIDTH-1:0] addSub;

   // Only supports add and subtract
   assign addSub = (auxFunc == 7'b0100000) ? (opA - opB) : (opA + opB);
   assign out    = (func == 3'b000) ? addSub : 32'hXXXXXXXX;

endmodule // ExecutionUnit
