// 1-bit Full Adder Specification:
// S = A ^ B ^ Cin, Cout = (A & B) | (B & Cin) | (A & Cin).
`timescale 1ns/1ps
module full_adder (
    input  wire A,
    input  wire B,
    input  wire Cin,
    output wire S,
    output wire Cout
);
    assign S    = A ^ B ^ Cin;
    assign Cout = (A & B) | (B & Cin) | (A & Cin);
endmodule
