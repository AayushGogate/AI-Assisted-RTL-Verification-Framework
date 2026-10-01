module parity_2bit(
     input wire [1:0] A,
     input wire [1:0] B,
     output wire A_eq_B,
     output wire A_gt_b,
     output wire A_lt_B
);

wire bit1_eq = ~(A[1] ^ B[1]); // High if A1 == B1
wire bit0_eq = ~(A[0] ^ B[0]); // Hgh if A0 == B0

// Dataflow assignments using standard Boolean Logic Equations
assign A_eq_B = bit1_eq & bit0_eq;
assign A_gt_B = (A[1] & ~B[1]) | (bit1_eq & (A[0] & ~B[0]));
assign A_lt_B = (~A[1] & B[1]) | (bit1_eq & (~A[0] & B[0]));

endmodule