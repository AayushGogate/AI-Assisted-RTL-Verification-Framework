`timescale 1ns/1ps

module tb_decoder_2to4;

    reg        enable;
    reg  [1:0] in;
    wire [3:0] out;

    integer num_tests  = 100;
    integer seed;
    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    reg [3:0] expected;

    // 5 meaningful bins: disabled (any 'in'), + enabled x 4 select values
    integer bin_disabled;
    integer bin_en_00;
    integer bin_en_01;
    integer bin_en_10;
    integer bin_en_11;

    integer fh;

    decoder_2to4 DUT (
        .enable(enable),
        .in(in),
        .out(out)
    );

    // ---------------- Driver ----------------
    task drive_stimulus;
        begin
            enable = $urandom_range(0,1);
            in     = $urandom_range(0,3);
            #1;
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    task check_result;
        begin
            if (!enable) begin
                expected = 4'b0000;
            end else begin
                case (in)
                    2'b00: expected = 4'b0001;
                    2'b01: expected = 4'b0010;
                    2'b10: expected = 4'b0100;
                    2'b11: expected = 4'b1000;
                    default: expected = 4'b0000;
                endcase
            end

            if (out !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] time=%0t enable=%b in=%02b out=%04b expected=%04b",
                          $time, enable, in, out, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    // ---------------- Monitor / Coverage ----------------
    task sample_coverage;
        begin
            if (!enable) begin
                bin_disabled = bin_disabled + 1;
            end else begin
                case (in)
                    2'b00: bin_en_00 = bin_en_00 + 1;
                    2'b01: bin_en_01 = bin_en_01 + 1;
                    2'b10: bin_en_10 = bin_en_10 + 1;
                    2'b11: bin_en_11 = bin_en_11 + 1;
                endcase
            end
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/decoder_2to4/data/results.csv", "w");
            $fwrite(fh, "test_num,enable,in,out,expected,pass\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "%0d,%b,%02b,%04b,%04b,%0d\n",
                     idx, enable, in, out, expected, (out === expected));
        end
    endtask

    initial begin
        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;
        $display("Running decoder_2to4 CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed); // seeds global RNG; Icarus updates 'seed' by ref, so log first

        bin_disabled = 0;
        bin_en_00    = 0;
        bin_en_01    = 0;
        bin_en_10    = 0;
        bin_en_11    = 0;

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
        $display("bin_disabled = %0d", bin_disabled);
        $display("bin_en_00    = %0d", bin_en_00);
        $display("bin_en_01    = %0d", bin_en_01);
        $display("bin_en_10    = %0d", bin_en_10);
        $display("bin_en_11    = %0d", bin_en_11);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule