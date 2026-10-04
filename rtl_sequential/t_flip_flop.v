`timescale 1ns/1ps

module t_flip_flop (
    input T,
    input clk,
    input reset,
    output reg Q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 1'b0;
        else if (T)
            Q <= ~Q;
        else
            Q <= Q;
    end

endmodule