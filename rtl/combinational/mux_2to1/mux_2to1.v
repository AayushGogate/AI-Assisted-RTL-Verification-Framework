// 2-to-1 Multiplexer Specification:
// When S=0, X=A; when S=1, X=B.
`timescale 1ns/1ps
module mux_2to1 (
    input  wire A,
    input  wire B,
    input  wire S,
    output wire X
);
    assign X = (S == 1'b0) ? A : B;
endmodule
