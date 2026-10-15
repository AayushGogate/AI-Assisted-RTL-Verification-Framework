`timescale 1ns/1ps
module tb_adder_4bit;
    reg  [3:0] A, B;
    reg        Cin;
    wire [3:0] S;
    wire       Cout;

    integer num_tests = 60;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg [4:0] expected;
    reg [255:0] cov_bin;
    integer fh;

    integer bin_sum_zero = 0, bin_sum_max = 0;
    integer bin_carry_gen = 0, bin_carry_prop = 0, bin_carry_kill = 0, bin_no_carry = 0;

    adder_4bit dut (.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));

    task drive_stimulus;
        begin
            A = $urandom_range(0, 15);
            B = $urandom_range(0, 15);
            Cin = $urandom_range(0, 1);
            #1;
        end
    endtask

    task check_result;
        begin
            expected = A + B + Cin;
            if ({Cout, S} !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d A=%0d B=%0d Cin=%0d | Cout=%0d S=%0d exp=%0d",
                         i, A, B, Cin, Cout, S, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            if (expected == 0) begin
                bin_sum_zero = bin_sum_zero + 1;
                cov_bin = "sum_zero";
            end else if (expected == 31) begin
                bin_sum_max = bin_sum_max + 1;
                cov_bin = "sum_max";
            end else if (Cin == 0 && Cout == 1) begin
                bin_carry_gen = bin_carry_gen + 1;
                cov_bin = "carry_gen";
            end else if (Cin == 1 && Cout == 1) begin
                bin_carry_prop = bin_carry_prop + 1;
                cov_bin = "carry_prop";
            end else if (Cin == 1 && Cout == 0) begin
                bin_carry_kill = bin_carry_kill + 1;
                cov_bin = "carry_kill";
            end else begin
                bin_no_carry = bin_no_carry + 1;
                cov_bin = "no_carry";
            end
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "adder_4bit,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, A, B, Cin, S, Cout, expected, ({Cout, S} === expected), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] adder_4bit | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/adder_4bit/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,Cin,S,Cout,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] adder_4bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $display("[COVERAGE] sum_0=%0d sum_31=%0d c_gen=%0d c_prop=%0d c_kill=%0d no_c=%0d",
                 bin_sum_zero, bin_sum_max, bin_carry_gen, bin_carry_prop, bin_carry_kill, bin_no_carry);
        $finish;
    end
endmodule
