`timescale 1ns/1ps

module shift_register_4bit (
    input clk,
    input reset,
    input serial_in,
    output reg [3:0] Q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 4'b0000;
        else
            Q <= {Q[2:0], serial_in};
    end

endmodule