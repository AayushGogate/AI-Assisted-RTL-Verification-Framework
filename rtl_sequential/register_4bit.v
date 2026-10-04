`timescale 1ns/1ps

module register_4bit (
    input [3:0] D,
    input clk,
    input reset,
    output reg [3:0] Q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 4'b0000;
        else
            Q <= D;
    end

endmodule