`timescale 1ns/1ps

module tb_adder_4bit_ml_targeted;

    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] S;
    wire       Cout;

    integer i;
    integer pass_count = 0;
    integer fail_count = 0;
    reg [4:0] expected;

    integer fh;

    // The 10 candidate inputs the ML model picked from the untested 340
    // combinations, ranked by predicted closeness to sum=0 and sum=31.
    reg [3:0] cand_A [0:9];
    reg [3:0] cand_B [0:9];
    reg       cand_Cin [0:9];

    adder_4bit DUT (
        .A(A), .B(B), .Cin(Cin),
        .S(S), .Cout(Cout)
    );

    initial begin
        cand_A[0]=4'd0;  cand_B[0]=4'd0;  cand_Cin[0]=1'b0;
        cand_A[1]=4'd0;  cand_B[1]=4'd1;  cand_Cin[1]=1'b1;
        cand_A[2]=4'd0;  cand_B[2]=4'd0;  cand_Cin[2]=1'b1;
        cand_A[3]=4'd1;  cand_B[3]=4'd0;  cand_Cin[3]=1'b0;
        cand_A[4]=4'd0;  cand_B[4]=4'd2;  cand_Cin[4]=1'b0;
        cand_A[5]=4'd15; cand_B[5]=4'd15; cand_Cin[5]=1'b1;
        cand_A[6]=4'd15; cand_B[6]=4'd15; cand_Cin[6]=1'b0;
        cand_A[7]=4'd15; cand_B[7]=4'd14; cand_Cin[7]=1'b0;
        cand_A[8]=4'd14; cand_B[8]=4'd15; cand_Cin[8]=1'b1;
        cand_A[9]=4'd14; cand_B[9]=4'd14; cand_Cin[9]=1'b1;

        $display("Running ML-targeted directed testbench on REAL adder_4bit.v RTL");
        $display("----------------------------------------");

        fh = $fopen("verification/4bit_adder/data/results.csv", "w");
        $fwrite(fh, "test_num,A,B,Cin,S,Cout,expected,pass,hits_zero,hits_max\n");

        for (i = 0; i < 10; i = i + 1) begin
            A   = cand_A[i];
            B   = cand_B[i];
            Cin = cand_Cin[i];
            #1;

            expected = A + B + Cin;

            if ({Cout, S} !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] A=%0d B=%0d Cin=%b -> S=%0d Cout=%b (expected %0d)",
                          A, B, Cin, S, Cout, expected);
            end else begin
                pass_count = pass_count + 1;
                $display("[PASS] A=%0d B=%0d Cin=%b -> S=%0d Cout=%b sum=%0d %s",
                          A, B, Cin, S, Cout, expected,
                          (expected==0) ? "<-- HITS sum=0 (was missing in CRV)" :
                          (expected==31)? "<-- HITS sum=31 (was missing in CRV)" : "");
            end

            $fwrite(fh, "%0d,%0d,%0d,%b,%0d,%b,%0d,%0d,%0d,%0d\n",
                     i, A, B, Cin, S, Cout, expected,
                     ({Cout,S} === expected), (expected==0), (expected==31));
        end

        $fclose(fh);

        $display("----------------------------------------");
        $display("PASS: %0d  FAIL: %0d (out of 10 directed RTL simulations)", pass_count, fail_count);
        $display("----------------------------------------");

        $finish;
    end

endmodule