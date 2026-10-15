module encoder_8to3_dataflow (
    input  wire [7:0] in,    // 8-bit input data lines
    output wire [2:0] out,   // 3-bit priority encoded output
    output wire       valid  // Asserted high if at least one input bit is high
);

    // Reduction OR operator: valid is 1 if any bit in 'in' is set
    assign valid = |in;

    // Nested ternary operators evaluating from Bit 7 (highest priority) down to Bit 0
    assign out = in[7] ? 3'b111 :
                 in[6] ? 3'b110 :
                 in[5] ? 3'b101 :
                 in[4] ? 3'b100 :
                 in[3] ? 3'b011 :
                 in[2] ? 3'b010 :
                 in[1] ? 3'b001 : 3'b000;

endmodule