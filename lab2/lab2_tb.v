/*
  
  Northwestern University
  CompEng361
  Lab 2 Testbench
 
  Drives ExecutionUnit using stimulus generated from `test_vectors.csv`
  via `csv_to_tb.py` (`tb_stimulus.vh`).

  DO NOT TURN THIS FILE IN!!!!
  
  */

`define WIDTH 32
`define FWIDTH 3
`define AFWIDTH 7
`define STEP 10

module testbench();
   reg [`WIDTH-1:0]  opA;
   reg [`WIDTH-1:0]  opB;
   wire [`WIDTH-1:0] result;

   reg [`FWIDTH-1:0]  func;
   reg [`AFWIDTH-1:0] auxFunc;
   reg [8*4-1:0]      op_name;
   integer            vec_num;

   ExecutionUnit EU( .out(result),
		     .opA(opA),
		     .opB(opB),
		     .func(func),
		     .auxFunc(auxFunc));

   initial begin
      $dumpfile("lab2.vcd");
      $dumpvars(0, testbench);

      $display("======================================================================");
      $display(" Vec# | Op   | func | auxFunc |    opA     |    opB     |    out     ");
      $display("----------------------------------------------------------------------");

      // Stimulus generated from test_vectors.csv by csv_to_tb.py
      `include "tb_stimulus.vh"

      $display("======================================================================");
      $finish;
   end

   task doExecute(input integer idx,
		  input [8*4-1:0] mnemonic,
		  input [`FWIDTH-1:0] f, 
		  input [`AFWIDTH-1:0] af, 
		  input [`WIDTH-1:0] a, 
		  input [`WIDTH-1:0] b);
      begin
         vec_num = idx;
         op_name = mnemonic;
         func = f;
         auxFunc = af;
         opA = a;
         opB = b;
         #`STEP;
         $display(" %4d | %4s | %03b  | %07b | 0x%08x | 0x%08x | 0x%08x",
                  vec_num, op_name, func, auxFunc, opA, opB, result);
      end
   endtask

endmodule // testbench
