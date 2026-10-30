/*
 * CompEng 361 - Lab 2
 * Public Practice Mutants (`public_mutants/public_mutants.v`)
 *
 * These two sample faulty ALU wrappers illustrate how hardware mutation
 * testing works locally against your `ExecutionUnit` and `test_vectors.csv`.
 *
 * Note: The autograder evaluates your `test_vectors.csv` against a separate
 * hidden suite of 20 faulty ALU mutants across all 10 RV32I operations.
 */

// Public Mutant A (SRA_logical):
// Fault: Ignores auxFunc on right shifts so SRA performs a logical shift (SRL)
//        instead of sign-extending.
module Public_Mutant_A(
    output [31:0] out,
    input  [31:0] opA,
    input  [31:0] opB,
    input  [2:0]  func,
    input  [6:0]  auxFunc
);
    wire [6:0] mutated_aux = (func == 3'b101 && auxFunc == 7'h20) ? 7'h00 : auxFunc;

    ExecutionUnit u_student(
        .out(out),
        .opA(opA),
        .opB(opB),
        .func(func),
        .auxFunc(mutated_aux)
    );
endmodule

// Public Mutant B (ADD_sub):
// Fault: Subtracts (opA - opB) instead of adding when executing ADD.
module Public_Mutant_B(
    output [31:0] out,
    input  [31:0] opA,
    input  [31:0] opB,
    input  [2:0]  func,
    input  [6:0]  auxFunc
);
    wire [31:0] student_out;

    ExecutionUnit u_student(
        .out(student_out),
        .opA(opA),
        .opB(opB),
        .func(func),
        .auxFunc(auxFunc)
    );

    assign out = (func == 3'b000 && auxFunc == 7'h00) ? (opA - opB) : student_out;
endmodule
