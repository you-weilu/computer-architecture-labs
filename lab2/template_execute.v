/*
  
  Northwestern University
  CompEng361 - Fall 2026
  Lab 2
  
  Name: You-wei (Terry) Lu, Daniel Antony
  NetID: qja7398, ouo5950
  
  */
  
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
