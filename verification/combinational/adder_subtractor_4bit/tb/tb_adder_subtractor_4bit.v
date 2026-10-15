`timescale 1ns/1ps
module tb_adder_subtractor_4bit;
    reg  [3:0] A, B;
    reg        sub;
    wire [3:0] Result;
    wire       Cout, Overflow;

    integer num_tests = 60;
    integer seed = 42;
    integer i, dummy;
    integer pass_count = 0, fail_count = 0;
    reg [3:0] exp_res;
    reg       exp_cout, exp_ovf;
    reg [255:0] cov_bin;
    integer fh;

    adder_subtractor_4bit dut (.A(A), .B(B), .sub(sub), .Result(Result), .Cout(Cout), .Overflow(Overflow));

    task drive_stimulus;
        begin
            A = $urandom_range(0, 15);
            B = $urandom_range(0, 15);
            sub = $urandom_range(0, 1);
            #1;
        end
    endtask

    task check_result;
        reg [4:0] s;
        reg [3:0] bx;
        begin
            bx = B ^ {4{sub}};
            s = A + bx + sub;
            exp_res = s[3:0];
            exp_cout = s[4];
            exp_ovf = (A[3] == bx[3]) && (exp_res[3] != A[3]);

            if (Result !== exp_res || Cout !== exp_cout || Overflow !== exp_ovf) begin
                fail_count = fail_count + 1;
                $display("[FAIL] test=%0d A=%0d B=%0d sub=%0d | Res=%0d Cout=%0d Ovf=%0d | expRes=%0d expCout=%0d expOvf=%0d",
                         i, A, B, sub, Result, Cout, Overflow, exp_res, exp_cout, exp_ovf);
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task sample_coverage;
        begin
            if (sub == 0 && A == 0 && B == 0) cov_bin = "add_zero";
            else if (sub == 0 && A == 15 && B == 15) cov_bin = "add_max";
            else if (sub == 1 && A == B) cov_bin = "sub_zero";
            else if (sub == 1 && A == 0 && B == 15) cov_bin = "sub_min_neg";
            else if (exp_ovf && exp_res[3] == 1) cov_bin = "overflow_pos";
            else if (exp_ovf && exp_res[3] == 0) cov_bin = "overflow_neg";
            else if (sub == 0) cov_bin = "normal_add";
            else cov_bin = "normal_sub";
        end
    endtask

    task log_csv_row;
        input integer test_idx;
        begin
            $fwrite(fh, "adder_subtractor_4bit,combinational,crv_baseline,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0d,%0s\n",
                    seed, test_idx, A, B, sub, Result, Cout, Overflow, exp_res,
                    (Result === exp_res && Cout === exp_cout && Overflow === exp_ovf), cov_bin);
        end
    endtask

    initial begin
        if ($value$plusargs("SEED=%d", seed)) begin end
        if ($value$plusargs("TESTS=%d", num_tests)) begin end
        $display("[TB_INIT] adder_subtractor_4bit | SEED=%0d | TESTS=%0d", seed, num_tests);
        dummy = $urandom(seed);

        fh = $fopen("verification/combinational/adder_subtractor_4bit/data/results_crv_baseline.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,A,B,sub,Result,Cout,Overflow,expected,pass,coverage_bin\n");

        for (i = 0; i < num_tests; i = i + 1) begin
            drive_stimulus;
            check_result;
            sample_coverage;
            log_csv_row(i);
        end

        $fclose(fh);
        $display("[TB_DONE] adder_subtractor_4bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule
