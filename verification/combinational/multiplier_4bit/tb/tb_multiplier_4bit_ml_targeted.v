`timescale 1ns/1ps
module tb_multiplier_4bit_ml_targeted;
    reg  [3:0] A;
    reg  [3:0] B;
    wire [7:0] P;
    reg [7:0] exp_p;
    multiplier_4bit dut (.A(A), .B(B), .P(P));
    integer i, fh;
    integer pass_count = 0, fail_count = 0;
    reg [255:0] cov_bin;
    initial begin
        fh = $fopen("verification/combinational/multiplier_4bit/data/results_ml_targeted.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,pass,coverage_bin\n");
        // Candidate 175
        A = 13;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,175,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 0
        A = 0;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,0,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 203
        A = 14;
        B = 15;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,203,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 204
        A = 15;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,204,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 1
        A = 0;
        B = 1;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,1,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 176
        A = 13;
        B = 1;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,176,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 218
        A = 15;
        B = 15;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,218,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 163
        A = 12;
        B = 1;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,163,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 15
        A = 1;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,15,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 68
        A = 5;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,68,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 54
        A = 4;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,54,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 110
        A = 8;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,110,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 95
        A = 7;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,95,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 42
        A = 3;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,42,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 81
        A = 6;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,81,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 28
        A = 2;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,28,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 137
        A = 10;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,137,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 125
        A = 9;
        B = 0;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,125,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 3
        A = 0;
        B = 3;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,3,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 2
        A = 0;
        B = 2;
        #1;
        exp_p = A * B;
        if (P === exp_p) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (exp_p == 0) cov_bin = "prod_zero";
        else if (exp_p == 225) cov_bin = "prod_max";
        else if (exp_p == 1) cov_bin = "prod_one";
        else if (exp_p <= 50) cov_bin = "prod_low";
        else if (exp_p <= 150) cov_bin = "prod_mid";
        else cov_bin = "prod_high";
        $fwrite(fh, "multiplier_4bit,combinational,ml_targeted,999,2,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        $fclose(fh);
        $display("[TARGETED SIM COMPLETE] multiplier_4bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule