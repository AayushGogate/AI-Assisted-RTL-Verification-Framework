module adder_4bit(
    input [3:0] A,
    input [3:0] B,
    input Cin,
    output [3:0] S,
    output Cout
);

wire C1, C2, C3;

assign S[0] = A[0] ^ B[0] ^ Cin;
assign C1 = (A[0] & B[0]) | (B[0] & Cin) | (A[0] & Cin);

assign S[1] = A[1] ^ B[1] ^ C1;
assign C2 = (A[1] & B[1]) | (B[1] & C1) | (A[1] & C1);

assign S[2] = A[2] ^ B[2] ^ C2;
assign C3 = (A[2] & B[2]) | (B[2] & C2) | (A[2] & C2);

assign S[3] = A[3] ^ B[3] ^ C3;
assign Cout = (A[3] & B[3]) | (B[3] & C3) | (A[3] & C3);

endmodule