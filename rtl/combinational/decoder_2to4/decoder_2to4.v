// 2-to-4 Decoder Specification:
// When enable=1, decodes 2-bit input into 4-bit one-hot output. When enable=0, out=0.
`timescale 1ns/1ps
module decoder_2to4 (
    input  wire       enable,
    input  wire [1:0] in,
    output wire [3:0] out
);
    assign out = enable ? (4'b0001 << in) : 4'b0000;
endmodule
