// Template for Northwestern - CompEng 361 - Lab3 -- Version 1.1
// Groupname: Group 22
// NetIDs: qja7398, ouo5950

// Some useful defines...please add your own
`define WORD_WIDTH 32
`define NUM_REGS 32
`define OPCODE_COMPUTE    7'b0110011
`define OPCODE_BRANCH     7'b1100011
`define OPCODE_JAL  7'b1101111
`define OPCODE_JALR 7'b1100111
`define OPCODE_LOAD       7'b0000011
`define OPCODE_STORE      7'b0100011 
`define FUNC_ADD      3'b000
`define AUX_FUNC_ADD  7'b0000000
`define AUX_FUNC_SUB  7'b0100000
`define SIZE_BYTE  2'b00
`define SIZE_HWORD 2'b01
`define SIZE_WORD  2'b10
`define OPCODE_ICOMPUTE 7'b0010011

module SingleCycleCPU(halt, clk, rst);
   output halt;
   input clk, rst;

   wire [`WORD_WIDTH-1:0] PC, InstWord;
   wire [`WORD_WIDTH-1:0] DataAddr, StoreData, DataWord;
   wire [1:0]  MemSize;
   wire        MemWrEn;
   
   wire [4:0]  Rsrc1, Rsrc2, Rdst;
   wire [`WORD_WIDTH-1:0] Rdata1, Rdata2, RWrdata;
   wire        RWrEn;

   wire [`WORD_WIDTH-1:0] NPC, PC_Plus_4;
   wire [6:0]  opcode;

   wire [6:0]  funct7;
   wire [2:0]  funct3;

   wire invalid_op;
   
   wire [`WORD_WIDTH-1:0] load_val;

   wire [`WORD_WIDTH-1:0] imm_I, imm_S, imm_B, imm_U, imm_J;
   wire [`WORD_WIDTH-1:0] opB_val;

   wire [`WORD_WIDTH-1:0] EU_out;

   wire branch_taken;

   wire is_r, is_i, is_br, is_ld, is_st, is_jal, is_jalr;
   wire mem_misaligned, fetch_misaligned;
   
   assign halt = invalid_op || mem_misaligned || fetch_misaligned;
   assign invalid_op = !( (is_r  && r_ok)  || (is_i  && i_ok)  || (is_br && br_ok) ||
                          (is_ld && ld_ok) || (is_st && st_ok) || is_jal ||
                          (is_jalr && jalr_ok) );
   // Opcodes
   assign is_r     = (opcode == `OPCODE_COMPUTE);
   assign is_i     = (opcode == `OPCODE_ICOMPUTE);
   assign is_br    = (opcode == `OPCODE_BRANCH);
   assign is_ld    = (opcode == `OPCODE_LOAD);
   assign is_st    = (opcode == `OPCODE_STORE);
   assign is_jal   = (opcode == `OPCODE_JAL);
   assign is_jalr  = (opcode == `OPCODE_JALR);

   // System State 
   Mem   MEM(.InstAddr(PC), .InstOut(InstWord), 
            .DataAddr(DataAddr), .DataSize(MemSize), .DataIn(StoreData), .DataOut(DataWord), .WE(MemWrEn), .CLK(clk));

   RegFile RF(.AddrA(Rsrc1), .DataOutA(Rdata1), 
	      .AddrB(Rsrc2), .DataOutB(Rdata2), 
	      .AddrW(Rdst), .DataInW(RWrdata), .WenW(RWrEn), .CLK(clk));

   Reg PC_REG(.Din(NPC), .Qout(PC), .WE(1'b1), .CLK(clk), .RST(rst));

   // Instruction Decode
   assign opcode = InstWord[6:0];   
   assign Rdst = InstWord[11:7]; 
   assign Rsrc1 = InstWord[19:15]; 
   assign Rsrc2 = InstWord[24:20];
   assign funct3 = InstWord[14:12];  // R-Type, I-Type, S-Type
   assign funct7 = InstWord[31:25];  // R-Type

   assign MemWrEn = (opcode == `OPCODE_STORE) && !halt;
   assign RWrEn = ((opcode == `OPCODE_COMPUTE) || (opcode == `OPCODE_ICOMPUTE) ||
                (opcode == `OPCODE_LOAD)    || (opcode == `OPCODE_JAL)      ||
                (opcode == `OPCODE_JALR)) && !halt;

   // Immediate Decode
   assign imm_I = {{20{InstWord[31]}},InstWord[31:20]}; // sign-extend to 32 bits
   assign imm_S = {{20{InstWord[31]}}, InstWord[31:25], InstWord[11:7]};
   assign imm_B = {{20{InstWord[31]}}, InstWord[7], InstWord[30:25], InstWord[11:8], 1'b0};
   assign imm_J = {{12{InstWord[31]}}, InstWord[19:12], InstWord[20], InstWord[30:21], 1'b0};


   // Memory access
   assign DataAddr = (opcode == `OPCODE_STORE) ? Rdata1 + imm_S : Rdata1 + imm_I;
   assign StoreData = Rdata2;

   assign load_val = (funct3 == 3'h0) ? {{24{DataWord[7]}}, DataWord[7:0]} :
                     (funct3 == 3'h1) ? {{16{DataWord[15]}}, DataWord[15:0]} :
                     (funct3 == 3'h2) ? (DataWord[31:0]) :
                     (funct3 == 3'h4) ? {24'b0, DataWord[7:0]} :
                     (funct3 == 3'h5) ? {16'b0, DataWord[15:0]} : 32'b0;

   assign RWrdata = (opcode == `OPCODE_LOAD) ? load_val : 
                     (opcode == `OPCODE_JAL || opcode == `OPCODE_JALR) ? PC_Plus_4 :
                     EU_out;

   // Halt checks
   assign mem_misaligned = ((opcode == `OPCODE_LOAD) || (opcode == `OPCODE_STORE)) &&
                           ((MemSize == `SIZE_WORD) && DataAddr[1:0] != 2'b00 ||
                            (MemSize == `SIZE_HWORD && DataAddr[0] != 1'b0));

   assign fetch_misaligned = (NPC[1:0] != 2'b00);


   assign r_ok    = (funct7 == 7'b0000000) ||
                    (funct7 == 7'b0100000 && (funct3 == 3'b000 || funct3 == 3'b101));
   assign i_ok    = (funct3 == 3'b001) ? (funct7 == 7'b0000000) :
                    (funct3 == 3'b101) ? (funct7 == 7'b0000000 || funct7 == 7'b0100000) :
                    1'b1;
   assign br_ok   = (funct3 != 3'b010) && (funct3 != 3'b011);
   assign ld_ok   = (funct3 == 3'b000) || (funct3 == 3'b001) || (funct3 == 3'b010) ||
                    (funct3 == 3'b100) || (funct3 == 3'b101);
   assign st_ok   = (funct3 == 3'b000) || (funct3 == 3'b001) || (funct3 == 3'b010);
   assign jalr_ok = (funct3 == 3'b000);


   // Branch logic
   assign branch_taken = (funct3 == 3'h0) ? (Rdata1 == Rdata2) :
                         (funct3 == 3'h1) ? (Rdata1 != Rdata2) :
                         (funct3 == 3'h4) ? ($signed(Rdata1) < $signed(Rdata2)) :
                         (funct3 == 3'h5) ? ($signed(Rdata1) >= $signed(Rdata2)) :
                         (funct3 == 3'h6) ? (Rdata1 < Rdata2) :
                         (funct3 == 3'h7) ? (Rdata1 >= Rdata2) : 1'b0;
   
   assign MemSize = funct3[1:0];
   
   // opB select
   assign opB_val = (opcode == `OPCODE_ICOMPUTE) ? imm_I : Rdata2;

   // Hardwired to support R-Type instructions -- please add muxes and other control signals
   ExecutionUnit EU(.out(EU_out), .opA(Rdata1), .opB(opB_val), .func(funct3), .auxFunc((opcode == `OPCODE_COMPUTE) ||
         (opcode == `OPCODE_ICOMPUTE && funct3 == 3'b101) ? funct7 : 7'b0));


   // Fetch Address Datapath
   assign PC_Plus_4 = PC + 4;
   assign NPC = (opcode == `OPCODE_BRANCH && branch_taken) ? (PC + imm_B) :
                (opcode == `OPCODE_JAL) ? (PC + imm_J) :
                (opcode == `OPCODE_JALR && funct3 == 3'h0) ? ((Rdata1 + imm_I) & ~32'b1) : 
                 PC_Plus_4;

   
endmodule // SingleCycleCPU


// Execution Unit
module ExecutionUnit(
  output [31:0] out,
  input [31:0]  opA,
  input [31:0]  opB,
  input [2:0]   func,
  input [6:0]   auxFunc
  );

  wire [31:0] res_add; // result of add operation
  wire [31:0] res_sub;
  wire [31:0] res_sll; // logical left shift
  wire [31:0] res_slt; // signed less than
  wire [31:0] res_sltu;
  wire [31:0] res_xor;
  wire [31:0] res_srl;
  wire [31:0] res_sra;
  wire [31:0] res_or;
  wire [31:0] res_and;

  assign res_add  = opA + opB;
  assign res_sub  = opA - opB;
  assign res_sll  = opA << opB[4:0];
  assign res_slt  = ($signed(opA) < $signed(opB));
  assign res_sltu = opA < opB;
  assign res_xor = opA ^ opB;
  assign res_srl = opA >> opB[4:0];
  assign res_sra = $signed(opA) >>> opB[4:0];
  assign res_or = opA | opB;
  assign res_and = opA & opB;

  assign out = (func == 3'b000) ? ((auxFunc[5]) ? res_sub : res_add) :
               (func == 3'b001) ? res_sll :
               (func == 3'b010) ? res_slt :
               (func == 3'b011) ? res_sltu :
               (func == 3'b100) ? res_xor :
               (func == 3'b101) ? ((auxFunc[5]) ? res_sra : res_srl) :
               (func == 3'b110) ? res_or : res_and;



endmodule // ExecutionUnit
