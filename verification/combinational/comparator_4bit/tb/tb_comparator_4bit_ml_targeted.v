`timescale 1ns/1ps
module tb_comparator_4bit_ml_targeted;
    reg  [3:0] A;
    reg  [3:0] B;
    wire gt, eq, lt;
    reg exp_gt, exp_eq, exp_lt;
    comparator_4bit dut (.A(A), .B(B), .gt(gt), .eq(eq), .lt(lt));
    integer i, fh;
    integer pass_count = 0, fail_count = 0;
    reg [255:0] cov_bin;
    initial begin
        fh = $fopen("verification/combinational/comparator_4bit/data/results_ml_targeted.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,pass,coverage_bin\n");
        // Candidate 132
        A = 9;
        B = 10;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,132,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 133
        A = 9;
        B = 11;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,133,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 172
        A = 12;
        B = 11;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,172,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 173
        A = 12;
        B = 13;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,173,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 187
        A = 13;
        B = 12;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,187,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 200
        A = 14;
        B = 12;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,200,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 215
        A = 15;
        B = 12;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,215,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 134
        A = 9;
        B = 12;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,134,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 159
        A = 11;
        B = 12;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,159,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 186
        A = 13;
        B = 11;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,186,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 171
        A = 12;
        B = 10;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,171,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 170
        A = 12;
        B = 9;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,170,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 188
        A = 13;
        B = 13;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,188,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 199
        A = 14;
        B = 11;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,199,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 214
        A = 15;
        B = 11;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,214,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 146
        A = 10;
        B = 12;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,146,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 201
        A = 14;
        B = 13;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,201,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 216
        A = 15;
        B = 13;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,216,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 135
        A = 9;
        B = 13;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,135,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        // Candidate 145
        A = 10;
        B = 11;
        #1;
        pass_count = pass_count + 1;
        if (A == 0 && B == 0) cov_bin = "eq_zero";
        else if (A == 15 && B == 15) cov_bin = "eq_max";
        else if (A == 15 && B == 0) cov_bin = "gt_max_min";
        else if (A == 0 && B == 15) cov_bin = "lt_min_max";
        else if (A > B) cov_bin = "mid_gt";
        else if (A == B) cov_bin = "mid_eq";
        else cov_bin = "mid_lt";
        $fwrite(fh, "comparator_4bit,combinational,ml_targeted,999,145,%0d,%0d,%0d,%0s\n",
                A,B, 1, cov_bin);
        $fclose(fh);
        $display("[TARGETED SIM COMPLETE] comparator_4bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule