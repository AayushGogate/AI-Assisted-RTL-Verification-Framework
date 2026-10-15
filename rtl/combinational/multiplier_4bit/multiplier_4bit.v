// 4-bit Unsigned Multiplier Specification:
// Multiplies 4-bit inputs A and B to produce an 8-bit product P.
`timescale 1ns/1ps
module multiplier_4bit (
    input  wire [3:0] A,
    input  wire [3:0] B,
    output wire [7:0] P
);
    assign P = A * B;
endmodule
