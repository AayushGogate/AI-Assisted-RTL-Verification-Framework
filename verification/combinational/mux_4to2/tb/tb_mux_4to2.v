`timescale 1ns/1ps
module tb_mux_4to2;
    reg  I0, I1, I2, I3, S1, S0;
    wire Y;

    integer num_tests = 30;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg expected;
    reg [255:0] cov_bin;
    integer fh;

    integer bins [0:7];

    mux_4to2 dut (.I0(I0), .I1(I1), .I2(I2), .I3(I3), .S1(S1), .S0(S0), .Y(Y));

    task drive_stimulus;
        begin
            I0 = $urandom_range(0, 1);
            I1 = $urandom_range(0, 1);
            I2 = $urandom_range(0, 1);
            I3 = $urandom_range(0, 1);
            S1 = $urandom_range(0, 1);
            S0 = $urandom_range(0, 1);
            #1;
        end
    endtask

    task check_result;
        begin
            case ({S1, S0})
                2'b00: expected = I0;
                2'b01: expected = I1;
                2'b10: expected = I2;
                2'b11: expected = I3;
            endcase
            if (Y !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d | Y=%0d exp=%0d", i, Y, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        integer idx;
        begin
            idx = ({S1, S0} * 2) + expected;
            bins[idx] = bins[idx] + 1;
            case (idx)
                0: cov_bin = "S00_I0_0";
                1: cov_bin = "S00_I0_1";
                2: cov_bin = "S01_I1_0";
                3: cov_bin = "S01_I1_1";
                4: cov_bin = "S10_I2_0";
                5: cov_bin = "S10_I2_1";
                6: cov_bin = "S11_I3_0";
                7: cov_bin = "S11_I3_1";
            endcase
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "mux_4to2,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, I0, I1, I2, I3, S1, S0, Y, expected, (Y === expected), cov_bin);
        end
    endtask

    initial begin
        for (i = 0; i < 8; i = i + 1) bins[i] = 0;
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] mux_4to2 | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/mux_4to2/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,I0,I1,I2,I3,S1,S0,Y,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] mux_4to2 | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
