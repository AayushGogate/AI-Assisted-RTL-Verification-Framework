`timescale 1ns/1ps
module tb_binary_to_gray_3bit;
    reg  [2:0] B;
    wire [2:0] G;

    integer num_tests = 20;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg [2:0] exp_g;
    reg [255:0] cov_bin;
    integer fh;

    binary_to_gray_3bit dut (.B(B), .G(G));

    task drive_stimulus;
        begin
            B = $urandom_range(0, 7);
            #1;
        end
    endtask

    task check_result;
        begin
            exp_g = B ^ (B >> 1);
            if (G !== exp_g) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d B=%0d | G=%0d exp=%0d", i, B, G, exp_g);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            case (B)
                0: cov_bin = "gray_0";
                1: cov_bin = "gray_1";
                2: cov_bin = "gray_2";
                3: cov_bin = "gray_3";
                4: cov_bin = "gray_4";
                5: cov_bin = "gray_5";
                6: cov_bin = "gray_6";
                7: cov_bin = "gray_7";
            endcase
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "binary_to_gray_3bit,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, B, G, exp_g, (G === exp_g), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] binary_to_gray_3bit | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/binary_to_gray_3bit/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,B,G,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] binary_to_gray_3bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
