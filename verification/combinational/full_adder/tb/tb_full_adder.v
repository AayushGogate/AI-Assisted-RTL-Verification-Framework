`timescale 1ns/1ps
module tb_full_adder;
    reg  A, B, Cin;
    wire S, Cout;

    integer num_tests = 20;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg [1:0] expected;
    reg [255:0] cov_bin;
    integer fh;
    integer bins [0:7];

    full_adder dut (.A(A), .B(B), .Cin(Cin), .S(S), .Cout(Cout));

    task drive_stimulus;
        begin
            A = $urandom_range(0, 1);
            B = $urandom_range(0, 1);
            Cin = $urandom_range(0, 1);
            #1;
        end
    endtask

    task check_result;
        begin
            expected = A + B + Cin;
            if ({Cout, S} !== expected) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d A=%0d B=%0d Cin=%0d | Cout=%0d S=%0d exp=%0d",
                         i, A, B, Cin, Cout, S, expected);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        integer idx;
        begin
            idx = {A, B, Cin};
            bins[idx] = bins[idx] + 1;
            case (idx)
                0: cov_bin = "A0_B0_Cin0";
                1: cov_bin = "A0_B0_Cin1";
                2: cov_bin = "A0_B1_Cin0";
                3: cov_bin = "A0_B1_Cin1";
                4: cov_bin = "A1_B0_Cin0";
                5: cov_bin = "A1_B0_Cin1";
                6: cov_bin = "A1_B1_Cin0";
                7: cov_bin = "A1_B1_Cin1";
            endcase
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "full_adder,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, A, B, Cin, S, Cout, expected, ({Cout, S} === expected), cov_bin);
        end
    endtask

    initial begin
        for (i = 0; i < 8; i = i + 1) bins[i] = 0;
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] full_adder | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/full_adder/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,Cin,S,Cout,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] full_adder | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
