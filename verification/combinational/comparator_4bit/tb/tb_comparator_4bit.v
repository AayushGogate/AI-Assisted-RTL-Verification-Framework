`timescale 1ns/1ps
module tb_comparator_4bit;
    reg  [3:0] A, B;
    wire gt, eq, lt;

    integer num_tests = 40;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg exp_gt, exp_eq, exp_lt;
    reg [255:0] cov_bin;
    integer fh;

    comparator_4bit dut (.A(A), .B(B), .gt(gt), .eq(eq), .lt(lt));

    task drive_stimulus;
        begin
            A = $urandom_range(0, 15);
            B = $urandom_range(0, 15);
            #1;
        end
    endtask

    task check_result;
        begin
            exp_gt = (A > B);
            exp_eq = (A == B);
            exp_lt = (A < B);
            if (gt !== exp_gt || eq !== exp_eq || lt !== exp_lt) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d A=%0d B=%0d | gt=%0d eq=%0d lt=%0d", i, A, B, gt, eq, lt);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            if (A == 0 && B == 0) cov_bin = "eq_zero";
            else if (A == 15 && B == 15) cov_bin = "eq_max";
            else if (A == 15 && B == 0) cov_bin = "gt_max_min";
            else if (A == 0 && B == 15) cov_bin = "lt_min_max";
            else if (A > B) cov_bin = "mid_gt";
            else if (A == B) cov_bin = "mid_eq";
            else cov_bin = "mid_lt";
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "comparator_4bit,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, A, B, gt, eq, lt, {exp_gt, exp_eq, exp_lt},
                    (gt === exp_gt && eq === exp_eq && lt === exp_lt), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] comparator_4bit | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/comparator_4bit/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,gt,eq,lt,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] comparator_4bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
