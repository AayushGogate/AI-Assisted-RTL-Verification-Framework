`timescale 1ns/1ps
module tb_decoder_2to4;
    reg        enable;
    reg  [1:0] in;
    wire [3:0] out;

    integer num_tests = 20;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg [3:0] exp_out;
    reg [255:0] cov_bin;
    integer fh;

    decoder_2to4 dut (.enable(enable), .in(in), .out(out));

    task drive_stimulus;
        begin
            enable = $urandom_range(0, 1);
            in     = $urandom_range(0, 3);
            #1;
        end
    endtask

    task check_result;
        begin
            exp_out = enable ? (4'b0001 << in) : 4'b0000;
            if (out !== exp_out) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d en=%0d in=%0d | out=%0d exp=%0d", i, enable, in, out, exp_out);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            if (enable == 0) cov_bin = "disabled";
            else begin
                case (in)
                    0: cov_bin = "en_out0";
                    1: cov_bin = "en_out1";
                    2: cov_bin = "en_out2";
                    3: cov_bin = "en_out3";
                endcase
            end
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "decoder_2to4,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, enable, in, out, exp_out, (out === exp_out), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] decoder_2to4 | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/decoder_2to4/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,enable,in,out,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] decoder_2to4 | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
