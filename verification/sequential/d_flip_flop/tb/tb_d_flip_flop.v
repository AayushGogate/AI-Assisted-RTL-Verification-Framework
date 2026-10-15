`timescale 1ns/1ps

module tb_d_flip_flop;

    reg  D, clk, reset;
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
    reg     async_ok;
    reg     post_ok;

    // coverage bins
    integer bin_q0_hold_d0;     // Q=0, D=0 -> 0
    integer bin_q0_set_d1;      // Q=0, D=1 -> 1
    integer bin_q1_clear_d0;    // Q=1, D=0 -> 0
    integer bin_q1_hold_d1;     // Q=1, D=1 -> 1
    integer bin_rst_clear_q1;   // async reset applied while Q=1
    integer bin_rst_held_d1;    // reset held through the edge with D=1 (reset must win)
    integer bin_rst_pulse_d1;   // short pulse clears Q, then D=1 is loaded at the edge

    integer fh;

    d_flip_flop DUT (
        .D(D),
        .clk(clk),
        .reset(reset),
        .Q(Q)
    );

    // ---------------- Clock ----------------
    initial clk = 1'b0;
    always #5 clk = ~clk;

    // ---------------- Driver ----------------
    // Called at negedge clk: picks the data and the reset behaviour for this cycle.
    task drive_stimulus;
        integer r;
        begin
            D = $urandom_range(0,1);
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
    // Called 1 ns after the posedge. Reset wins over data; otherwise Q takes D.
    task check_result;
        begin
            if (reset) exp_q = 1'b0;
            else       exp_q = D;

            post_ok = (Q === exp_q);
            if (!post_ok)
                $display("[FAIL] time=%0t cycle=%0d reset=%b D=%b Q=%b expected=%b",
                          $time, i, reset, D, Q, exp_q);

            if (async_ok && post_ok) pass_count = pass_count + 1;
            else                     fail_count = fail_count + 1;
        end
    endtask

    reg [255:0] cov_bin;
    integer bin_rst_held_d0;

    // ---------------- Monitor / Coverage ----------------
    task sample_coverage;
        begin
            if (rst_mode == 0) begin
                case ({prev_q, D})
                    2'b00: begin bin_q0_hold_d0  = bin_q0_hold_d0  + 1; cov_bin = "bin_q0_hold_d0"; end
                    2'b01: begin bin_q0_set_d1   = bin_q0_set_d1   + 1; cov_bin = "bin_q0_set_d1"; end
                    2'b10: begin bin_q1_clear_d0 = bin_q1_clear_d0 + 1; cov_bin = "bin_q1_clear_d0"; end
                    2'b11: begin bin_q1_hold_d1  = bin_q1_hold_d1  + 1; cov_bin = "bin_q1_hold_d1"; end
                endcase
            end else begin
                if (prev_q === 1'b1)             bin_rst_clear_q1 = bin_rst_clear_q1 + 1;
                if (rst_mode == 1 && D === 1'b1) bin_rst_held_d1  = bin_rst_held_d1  + 1;
                if (rst_mode == 2 && D === 1'b1) bin_rst_pulse_d1 = bin_rst_pulse_d1 + 1;
                if (rst_mode == 1 && D === 1'b0 && prev_q === 1'b0) bin_rst_held_d0 = bin_rst_held_d0 + 1;

                if (rst_mode == 1 && D === 1'b1)      cov_bin = "bin_rst_held_d1";
                else if (rst_mode == 2 && D === 1'b1) cov_bin = "bin_rst_pulse_d1";
                else if (prev_q === 1'b1)             cov_bin = "bin_rst_clear_q1";
                else                                  cov_bin = "bin_rst_held_d0";
            end
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/sequential/d_flip_flop/data/results_crv_baseline.csv", "w");
            if (!fh) fh = $fopen("data/results_crv_baseline.csv", "w");
            $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,cycle,state,rst_mode,D,reset,Q,expected,pass,coverage_bin\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "d_flip_flop,sequential,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                     seed, idx, idx, prev_q, rst_mode, D, reset, Q, exp_q, (async_ok && post_ok), cov_bin);
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
        $display("Running d_flip_flop CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed); // seeds global RNG; Icarus updates 'seed' by ref, so it is printed first

        bin_q0_hold_d0 = 0; bin_q0_set_d1 = 0; bin_q1_clear_d0 = 0; bin_q1_hold_d1 = 0;
        bin_rst_clear_q1 = 0; bin_rst_held_d1 = 0; bin_rst_pulse_d1 = 0; bin_rst_held_d0 = 0;

        log_csv_header;

        // Initial async reset so the reference and the DUT start from a known state
        reset = 1'b0; D = 1'b0;
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
        $display("Coverage bins:");
        report_bin("bin_q0_hold_d0", bin_q0_hold_d0);
        report_bin("bin_q0_set_d1", bin_q0_set_d1);
        report_bin("bin_q1_clear_d0", bin_q1_clear_d0);
        report_bin("bin_q1_hold_d1", bin_q1_hold_d1);
        report_bin("bin_rst_clear_q1", bin_rst_clear_q1);
        report_bin("bin_rst_held_d1", bin_rst_held_d1);
        report_bin("bin_rst_pulse_d1", bin_rst_pulse_d1);
        report_bin("bin_rst_held_d0", bin_rst_held_d0);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule