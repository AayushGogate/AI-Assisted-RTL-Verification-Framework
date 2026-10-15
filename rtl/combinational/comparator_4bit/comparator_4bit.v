// 4-bit Comparator Specification:
// Compares 4-bit unsigned inputs A and B. Asserts gt, eq, or lt.
`timescale 1ns/1ps
module comparator_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire       gt,
    output wire       eq,
    output wire       lt
);
    assign gt = (A > B);
    assign eq = (A == B);
    assign lt = (A < B);
endmodule
