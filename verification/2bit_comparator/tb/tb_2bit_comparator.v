`timescale 1ns/1ps

module tb_comparator_2bit;

    reg  A1, A0, B1, B0;
    wire A_greater_B, A_equal_B, A_less_B;

    integer num_tests   = 100;
    integer seed;
    integer i;
    integer pass_count  = 0;
    integer fail_count  = 0;

    reg [1:0] A, B;
    reg [2:0] expected; // {gt, eq, lt}

    integer bin_gt;
    integer bin_eq;
    integer bin_lt;

    integer fh;

    comparator_2bit DUT (
        .A1(A1), .A0(A0),
        .B1(B1), .B0(B0),
        .A_greater_B(A_greater_B),
        .A_equal_B(A_equal_B),
        .A_less_B(A_less_B)
    );

    // ---------------- Driver ----------------
    task drive_stimulus;
        begin
            A1 = $urandom_range(0,1);
            A0 = $urandom_range(0,1);
            B1 = $urandom_range(0,1);
            B0 = $urandom_range(0,1);
            #1;
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    task check_result;
        begin
            A = {A1, A0};
            B = {B1, B0};
            expected[2] = (A > B); // gt
            expected[1] = (A == B); // eq
            expected[0] = (A < B); // lt

            if ({A_greater_B, A_equal_B, A_less_B} !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] time=%0t A=%0d B=%0d gt=%b eq=%b lt=%b expected=%03b",
                          $time, A, B, A_greater_B, A_equal_B, A_less_B, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    // ---------------- Monitor / Coverage ----------------
    task sample_coverage;
        begin
            if (expected[2]) bin_gt = bin_gt + 1;
            if (expected[1]) bin_eq = bin_eq + 1;
            if (expected[0]) bin_lt = bin_lt + 1;
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/2bit_comparator/data/results.csv", "w");
            $fwrite(fh, "test_num,A,B,A_greater_B,A_equal_B,A_less_B,expected,pass\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "%0d,%0d,%0d,%b,%b,%b,%03b,%0d\n",
                     idx, A, B, A_greater_B, A_equal_B, A_less_B, expected,
                     ({A_greater_B, A_equal_B, A_less_B} === expected));
        end
    endtask

    initial begin
        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;
        $display("Running comparator_2bit CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed);

        bin_gt = 0;
        bin_eq = 0;
        bin_lt = 0;

        log_csv_header;

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);

        $display("----------------------------------------");
        $display("PASS: %0d  FAIL: %0d", pass_count, fail_count);
        $display("bin_gt = %0d", bin_gt);
        $display("bin_eq = %0d", bin_eq);
        $display("bin_lt = %0d", bin_lt);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule