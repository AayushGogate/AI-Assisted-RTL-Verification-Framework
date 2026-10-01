module full_adder(
    input A, B, Cin,
    output Cout, S
);

assign S = A ^ B ^ Cin;
assign Cout = (A & B) | (B & Cin) | (A & Cin);

endmodule