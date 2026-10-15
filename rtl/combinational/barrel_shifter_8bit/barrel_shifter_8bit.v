// 8-bit Barrel Shifter (Rotator) Specification:
// Circularly rotates 8-bit data by amt positions. dir=0: rotate left; dir=1: rotate right.
`timescale 1ns/1ps
module barrel_shifter_8bit (
    input  wire [7:0] data,
    input  wire [2:0] amt,
    input  wire       dir,
    output reg  [7:0] out
);
    wire [15:0] double_left  = {data, data};
    wire [15:0] double_right = {data, data};

    always @(*) begin
        if (dir == 1'b0) begin
            // rotate left
            out = double_left[15 - amt -: 8];
        end else begin
            // rotate right
            out = double_right[amt +: 8];
        end
    end
endmodule
