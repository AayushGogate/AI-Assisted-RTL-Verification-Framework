// 4-to-2 Priority Encoder Specification:
// Active-high enable. in[3] has highest priority, in[0] lowest.
// Valid is asserted when at least one input bit is active.
`timescale 1ns/1ps
module priority_encoder_4to2 (
    input  wire       enable,
    input  wire [3:0] in,
    output reg  [1:0] code,
    output reg        valid
);
    always @(*) begin
        if (!enable) begin
            code  = 2'b00;
            valid = 1'b0;
        end else begin
            if (in[3]) begin
                code  = 2'b11;
                valid = 1'b1;
            end else if (in[2]) begin
                code  = 2'b10;
                valid = 1'b1;
            end else if (in[1]) begin
                code  = 2'b01;
                valid = 1'b1;
            end else if (in[0]) begin
                code  = 2'b00;
                valid = 1'b1;
            end else begin
                code  = 2'b00;
                valid = 1'b0;
            end
        end
    end
endmodule
