`timescale 1ns/1ps
module tb_priority_encoder_4to2;
    reg        enable;
    reg  [3:0] in;
    wire [1:0] code;
    wire       valid;

    integer num_tests = 25;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg [1:0] exp_code;
    reg       exp_valid;
    reg [255:0] cov_bin;
    integer fh;

    priority_encoder_4to2 dut (.enable(enable), .in(in), .code(code), .valid(valid));

    task drive_stimulus;
        begin
            enable = $urandom_range(0, 1);
            in     = $urandom_range(0, 15);
            #1;
        end
    endtask

    task check_result;
        begin
            if (!enable) begin
                exp_code = 0; exp_valid = 0;
            end else if (in[3]) begin
                exp_code = 3; exp_valid = 1;
            end else if (in[2]) begin
                exp_code = 2; exp_valid = 1;
            end else if (in[1]) begin
                exp_code = 1; exp_valid = 1;
            end else if (in[0]) begin
                exp_code = 0; exp_valid = 1;
            end else begin
                exp_code = 0; exp_valid = 0;
            end

            if (code !== exp_code || valid !== exp_valid) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d en=%0d in=%0d | code=%0d valid=%0d expCode=%0d expValid=%0d",
                         i, enable, in, code, valid, exp_code, exp_valid);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            if (enable == 0) cov_bin = "disabled";
            else if (in == 0) cov_bin = "none_active";
            else if (in[3]) cov_bin = "pri_3";
            else if (in[2]) cov_bin = "pri_2";
            else if (in[1]) cov_bin = "pri_1";
            else cov_bin = "pri_0";
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "priority_encoder_4to2,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, enable, in, code, valid, {exp_valid, exp_code},
                    (code === exp_code && valid === exp_valid), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] priority_encoder_4to2 | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/priority_encoder_4to2/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,enable,in,code,valid,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] priority_encoder_4to2 | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
