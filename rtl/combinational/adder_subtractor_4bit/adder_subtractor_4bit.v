// 4-bit Adder/Subtractor Specification:
// When sub=0: Result = A + B. When sub=1: Result = A - B.
// Detects 2's complement signed overflow.
`timescale 1ns/1ps
module adder_subtractor_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    input  wire       sub,
    output wire [3:0] Result,
    output wire       Cout,
    output wire       Overflow
);
    wire [3:0] b_xor = B ^ {4{sub}};
    wire [4:0] full_sum = A + b_xor + sub;

    assign Result   = full_sum[3:0];
    assign Cout     = full_sum[4];
    assign Overflow = (A[3] == b_xor[3]) && (Result[3] != A[3]);
endmodule
