module priority_encoder_4to2 (
    input  wire [3:0] in,     // 4-bit request/input lines
    output reg  [1:0] out,    // 2-bit encoded binary output
    output reg        valid   // Asserted high if at least one input is high
);

    always @(*) begin
        valid = 1'b1;
        casez (in)
            4'b1???: out = 2'b11; // Priority to bit 3 (highest)
            4'b01??: out = 2'b10; // Bit 2
            4'b001?: out = 2'b01; // Bit 1
            4'b0001: out = 2'b00; // Bit 0 (lowest)
            default: begin
                out   = 2'b00;
                valid = 1'b0;    // No input is active
            end
        endcase
    end

endmodule