module demux_1to4(
    input wire in,
    input wire [1:0] sel,
    output wire [3:0] out
);

assign out[0] = in & ~sel[1] & ~sel[0];
assign out[1] = in & ~sel[1] &  sel[0];
assign out[2] = in &  sel[1] & ~sel[0];
assign out[3] = in &  sel[1] &  sel[0];

endmodule