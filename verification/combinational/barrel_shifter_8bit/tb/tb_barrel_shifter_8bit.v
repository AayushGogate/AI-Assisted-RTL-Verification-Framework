`timescale 1ns/1ps
module tb_barrel_shifter_8bit;
    reg  [7:0] data;
    reg  [2:0] amt;
    reg        dir;
    wire [7:0] out;

    integer num_tests = 80;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg [7:0] exp_out;
    reg [255:0] cov_bin;
    integer fh;

    barrel_shifter_8bit dut (.data(data), .amt(amt), .dir(dir), .out(out));

    task drive_stimulus;
        begin
            data = $urandom_range(0, 255);
            amt  = $urandom_range(0, 7);
            dir  = $urandom_range(0, 1);
            #1;
        end
    endtask

    task check_result;
        begin
            if (dir == 1'b0) begin
                // rotate left by amt
                exp_out = (data << amt) | (data >> (8 - amt));
            end else begin
                // rotate right by amt
                exp_out = (data >> amt) | (data << (8 - amt));
            end

            if (out !== exp_out) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d data=%0d amt=%0d dir=%0d | out=%0d exp=%0d",
                         i, data, amt, dir, out, exp_out);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            if (data == 0) cov_bin = "data_all_0";
            else if (data == 255) cov_bin = "data_all_1";
            else begin
                case ({dir, amt})
                    4'b0000: cov_bin = "dir_L_amt_0";
                    4'b0001: cov_bin = "dir_L_amt_1";
                    4'b0010: cov_bin = "dir_L_amt_2";
                    4'b0011: cov_bin = "dir_L_amt_3";
                    4'b0100: cov_bin = "dir_L_amt_4";
                    4'b0101: cov_bin = "dir_L_amt_5";
                    4'b0110: cov_bin = "dir_L_amt_6";
                    4'b0111: cov_bin = "dir_L_amt_7";
                    4'b1000: cov_bin = "dir_R_amt_0";
                    4'b1001: cov_bin = "dir_R_amt_1";
                    4'b1010: cov_bin = "dir_R_amt_2";
                    4'b1011: cov_bin = "dir_R_amt_3";
                    4'b1100: cov_bin = "dir_R_amt_4";
                    4'b1101: cov_bin = "dir_R_amt_5";
                    4'b1110: cov_bin = "dir_R_amt_6";
                    4'b1111: cov_bin = "dir_R_amt_7";
                endcase
            end
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "barrel_shifter_8bit,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, data, amt, dir, out, exp_out, (out === exp_out), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] barrel_shifter_8bit | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/barrel_shifter_8bit/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,data,amt,dir,out,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] barrel_shifter_8bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
