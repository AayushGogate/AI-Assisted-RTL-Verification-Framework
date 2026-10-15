`timescale 1ns/1ps

module tb_sr_flip_flop;

    reg  S, R, clk, reset;
    wire Q;

    integer num_tests = 100;
    integer seed;
    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    // rst_mode: 0 = no reset, 1 = reset held across the clock edge,
    //           2 = short async reset pulse between clock edges
    integer rst_mode;
    reg     prev_q;     // reference state at the start of the cycle (can be X)
    reg     exp_q;      // reference model state (can be X)
    reg     cur_q;
    reg     async_ok;
    reg     post_ok;

    // coverage bins
    // cov_sr[qcode*4 + {S,R}] where qcode: 0 -> Q=0, 1 -> Q=1, 2 -> Q=X (no reset active)
    integer cov_sr [0:11];
    integer bin_rst_clear_q1;   // async reset applied while Q=1
    integer bin_rst_clear_qx;   // async reset applied while Q=X (recovery from the forbidden state)
    integer bin_rst_held_s1r0;  // reset held through the edge while S=1,R=0 (reset must beat set)
    integer bin_rst_pulse_s1r0; // short pulse clears Q, then S=1,R=0 sets it at the edge
    integer qcode;
    integer k;

    integer fh;

    sr_flip_flop DUT (
        .S(S),
        .R(R),
        .clk(clk),
        .reset(reset),
        .Q(Q)
    );

    // ---------------- Clock ----------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------- Driver ----------------
    // S/R is weighted so the forbidden combination appears, but less often than the legal ones:
    // 00 (hold) 25%, 01 (reset) 30%, 10 (set) 30%, 11 (forbidden) 15%.
    task drive_stimulus;
        integer r;
        integer sr;
        begin
            sr = $urandom_range(0,99);
            if      (sr < 25) {S, R} = 2'b00;
            else if (sr < 55) {S, R} = 2'b01;
            else if (sr < 85) {S, R} = 2'b10;
            else              {S, R} = 2'b11;

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
    // Called 1 ns after the posedge. Reset wins; otherwise apply the S/R truth table.
    // S=R=1 is the forbidden input, and the module defines its result as unknown (X).
    task check_result;
        begin
            cur_q = exp_q;
            if (reset) begin
                exp_q = 1'b0;
            end else begin
                case ({S, R})
                    2'b00: exp_q = cur_q;     // hold (an X state stays X)
                    2'b01: exp_q = 1'b0;      // reset to 0
                    2'b10: exp_q = 1'b1;      // set to 1
                    2'b11: exp_q = 1'bx;      // forbidden -> X
                endcase
            end

            post_ok = (Q === exp_q);
            if (!post_ok)
                $display("[FAIL] time=%0t cycle=%0d reset=%b S=%b R=%b Q=%b expected=%b",
                          $time, i, reset, S, R, Q, exp_q);

            if (async_ok && post_ok) pass_count = pass_count + 1;
            else                     fail_count = fail_count + 1;
        end
    endtask

    // ---------------- Monitor / Coverage ----------------
    reg [255:0] cov_bin;
    reg [15:0]  state_str;
    integer bin_rst_idle;

    task sample_coverage;
        begin
            if (prev_q === 1'b0)      begin qcode = 0; state_str = "0"; end
            else if (prev_q === 1'b1) begin qcode = 1; state_str = "1"; end
            else                      begin qcode = 2; state_str = "x"; end

            if (rst_mode == 0) begin
                cov_sr[qcode*4 + {S, R}] = cov_sr[qcode*4 + {S, R}] + 1;
                case (qcode)
                    0: cov_bin = {"q0_s", (S ? "1" : "0"), "_r", (R ? "1" : "0")};
                    1: cov_bin = {"q1_s", (S ? "1" : "0"), "_r", (R ? "1" : "0")};
                    default: cov_bin = {"qx_s", (S ? "1" : "0"), "_r", (R ? "1" : "0")};
                endcase
            end else begin
                if (qcode == 1) bin_rst_clear_q1 = bin_rst_clear_q1 + 1;
                if (qcode == 2) bin_rst_clear_qx = bin_rst_clear_qx + 1;
                if (rst_mode == 1 && S === 1'b1 && R === 1'b0) bin_rst_held_s1r0  = bin_rst_held_s1r0  + 1;
                if (rst_mode == 2 && S === 1'b1 && R === 1'b0) bin_rst_pulse_s1r0 = bin_rst_pulse_s1r0 + 1;
                if ((rst_mode == 1 || rst_mode == 2) && qcode == 0 && !(S === 1'b1 && R === 1'b0))
                    bin_rst_idle = bin_rst_idle + 1;

                if (rst_mode == 1 && S === 1'b1 && R === 1'b0) cov_bin = "bin_rst_held_s1r0";
                else if (rst_mode == 2 && S === 1'b1 && R === 1'b0) cov_bin = "bin_rst_pulse_s1r0";
                else if (qcode == 1)                               cov_bin = "bin_rst_clear_q1";
                else if (qcode == 2)                               cov_bin = "bin_rst_clear_qx";
                else                                               cov_bin = "bin_rst_idle";
            end
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/sequential/sr_flip_flop/data/results_crv_baseline.csv", "w");
            if (!fh) fh = $fopen("data/results_crv_baseline.csv", "w");
            $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,cycle,state,rst_mode,S,R,reset,Q,expected,pass,coverage_bin\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "sr_flip_flop,sequential,crv_baseline,%0d,%0d,%0d,%0s,%0d,%0d,%0d,%0d,%b,%b,%0d,%0s\n",
                     seed, idx, idx, state_str, rst_mode, S, R, reset, Q, exp_q, (async_ok && post_ok), cov_bin);
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
        $display("Running sr_flip_flop CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed); // seeds global RNG; Icarus updates 'seed' by ref, so it is printed first

        for (k = 0; k < 12; k = k + 1) cov_sr[k] = 0;
        bin_rst_clear_q1 = 0; bin_rst_clear_qx = 0; bin_rst_held_s1r0 = 0; bin_rst_pulse_s1r0 = 0; bin_rst_idle = 0;

        log_csv_header;

        // Initial async reset so the reference and the DUT start from a known state
        reset = 1'b0; S = 1'b0; R = 1'b0;
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
        $display("Coverage bins [prev Q, S R -> count]:");
        for (k = 0; k < 12; k = k + 1) begin
            if (cov_sr[k] == 0) begin
                if (k/4 == 0)      $display("  Q=0 SR=%b = %0d   <-- MISSING", k[1:0], cov_sr[k]);
                else if (k/4 == 1) $display("  Q=1 SR=%b = %0d   <-- MISSING", k[1:0], cov_sr[k]);
                else               $display("  Q=X SR=%b = %0d   <-- MISSING", k[1:0], cov_sr[k]);
            end else begin
                if (k/4 == 0)      $display("  Q=0 SR=%b = %0d", k[1:0], cov_sr[k]);
                else if (k/4 == 1) $display("  Q=1 SR=%b = %0d", k[1:0], cov_sr[k]);
                else               $display("  Q=X SR=%b = %0d", k[1:0], cov_sr[k]);
            end
        end
        report_bin("bin_rst_clear_q1", bin_rst_clear_q1);
        report_bin("bin_rst_clear_qx", bin_rst_clear_qx);
        report_bin("bin_rst_held_s1r0", bin_rst_held_s1r0);
        report_bin("bin_rst_pulse_s1r0", bin_rst_pulse_s1r0);
        report_bin("bin_rst_idle", bin_rst_idle);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule