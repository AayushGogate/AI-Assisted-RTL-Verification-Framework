`timescale 1ns/1ps

module tb_d_flip_flop;

    reg D, clk, reset;
    wire Q;

    integer num_tests = 100;
    integer seed;
    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    integer fh;

    d_flip_flop DUT (
        .D(D),
        .clk(clk),
        .reset(reset),
        .Q(Q)
    );

    // Clock generation
    always #5 clk = ~clk;

    // ---------------- Driver ----------------
    task drive_stimulus;
        begin
            D = $urandom_range(0,1);
            reset = $urandom_range(0,1);

            #2;

            if (reset) begin
                #3;
            end
            else begin
                #3;
            end
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    task check_result;
        reg expected;
        begin
            if (reset)
                expected = 1'b0;
            else
                expected = D;

            if (Q !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] time=%0t D=%b reset=%b Q=%b expected=%b",
                         $time, D, reset, Q, expected);
            end
            else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification_sequential/d_flip_flop/data/results.csv", "w");
            $fwrite(fh, "test_num,D,clk,reset,Q,expected,pass\n");
        end
    endtask

    task log_csv_row(input integer idx);
        reg expected;
        begin
            if (reset)
                expected = 1'b0;
            else
                expected = D;

            $fwrite(fh, "%0d,%b,%b,%b,%b,%b,%0d\n",
                    idx, D, clk, reset, Q, expected,
                    (Q === expected));
        end
    endtask

    initial begin
        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;

        clk = 0;
        D = 0;
        reset = 1;

        $display("Running d_flip_flop CRV testbench | seed=%0d | tests=%0d",
                 seed, num_tests);

        i = $urandom(seed);

        log_csv_header;

        #10;

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;

            @(posedge clk);
            #1;

            check_result;
            log_csv_row(i);
        end

        $fclose(fh);

        $display("----------------------------------------");
        $display("PASS: %0d  FAIL: %0d", pass_count, fail_count);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule