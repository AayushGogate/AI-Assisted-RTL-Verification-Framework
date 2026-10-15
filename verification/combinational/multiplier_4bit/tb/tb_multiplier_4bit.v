`timescale 1ns/1ps
module tb_multiplier_4bit;
    reg  [3:0] A, B;
    wire [7:0] P;

    integer num_tests = 40;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg [7:0] exp_p;
    reg [255:0] cov_bin;
    integer fh;

    multiplier_4bit dut (.A(A), .B(B), .P(P));

    task drive_stimulus;
        begin
            A = $urandom_range(0, 15);
            B = $urandom_range(0, 15);
            #1;
        end
    endtask

    task check_result;
        begin
            exp_p = A * B;
            if (P !== exp_p) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d A=%0d B=%0d | P=%0d exp=%0d", i, A, B, P, exp_p);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            if (exp_p == 0) cov_bin = "prod_zero";
            else if (exp_p == 225) cov_bin = "prod_max";
            else if (exp_p == 1) cov_bin = "prod_one";
            else if (exp_p <= 50) cov_bin = "prod_low";
            else if (exp_p <= 150) cov_bin = "prod_mid";
            else cov_bin = "prod_high";
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "multiplier_4bit,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, A, B, P, exp_p, (P === exp_p), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] multiplier_4bit | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/multiplier_4bit/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,P,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] multiplier_4bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
