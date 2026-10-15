`timescale 1ns/1ps

module tb_pipo;

    reg        clk, reset;
    reg  [3:0] parallel_in;
    wire [3:0] parallel_out;

    integer num_tests = 200;
    integer seed;
    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    // rst_mode: 0 = no reset, 1 = reset held across the clock edge,
    //           2 = short async reset pulse between clock edges
    integer rst_mode;
    reg [3:0] prev_out;   // reference state at the start of the cycle
    reg [3:0] exp_out;    // reference model state
    reg       async_ok;
    reg       post_ok;

    // coverage bins (no reset active unless stated)
    integer bin_load_zero;          // 0000 loaded
    integer bin_load_ones;          // 1111 loaded
    integer bin_load_alt;           // 0101 or 1010 loaded
    integer bin_load_onehot;        // 0001, 0010, 0100 or 1000 loaded
    integer bin_load_other;         // any other value loaded
    integer bin_hold_same;          // loaded value equals the stored value (no bit changes)
    integer bin_all_flip;           // loaded value is the bitwise inverse of the stored value
    integer bin_rst_clear_nonzero;  // async reset applied while the stored value is nonzero
    integer bin_rst_held_nonzero;   // reset held through the edge while parallel_in is nonzero
    integer bin_rst_pulse_nonzero;  // short pulse clears the register, then a nonzero value loads at the edge

    integer fh;

    pipo DUT (
        .clk(clk),
        .reset(reset),
        .parallel_in(parallel_in),
        .parallel_out(parallel_out)
    );

    // ---------------- Clock ----------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------- Driver ----------------
    task drive_stimulus;
        integer r;
        begin
            parallel_in = $urandom_range(0,15);
            r = $urandom_range(0,99);
            if      (r < 80) rst_mode = 0;
            else if (r < 92) rst_mode = 1;
            else             rst_mode = 2;
        end
    endtask

    task check_async;
        begin
            if (parallel_out !== exp_out) begin
                async_ok = 1'b0;
                $display("[FAIL] time=%0t cycle=%0d async reset: parallel_out=%0d expected=%0d",
                          $time, i, parallel_out, exp_out);
            end
        end
    endtask

    task apply_async_reset;
        begin
            async_ok = 1'b1;
            if (rst_mode == 0) begin
                reset = 1'b0;
            end else if (rst_mode == 1) begin
                reset = 1'b1;
                #1;
                exp_out = 4'd0;
                check_async;
            end else begin
                reset = 1'b1;
                #1;
                exp_out = 4'd0;
                check_async;
                #2 reset = 1'b0;
            end
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    // Called 1 ns after the posedge. Reset wins; otherwise the register loads parallel_in.
    task check_result;
        begin
            if (reset) exp_out = 4'd0;
            else       exp_out = parallel_in;

            post_ok = (parallel_out === exp_out);
            if (!post_ok)
                $display("[FAIL] time=%0t cycle=%0d reset=%b parallel_in=%0d parallel_out=%0d expected=%0d",
                          $time, i, reset, parallel_in, parallel_out, exp_out);

            if (async_ok && post_ok) pass_count = pass_count + 1;
            else                     fail_count = fail_count + 1;
        end
    endtask

    // ---------------- Monitor / Coverage ----------------
    reg [255:0] cov_bin;
    integer bin_rst_idle;

    task sample_coverage;
        begin
            if (rst_mode == 0) begin
                if (parallel_in == 4'b0000) begin
                    bin_load_zero = bin_load_zero + 1;
                    cov_bin = "bin_load_zero";
                end else if (parallel_in == 4'b1111) begin
                    bin_load_ones = bin_load_ones + 1;
                    cov_bin = "bin_load_ones";
                end else if (parallel_in == 4'b0101 || parallel_in == 4'b1010) begin
                    bin_load_alt = bin_load_alt + 1;
                    cov_bin = "bin_load_alt";
                end else if (parallel_in == 4'b0001 || parallel_in == 4'b0010 ||
                             parallel_in == 4'b0100 || parallel_in == 4'b1000) begin
                    bin_load_onehot = bin_load_onehot + 1;
                    cov_bin = "bin_load_onehot";
                end else if (parallel_in == prev_out) begin
                    bin_hold_same = bin_hold_same + 1;
                    cov_bin = "bin_hold_same";
                end else if (parallel_in == ((~prev_out) & 4'hF)) begin
                    bin_all_flip = bin_all_flip + 1;
                    cov_bin = "bin_all_flip";
                end else begin
                    bin_load_other = bin_load_other + 1;
                    cov_bin = "bin_load_other";
                end

                if (parallel_in == prev_out && cov_bin != "bin_hold_same")   bin_hold_same = bin_hold_same + 1;
                if (parallel_in == ((~prev_out) & 4'hF) && cov_bin != "bin_all_flip") bin_all_flip  = bin_all_flip  + 1;
            end else begin
                if (prev_out != 4'd0)
                    bin_rst_clear_nonzero = bin_rst_clear_nonzero + 1;
                if (rst_mode == 1 && parallel_in != 4'd0)
                    bin_rst_held_nonzero = bin_rst_held_nonzero + 1;
                if (rst_mode == 2 && parallel_in != 4'd0)
                    bin_rst_pulse_nonzero = bin_rst_pulse_nonzero + 1;
                if ((rst_mode == 1 || rst_mode == 2) && prev_out == 4'd0 && parallel_in == 4'd0)
                    bin_rst_idle = bin_rst_idle + 1;

                if (rst_mode == 1 && parallel_in != 4'd0)      cov_bin = "bin_rst_held_nonzero";
                else if (rst_mode == 2 && parallel_in != 4'd0) cov_bin = "bin_rst_pulse_nonzero";
                else if (prev_out != 4'd0)                     cov_bin = "bin_rst_clear_nonzero";
                else                                           cov_bin = "bin_rst_idle";
            end
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/sequential/pipo/data/results_crv_baseline.csv", "w");
            if (!fh) fh = $fopen("data/results_crv_baseline.csv", "w");
            $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,cycle,state,rst_mode,reset,parallel_in,parallel_out,expected,pass,coverage_bin\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "pipo,sequential,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                     seed, idx, idx, prev_out, rst_mode, reset, parallel_in, parallel_out, exp_out,
                     (async_ok && post_ok), cov_bin);
        end
    endtask

    task report_bin;
        input [8*24-1:0] name;
        input integer    cnt;
        begin
            if (cnt == 0) $display("  %0s = %0d   <-- MISSING", name, cnt);
            else          $display("  %0s = %0d", name, cnt);
        end
    endtask

    initial begin
        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;
        if (!$value$plusargs("TESTS=%d", num_tests))
            num_tests = 200;
        $display("Running pipo CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed); // seeds global RNG; Icarus updates 'seed' by ref, so it is printed first

        bin_load_zero = 0; bin_load_ones = 0; bin_load_alt = 0; bin_load_onehot = 0; bin_load_other = 0;
        bin_hold_same = 0; bin_all_flip = 0;
        bin_rst_clear_nonzero = 0; bin_rst_held_nonzero = 0; bin_rst_pulse_nonzero = 0; bin_rst_idle = 0;

        log_csv_header;

        // Initial async reset so the reference and the DUT start from a known state
        reset = 1'b0; parallel_in = 4'd0;
        #2 reset = 1'b1;
        #1;
        exp_out = 4'd0;
        if (parallel_out !== 4'd0) $display("[FAIL] initial reset did not clear parallel_out (=%0d)", parallel_out);
        #4 reset = 1'b0;

        for (i = 0; i < num_tests; i = i + 1) begin
            @(negedge clk);
            prev_out = exp_out;
            drive_stimulus;
            apply_async_reset;
            @(posedge clk);
            #1;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);

        $display("----------------------------------------");
        $display("PASS: %0d  FAIL: %0d", pass_count, fail_count);
        $display("Coverage bins:");
        report_bin("bin_load_zero", bin_load_zero);
        report_bin("bin_load_ones", bin_load_ones);
        report_bin("bin_load_alt", bin_load_alt);
        report_bin("bin_load_onehot", bin_load_onehot);
        report_bin("bin_load_other", bin_load_other);
        report_bin("bin_hold_same", bin_hold_same);
        report_bin("bin_all_flip", bin_all_flip);
        report_bin("bin_rst_clear_nonzero", bin_rst_clear_nonzero);
        report_bin("bin_rst_held_nonzero", bin_rst_held_nonzero);
        report_bin("bin_rst_pulse_nonzero", bin_rst_pulse_nonzero);
        report_bin("bin_rst_idle", bin_rst_idle);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule