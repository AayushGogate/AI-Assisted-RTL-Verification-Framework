// 4-bit Adder Specification:
// Computes 4-bit sum and carry-out from 4-bit A, 4-bit B, and Cin.
`timescale 1ns/1ps
module adder_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       Cin,
    output wire [3:0] S,
    output wire       Cout
);
    wire c1, c2, c3;
    assign S[0] = A[0] ^ B[0] ^ Cin;
    assign c1   = (A[0] & B[0]) | (B[0] & Cin) | (A[0] & Cin);

    assign S[1] = A[1] ^ B[1] ^ c1;
    assign c2   = (A[1] & B[1]) | (B[1] & c1) | (A[1] & c1);

    assign S[2] = A[2] ^ B[2] ^ c2;
    assign c3   = (A[2] & B[2]) | (B[2] & c2) | (A[2] & c2);

    assign S[3] = A[3] ^ B[3] ^ c3;
    assign Cout = (A[3] & B[3]) | (B[3] & c3) | (A[3] & c3);
endmodule
