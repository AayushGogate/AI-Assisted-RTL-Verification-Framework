`timescale 1ns/1ps

module tb_demux_1to4;

    reg        in;
    reg  [1:0] sel;
    wire [3:0] out;

    integer num_tests  = 100;
    integer seed;
    integer i;
    integer pass_count = 0;
    integer fail_count = 0;

    reg [3:0] expected;

    // 5 meaningful bins: in=0 (all outputs low, regardless of sel), + in=1 x 4 sel values
    integer bin_in0;
    integer bin_in1_sel00;
    integer bin_in1_sel01;
    integer bin_in1_sel10;
    integer bin_in1_sel11;

    integer fh;

    demux_1to4 DUT (
        .in(in),
        .sel(sel),
        .out(out)
    );

    // ---------------- Driver ----------------
    task drive_stimulus;
        begin
            in  = $urandom_range(0,1);
            sel = $urandom_range(0,3);
            #1;
        end
    endtask

    // ---------------- Reference Model / Scoreboard ----------------
    task check_result;
        begin
            expected[0] = in & ~sel[1] & ~sel[0];
            expected[1] = in & ~sel[1] &  sel[0];
            expected[2] = in &  sel[1] & ~sel[0];
            expected[3] = in &  sel[1] &  sel[0];

            if (out !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] time=%0t in=%b sel=%02b out=%04b expected=%04b",
                          $time, in, sel, out, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    // ---------------- Monitor / Coverage ----------------
    task sample_coverage;
        begin
            if (!in) begin
                bin_in0 = bin_in0 + 1;
            end else begin
                case (sel)
                    2'b00: bin_in1_sel00 = bin_in1_sel00 + 1;
                    2'b01: bin_in1_sel01 = bin_in1_sel01 + 1;
                    2'b10: bin_in1_sel10 = bin_in1_sel10 + 1;
                    2'b11: bin_in1_sel11 = bin_in1_sel11 + 1;
                endcase
            end
        end
    endtask

    task log_csv_header;
        begin
            fh = $fopen("verification/demux_1to4/data/results.csv", "w");
            $fwrite(fh, "test_num,in,sel,out,expected,pass\n");
        end
    endtask

    task log_csv_row(input integer idx);
        begin
            $fwrite(fh, "%0d,%b,%02b,%04b,%04b,%0d\n",
                     idx, in, sel, out, expected, (out === expected));
        end
    endtask

    initial begin
        if (!$value$plusargs("SEED=%d", seed))
            seed = 1;
        $display("Running demux_1to4 CRV testbench | seed=%0d | tests=%0d", seed, num_tests);
        i = $urandom(seed); // seeds global RNG; Icarus updates 'seed' by ref, so log first

        bin_in0       = 0;
        bin_in1_sel00 = 0;
        bin_in1_sel01 = 0;
        bin_in1_sel10 = 0;
        bin_in1_sel11 = 0;

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
        $display("bin_in0        = %0d", bin_in0);
        $display("bin_in1_sel00  = %0d", bin_in1_sel00);
        $display("bin_in1_sel01  = %0d", bin_in1_sel01);
        $display("bin_in1_sel10  = %0d", bin_in1_sel10);
        $display("bin_in1_sel11  = %0d", bin_in1_sel11);
        $display("----------------------------------------");

        if (fail_count == 0)
            $display("RESULT: ALL TESTS PASSED");
        else
            $display("RESULT: %0d TESTS FAILED", fail_count);

        $finish;
    end

endmodule