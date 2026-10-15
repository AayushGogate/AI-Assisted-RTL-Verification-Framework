`timescale 1ns/1ps
module tb_mux_2to1;
    reg  A, B, S;
    wire X;

    integer num_tests = 20;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg expected;
    reg [255:0] cov_bin;
    integer fh;

    // Coverage bin counters
    integer bin_S0_val0 = 0, bin_S0_val1 = 0;
    integer bin_S1_val0 = 0, bin_S1_val1 = 0;

    mux_2to1 dut (.A(A), .B(B), .S(S), .X(X));

    task drive_stimulus;
        begin
            A = $urandom_range(0, 1);
            B = $urandom_range(0, 1);
            S = $urandom_range(0, 1);
            #1;
        end
    endtask

    task check_result;
        begin
            expected = (S == 1'b0) ? A : B;
            if (X !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d A=%0d B=%0d S=%0d | X=%0d exp=%0d", i, A, B, S, X, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            if (S == 0 && A == 0) begin bin_S0_val0 = bin_S0_val0 + 1; cov_bin = "S0_val0"; end
            else if (S == 0 && A == 1) begin bin_S0_val1 = bin_S0_val1 + 1; cov_bin = "S0_val1"; end
            else if (S == 1 && B == 0) begin bin_S1_val0 = bin_S1_val0 + 1; cov_bin = "S1_val0"; end
            else begin bin_S1_val1 = bin_S1_val1 + 1; cov_bin = "S1_val1"; end
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "mux_2to1,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, A, B, S, X, expected, (X === expected), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] mux_2to1 | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/mux_2to1/data/results_crv_baseline.csv", "w");
        if (!fh) begin
            $display("[ERROR] Cannot open results CSV");
            $finish;
        end
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,S,X,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] mux_2to1 | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $display("[COVERAGE] S0_val0=%0d S0_val1=%0d S1_val0=%0d S1_val1=%0d",
                 bin_S0_val0, bin_S0_val1, bin_S1_val0, bin_S1_val1);
        $finish;
    end
endmodule
