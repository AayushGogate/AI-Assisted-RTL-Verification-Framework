`timescale 1ns/1ps
module tb_adder_4bit_ml_targeted;
    reg  [3:0] A;
    reg  [3:0] B;
    reg  Cin;
    wire [3:0] S;
    wire Cout;
    reg [4:0] expected;
    adder_4bit dut (.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));
    integer i, fh;
    integer pass_count = 0, fail_count = 0;
    reg [255:0] cov_bin;
    initial begin
        fh = $fopen("verification/combinational/adder_4bit/data/results_ml_targeted.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,Cin,pass,coverage_bin\n");
        // Candidate 0
        A = 0;
        B = 0;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,0,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 2
        A = 0;
        B = 1;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,2,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 55
        A = 2;
        B = 1;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,55,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 53
        A = 2;
        B = 0;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,53,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 27
        A = 1;
        B = 1;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,27,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 25
        A = 1;
        B = 0;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,25,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 84
        A = 3;
        B = 0;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,84,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 4
        A = 0;
        B = 2;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,4,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 29
        A = 1;
        B = 2;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,29,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 87
        A = 3;
        B = 2;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,87,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 424
        A = 14;
        B = 14;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,424,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 452
        A = 15;
        B = 14;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,452,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 454
        A = 15;
        B = 15;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,454,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 422
        A = 14;
        B = 13;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,422,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 420
        A = 14;
        B = 12;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,420,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 450
        A = 15;
        B = 13;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,450,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 425
        A = 14;
        B = 14;
        Cin = 1;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,425,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 426
        A = 14;
        B = 15;
        Cin = 1;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,426,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 448
        A = 15;
        B = 12;
        Cin = 0;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,448,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        // Candidate 453
        A = 15;
        B = 14;
        Cin = 1;
        #1;
        expected = A + B + Cin;
        if ({Cout, S} === expected) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (expected == 0) cov_bin = "sum_zero";
        else if (expected == 31) cov_bin = "sum_max";
        else if (Cin == 0 && Cout == 1) cov_bin = "carry_gen";
        else if (Cin == 1 && Cout == 1) cov_bin = "carry_prop";
        else if (Cin == 1 && Cout == 0) cov_bin = "carry_kill";
        else cov_bin = "no_carry";
        $fwrite(fh, "adder_4bit,combinational,ml_targeted,999,453,%0d,%0d,%0d,%0d,%0s\n",
                A,B,Cin, 1, cov_bin);
        $fclose(fh);
        $display("[TARGETED SIM COMPLETE] adder_4bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule