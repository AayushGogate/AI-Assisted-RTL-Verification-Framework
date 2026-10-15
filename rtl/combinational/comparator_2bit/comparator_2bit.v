// 2-bit Comparator Specification:
// Compares 2-bit unsigned inputs A and B. Asserts A_gt_B, A_eq_B, or A_lt_B.
`timescale 1ns/1ps
module comparator_2bit (
    input  wire [1:0] A,
    input  wire [1:0] B,
    output wire       A_gt_B,
    output wire       A_eq_B,
    output wire       A_less_B
);
    assign A_gt_B   = (A > B);
    assign A_eq_B   = (A == B);
    assign A_less_B = (A < B);
endmodule
