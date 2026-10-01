`timescale 1ns/1ps

module tb_full_adder;

    reg  A, B, Cin;
    wire Cout, S;

    integer num_tests   = 100;
    integer seed;
    integer i;
    integer pass_count  = 0;
    integer fail_count  = 0;

    // 8 possible input combos: A,B,Cin each 0/1
    integer cov_bins [0:7];
    integer bin_idx;
    reg  [1:0] expected; // {Cout, S}

    integer fh;

    full_adder DUT (
        .A(A), .B(B), .Cin(Cin),
        .Cout(Cout), .S(S)
    );

    // ---------------- Driver ----------------
    task drive_stimulus;
        begin
            A   = $urandom_range(0,1);
            B   = $urandom_range(0,1);
            Cin = $urandom_range(0,1);
            #1;
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    task check_result;
        begin
            expected = A + B + Cin; // {Cout,S} = sum of 3 bits
            if ({Cout, S} !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] time=%0t A=%b B=%b Cin=%b Cout=%b S=%b expected=%b",
                          $time, A, B, Cin, Cout, S, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    // ---------------- Monitor / Coverage ----------------
    task sample_coverage;
        begin
            bin_idx = {A, B, Cin};
            cov_bins[bin_idx] = cov_bins[bin_idx] + 1;
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/full_adder/data/results.csv", "w");
            $fwrite(fh, "test_num,A,B,Cin,Cout,S,expected,pass\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "%0d,%b,%b,%b,%b,%b,%b,%0d\n",
                     idx, A, B, Cin, Cout, S, expected, ({Cout,S} === expected));
        end
    endtask

    initial begin
        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;
        $display("Running full_adder CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed); // seeds global RNG; Icarus updates 'seed' by ref, so log first

        for (bin_idx = 0; bin_idx < 8; bin_idx = bin_idx + 1)
            cov_bins[bin_idx] = 0;

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
        $display("Coverage bins [ABC=000..111]:");
        for (bin_idx = 0; bin_idx < 8; bin_idx = bin_idx + 1)
            $display("  %03b -> %0d", bin_idx[2:0], cov_bins[bin_idx]);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule