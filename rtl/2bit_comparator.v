module comparator_2bit(
    input A1, A0,
    input B1, B0,
    output A_greater_B,
    output A_equal_B,
    output A_less_B
);

assign A_greater_B = (A1 & ~B1) | ((A1 ~^ B1) & A0 & ~B0);

assign A_equal_B = (A1 ~^ B1) & (A0 ~^ B0);

assign A_less_B = (~A1 & B1) | ((A1 ~^ B1) & ~A0 & B0);

endmodule