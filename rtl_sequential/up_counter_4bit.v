`timescale 1ns/1ps

module up_counter_4bit (
    input clk,
    input reset,
    output reg [3:0] Q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 4'b0000;
        else
            Q <= Q + 1'b1;
    end

endmodule