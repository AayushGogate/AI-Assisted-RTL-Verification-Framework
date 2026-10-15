module mux2to1(
    input A, B, S,
    output X
);

assign X = (A & ~S) | (B & S);

endmodule