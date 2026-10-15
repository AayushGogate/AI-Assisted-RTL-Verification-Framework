// 4-to-1 Multiplexer Specification:
// Inputs I0, I1, I2, I3 selected by 2-bit select lines S1, S0.
`timescale 1ns/1ps
module mux_4to2 (
    input  wire I0,
    input  wire I1,
    input  wire I2,
    input  wire I3,
    input  wire S1,
    input  wire S0,
    output wire Y
);
    assign Y = (S1 == 1'b0 && S0 == 1'b0) ? I0 :
               (S1 == 1'b0 && S0 == 1'b1) ? I1 :
               (S1 == 1'b1 && S0 == 1'b0) ? I2 : I3;
endmodule
