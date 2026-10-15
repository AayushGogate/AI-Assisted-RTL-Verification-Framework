// 3-bit Binary to Gray Code Converter Specification:
// G[2] = B[2]; G[1] = B[2] ^ B[1]; G[0] = B[1] ^ B[0].
`timescale 1ns/1ps
module binary_to_gray_3bit (
    input  wire [2:0] B,
    output wire [2:0] G
);
    assign G[2] = B[2];
    assign G[1] = B[2] ^ B[1];
    assign G[0] = B[1] ^ B[0];
endmodule
