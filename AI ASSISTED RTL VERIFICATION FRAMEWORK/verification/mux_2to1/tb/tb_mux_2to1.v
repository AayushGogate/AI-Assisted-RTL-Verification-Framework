`timescale 1ns/1ps

module tb_mux_2to1_top;

    reg  A, B, S;
    wire X;

    integer num_tests   = 100;
    integer seed;
    integer i;
    integer pass_count  = 0;
    integer fail_count  = 0;

    // coverage bins: S=0/A=0, S=0/A=1, S=1/B=0, S=1/B=1
    integer cov_bins [0:3];
    reg     expected;

    integer fh;

    mux2to1 DUT (
        .A(A),
        .B(B),
        .S(S),
        .X(X)
    );

    // ---------------- Driver ----------------
    task drive_stimulus;
        begin
            A = $urandom_range(0,1);
            B = $urandom_range(0,1);
            S = $urandom_range(0,1);
            #1;
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    task check_result;
        begin
            expected = (S == 1'b0) ? A : B;

            if (X !== expected) begin
                fail_count = fail_count + 1;

                $display("[FAIL] time=%0t A=%b B=%b S=%b X=%b expected=%b",
                         $time, A, B, S, X, expected);
            end
            else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    // ---------------- Monitor / Coverage ----------------
    task sample_coverage;
        begin
            if (S == 1'b0 && A == 1'b0)
                cov_bins[0] = cov_bins[0] + 1;

            if (S == 1'b0 && A == 1'b1)
                cov_bins[1] = cov_bins[1] + 1;

            if (S == 1'b1 && B == 1'b0)
                cov_bins[2] = cov_bins[2] + 1;

            if (S == 1'b1 && B == 1'b1)
                cov_bins[3] = cov_bins[3] + 1;
        end
    endtask

    // ---------------- CSV Header ----------------
    task log_csv_header;
        begin
            fh = $fopen("verification/mux_2to1/data/results.csv", "w");

            if (fh == 0) begin
                $display("ERROR: Could not create results.csv");
                $finish;
            end

            $display("CSV file opened successfully");

            $fwrite(fh, "test_num,A,B,S,X,expected,pass\n");
        end
    endtask

    // ---------------- CSV Data ----------------
    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "%0d,%b,%b,%b,%b,%b,%0d\n",
                    idx, A, B, S, X, expected, (X === expected));
        end
    endtask

    // ---------------- Main Test ----------------
    initial begin

        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;

        $display("Running mux_2to1 CRV testbench | seed=%0d | tests=%0d",
                 seed, num_tests);

        i = $urandom(seed);

        cov_bins[0] = 0;
        cov_bins[1] = 0;
        cov_bins[2] = 0;
        cov_bins[3] = 0;

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

        $display("Coverage bins [S0A0, S0A1, S1B0, S1B1] = %0d, %0d, %0d, %0d",
                 cov_bins[0],
                 cov_bins[1],
                 cov_bins[2],
                 cov_bins[3]);

        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;

    end

endmodule