`timescale 1ns/1ps

module tb_t_flip_flop;

    reg  T, clk, reset;
    wire Q;

    integer num_tests = 100;
    integer seed;
    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    // rst_mode: 0 = no reset, 1 = reset held across the clock edge,
    //           2 = short async reset pulse between clock edges
    integer rst_mode;
    reg     prev_q;     // reference state at the start of the cycle
    reg     exp_q;      // reference model state
    reg     cur_q;
    reg     async_ok;
    reg     post_ok;

    // coverage bins
    // cov_t[{Q,T}]: current state x toggle-enable, no reset active
    integer cov_t [0:3];
    integer bin_rst_clear_q1;   // async reset applied while Q=1
    integer bin_rst_held_t1;    // reset held through the edge with T=1 (reset must beat toggle)
    integer bin_rst_pulse_t1;   // short pulse clears Q, then T=1 toggles it to 1 at the edge
    integer k;

    integer fh;

    t_flip_flop DUT (
        .T(T),
        .clk(clk),
        .reset(reset),
        .Q(Q)
    );

    // ---------------- Clock ----------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------- Driver ----------------
    task drive_stimulus;
        integer r;
        begin
            T = $urandom_range(0,1);
            r = $urandom_range(0,99);
            if      (r < 80) rst_mode = 0;
            else if (r < 92) rst_mode = 1;
            else             rst_mode = 2;
        end
    endtask

    task check_async;
        begin
            if (Q !== exp_q) begin
                async_ok = 1'b0;
                $display("[FAIL] time=%0t cycle=%0d async reset: Q=%b expected=%b",
                          $time, i, Q, exp_q);
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
                exp_q = 1'b0;
                check_async;
            end else begin
                reset = 1'b1;
                #1;
                exp_q = 1'b0;
                check_async;
                #2 reset = 1'b0;
            end
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    // Called 1 ns after the posedge. Reset wins; T=1 toggles, T=0 holds.
    task check_result;
        begin
            cur_q = exp_q;
            if (reset)  exp_q = 1'b0;
            else if (T) exp_q = ~cur_q;
            else        exp_q = cur_q;

            post_ok = (Q === exp_q);
            if (!post_ok)
                $display("[FAIL] time=%0t cycle=%0d reset=%b T=%b Q=%b expected=%b",
                          $time, i, reset, T, Q, exp_q);

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
                cov_t[{prev_q, T}] = cov_t[{prev_q, T}] + 1;
                case ({prev_q, T})
                    2'b00: cov_bin = "q0_t0";
                    2'b01: cov_bin = "q0_t1";
                    2'b10: cov_bin = "q1_t0";
                    2'b11: cov_bin = "q1_t1";
                endcase
            end else begin
                if (prev_q === 1'b1)             bin_rst_clear_q1 = bin_rst_clear_q1 + 1;
                if (rst_mode == 1 && T === 1'b1) bin_rst_held_t1  = bin_rst_held_t1  + 1;
                if (rst_mode == 2 && T === 1'b1) bin_rst_pulse_t1 = bin_rst_pulse_t1 + 1;
                if ((rst_mode == 1 || rst_mode == 2) && prev_q === 1'b0 && T === 1'b0)
                    bin_rst_idle = bin_rst_idle + 1;

                if (rst_mode == 1 && T === 1'b1)      cov_bin = "bin_rst_held_t1";
                else if (rst_mode == 2 && T === 1'b1) cov_bin = "bin_rst_pulse_t1";
                else if (prev_q === 1'b1)             cov_bin = "bin_rst_clear_q1";
                else                                  cov_bin = "bin_rst_idle";
            end
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/sequential/t_flip_flop/data/results_crv_baseline.csv", "w");
            if (!fh) fh = $fopen("data/results_crv_baseline.csv", "w");
            $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,cycle,state,rst_mode,T,reset,Q,expected,pass,coverage_bin\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "t_flip_flop,sequential,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                     seed, idx, idx, prev_q, rst_mode, T, reset, Q, exp_q, (async_ok && post_ok), cov_bin);
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
            num_tests = 100;
        $display("Running t_flip_flop CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed); // seeds global RNG; Icarus updates 'seed' by ref, so it is printed first

        for (k = 0; k < 4; k = k + 1) cov_t[k] = 0;
        bin_rst_clear_q1 = 0; bin_rst_held_t1 = 0; bin_rst_pulse_t1 = 0; bin_rst_idle = 0;

        log_csv_header;

        // Initial async reset so the reference and the DUT start from a known state
        reset = 1'b0; T = 1'b0;
        #2 reset = 1'b1;
        #1;
        exp_q = 1'b0;
        if (Q !== 1'b0) $display("[FAIL] initial reset did not clear Q (Q=%b)", Q);
        #4 reset = 1'b0;

        for (i = 0; i < num_tests; i = i + 1) begin
            @(negedge clk);
            prev_q = exp_q;
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
        $display("Coverage bins [Q T -> count]:");
        for (k = 0; k < 4; k = k + 1) begin
            if (cov_t[k] == 0) $display("  %02b = %0d   <-- MISSING", k[1:0], cov_t[k]);
            else               $display("  %02b = %0d", k[1:0], cov_t[k]);
        end
        report_bin("bin_rst_clear_q1", bin_rst_clear_q1);
        report_bin("bin_rst_held_t1", bin_rst_held_t1);
        report_bin("bin_rst_pulse_t1", bin_rst_pulse_t1);
        report_bin("bin_rst_idle", bin_rst_idle);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule