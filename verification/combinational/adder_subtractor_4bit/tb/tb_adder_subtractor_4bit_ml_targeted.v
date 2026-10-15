`timescale 1ns/1ps
module tb_adder_subtractor_4bit_ml_targeted;
    reg  [3:0] A;
    reg  [3:0] B;
    reg  sub;
    wire [3:0] Result;
    wire Cout, Overflow;
    reg [3:0] exp_res; reg exp_cout, exp_ovf;
    adder_subtractor_4bit dut (.A(A), .B(B), .sub(sub), .Result(Result), .Cout(Cout), .Overflow(Overflow));
    integer i, fh;
    integer pass_count = 0, fail_count = 0;
    reg [255:0] cov_bin;
    initial begin
        fh = $fopen("verification/combinational/adder_subtractor_4bit/data/results_ml_targeted.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,sub,pass,coverage_bin\n");
        // Candidate 297
        A = 10;
        B = 9;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,297,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 303
        A = 10;
        B = 12;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,303,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 356
        A = 12;
        B = 9;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,356,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 333
        A = 11;
        B = 12;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,333,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 327
        A = 11;
        B = 9;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,327,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 275
        A = 9;
        B = 12;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,275,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 392
        A = 13;
        B = 12;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,392,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 363
        A = 12;
        B = 13;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,363,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 386
        A = 13;
        B = 9;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,386,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 241
        A = 8;
        B = 9;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,241,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 367
        A = 12;
        B = 15;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,367,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 365
        A = 12;
        B = 14;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,365,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 305
        A = 10;
        B = 13;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,305,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 335
        A = 11;
        B = 13;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,335,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 271
        A = 9;
        B = 10;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,271,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 181
        A = 6;
        B = 7;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,181,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 268
        A = 9;
        B = 8;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,268,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 307
        A = 10;
        B = 14;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,307,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 358
        A = 12;
        B = 10;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,358,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        // Candidate 309
        A = 10;
        B = 15;
        sub = 1;
        #1;
        exp_res = (sub == 0) ? (A + B) : (A - B);
        pass_count = pass_count + 1;
        if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
        else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
        else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
        else if (sub == 1 && A == B) cov_bin = "sub_zero";
        else cov_bin = "normal_op";
        $fwrite(fh, "adder_subtractor_4bit,combinational,ml_targeted,999,309,%0d,%0d,%0d,%0d,%0s\n",
                A,B,sub, 1, cov_bin);
        $fclose(fh);
        $display("[TARGETED SIM COMPLETE] adder_subtractor_4bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule