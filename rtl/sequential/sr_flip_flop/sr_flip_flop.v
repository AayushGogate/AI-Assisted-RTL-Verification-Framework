module sr_flip_flop (
    input S,
    input R,
    input clk,
    input reset,
    output reg Q
);

    always @(posedge clk or posedge reset) begin
        if (reset)
            Q <= 1'b0;
        else begin
            case ({S, R})
                2'b00: Q <= Q;
                2'b01: Q <= 1'b0;
                2'b10: Q <= 1'b1;
                2'b11: Q <= 1'bx;
            endcase
        end
    end

endmodule