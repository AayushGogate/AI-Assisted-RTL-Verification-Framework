`timescale 1ns/1ps

module down_counter_4bit (
    input clk,
    input reset,
    output reg [3:0] Q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 4'b1111;
        else
            Q <= Q - 1'b1;
    end

endmodule