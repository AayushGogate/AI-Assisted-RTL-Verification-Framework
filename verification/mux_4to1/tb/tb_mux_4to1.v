`timescale 1ns/1ps

module tb_mux_4to1;

    reg  I0, I1, I2, I3, S1, S0;
    wire Y;

    integer num_tests   = 100;
    integer seed;
    integer i;
    integer pass_count  = 0;
    integer fail_count  = 0;

    // 8 bins:
    // {S1, S0, selected_input_value}
    integer cov_bins [0:7];
    integer bin_idx;

    reg expected;
    reg chosen_val;

    integer fh;

    mux_4to1 DUT (
        .I0(I0),
        .I1(I1),
        .I2(I2),
        .I3(I3),
        .S1(S1),
        .S0(S0),
        .Y(Y)
    );

    // ---------------- Driver ----------------

    task drive_stimulus;
        begin
            I0 = $urandom_range(0, 1);
            I1 = $urandom_range(0, 1);
            I2 = $urandom_range(0, 1);
            I3 = $urandom_range(0, 1);
            S1 = $urandom_range(0, 1);
            S0 = $urandom_range(0, 1);

            #1;
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------

    task check_result;
        begin
            case ({S1, S0})
                2'b00: expected = I0;
                2'b01: expected = I1;
                2'b10: expected = I2;
                2'b11: expected = I3;
                default: expected = 1'bx;
            endcase

            if (Y !== expected) begin
                fail_count = fail_count + 1;

                $display(
                    "[FAIL] time=%0t I0=%b I1=%b I2=%b I3=%b S1=%b S0=%b Y=%b expected=%b",
                    $time,
                    I0,
                    I1,
                    I2,
                    I3,
                    S1,
                    S0,
                    Y,
                    expected
                );
            end
            else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    // ---------------- Functional Coverage ----------------

    task sample_coverage;
        begin
            case ({S1, S0})
                2'b00: chosen_val = I0;
                2'b01: chosen_val = I1;
                2'b10: chosen_val = I2;
                2'b11: chosen_val = I3;
                default: chosen_val = 1'bx;
            endcase

            if ((S1 === 1'b0) &&
                (S0 === 1'b0) &&
                (chosen_val === 1'b0))
                cov_bins[0] = cov_bins[0] + 1;

            else if ((S1 === 1'b0) &&
                     (S0 === 1'b0) &&
                     (chosen_val === 1'b1))
                cov_bins[1] = cov_bins[1] + 1;

            else if ((S1 === 1'b0) &&
                     (S0 === 1'b1) &&
                     (chosen_val === 1'b0))
                cov_bins[2] = cov_bins[2] + 1;

            else if ((S1 === 1'b0) &&
                     (S0 === 1'b1) &&
                     (chosen_val === 1'b1))
                cov_bins[3] = cov_bins[3] + 1;

            else if ((S1 === 1'b1) &&
                     (S0 === 1'b0) &&
                     (chosen_val === 1'b0))
                cov_bins[4] = cov_bins[4] + 1;

            else if ((S1 === 1'b1) &&
                     (S0 === 1'b0) &&
                     (chosen_val === 1'b1))
                cov_bins[5] = cov_bins[5] + 1;

            else if ((S1 === 1'b1) &&
                     (S0 === 1'b1) &&
                     (chosen_val === 1'b0))
                cov_bins[6] = cov_bins[6] + 1;

            else if ((S1 === 1'b1) &&
                     (S0 === 1'b1) &&
                     (chosen_val === 1'b1))
                cov_bins[7] = cov_bins[7] + 1;
        end
    endtask

    // ---------------- CSV Header ----------------

    task log_csv_header;
        begin
            // This path is relative to the directory where vvp is executed.
            fh = $fopen("verification/mux_4to1/data/results.csv", "w");

            if (fh == 0) begin
                $display("ERROR: Could not create CSV file.");
                $display("Check that this directory exists:");
                $display("verification/mux_4to1/data/");
                $finish;
            end
            else begin
                $display("CSV file opened successfully.");
                $display("CSV path: verification/mux_4to1/data/results.csv");
            end

            $fwrite(
                fh,
                "test_num,I0,I1,I2,I3,S1,S0,Y,expected,pass\n"
            );
        end
    endtask

    // ---------------- CSV Data ----------------

    task log_csv_row;
        input integer idx;

        begin
            $fwrite(
                fh,
                "%0d,%b,%b,%b,%b,%b,%b,%b,%b,%0d\n",
                idx,
                I0,
                I1,
                I2,
                I3,
                S1,
                S0,
                Y,
                expected,
                (Y === expected)
            );
        end
    endtask

    // ---------------- Main Test ----------------

    initial begin

        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;

        $display(
            "Running mux_4to1 CRV testbench | seed=%0d | tests=%0d",
            seed,
            num_tests
        );

        // Seed the random generator
        i = $urandom(seed);

        // Initialize coverage bins
        for (bin_idx = 0; bin_idx < 8; bin_idx = bin_idx + 1)
            cov_bins[bin_idx] = 0;

        // Open CSV and write header
        log_csv_header;

        // Run tests
        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        // Close CSV
        $fclose(fh);
        $display("CSV file closed successfully.");

        // Display results
        $display("----------------------------------------");
        $display("PASS: %0d  FAIL: %0d", pass_count, fail_count);

        $display("Coverage bins [S1 S0 chosen_val]:");

        for (bin_idx = 0; bin_idx < 8; bin_idx = bin_idx + 1)
            $display(
                "  %03b -> %0d",
                bin_idx[2:0],
                cov_bins[bin_idx]
            );

        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;

    end

endmodule