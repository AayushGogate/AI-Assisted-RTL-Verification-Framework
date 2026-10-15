`timescale 1ns/1ps

module tb_binary_to_gray_3bit;

    reg  [2:0] B;
    wire [2:0] G;

    integer num_tests  = 100;
    integer seed;
    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    reg [2:0] expected;

    // 8 bins: one per possible B value (0 through 7)
    integer cov_bins [0:7];

    integer fh;

    binary_to_gray_3bit DUT (
        .B(B),
        .G(G)
    );

    // ---------------- Driver ----------------
    task drive_stimulus;
        begin
            B = $urandom_range(0,7);
            #1;
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    task check_result;
        begin
            expected[2] = B[2];
            expected[1] = B[1] ^ B[2];
            expected[0] = B[0] ^ B[1];

            if (G !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] time=%0t B=%03b G=%03b expected=%03b",
                          $time, B, G, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    // ---------------- Monitor / Coverage ----------------
    task sample_coverage;
        begin
            cov_bins[B] = cov_bins[B] + 1;
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/binary_to_gray_3bit/data/results.csv", "w");
            $fwrite(fh, "test_num,B,G,expected,pass\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "%0d,%03b,%03b,%03b,%0d\n",
                     idx, B, G, expected, (G === expected));
        end
    endtask

    initial begin
        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;
        $display("Running binary_to_gray_3bit CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed); // seeds global RNG; Icarus updates 'seed' by ref, so log first

        for (i = 0; i < 8; i = i + 1)
            cov_bins[i] = 0;

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
        $display("Coverage bins [B=000..111]:");
        for (i = 0; i < 8; i = i + 1)
            $display("  %03b -> %0d", i[2:0], cov_bins[i]);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule