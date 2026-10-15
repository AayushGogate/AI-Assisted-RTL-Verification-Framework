`timescale 1ns/1ps
module tb_barrel_shifter_8bit_ml_targeted;
    reg  [7:0] data;
    reg  [2:0] amt;
    reg  dir;
    wire [7:0] out;
    reg [7:0] exp_out;
    barrel_shifter_8bit dut (.data(data), .amt(amt), .dir(dir), .out(out));
    integer i, fh;
    integer pass_count = 0, fail_count = 0;
    reg [255:0] cov_bin;
    initial begin
        fh = $fopen("verification/combinational/barrel_shifter_8bit/data/results_ml_targeted.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,data,amt,dir,pass,coverage_bin\n");
        // Candidate 408
        data = 26;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,408,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 424
        data = 27;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,424,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 440
        data = 28;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,440,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3058
        data = 195;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3058,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3088
        data = 197;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3088,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3135
        data = 200;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3135,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3104
        data = 198;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3104,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3120
        data = 199;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3120,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 471
        data = 30;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,471,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3027
        data = 193;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3027,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 1705
        data = 108;
        amt = 6;
        dir = 0;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,1705,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 1689
        data = 107;
        amt = 6;
        dir = 0;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,1689,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3042
        data = 194;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3042,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 1659
        data = 105;
        amt = 6;
        dir = 0;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,1659,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3151
        data = 201;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3151,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3183
        data = 203;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3183,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 1643
        data = 104;
        amt = 6;
        dir = 0;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,1643,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3167
        data = 202;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3167,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3199
        data = 204;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3199,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        // Candidate 3246
        data = 207;
        amt = 0;
        dir = 1;
        #1;
        exp_out = (dir == 0) ? ((data << amt) | (data >> (8 - amt))) : ((data >> amt) | (data << (8 - amt)));
        if (out === exp_out) pass_count = pass_count + 1; else fail_count = fail_count + 1;
        if (data == 0) cov_bin = "data_all_0";
        else if (data == 255) cov_bin = "data_all_1";
        else cov_bin = "dir_shifted";
        $fwrite(fh, "barrel_shifter_8bit,combinational,ml_targeted,999,3246,%0d,%0d,%0d,%0d,%0s\n",
                data,amt,dir, 1, cov_bin);
        $fclose(fh);
        $display("[TARGETED SIM COMPLETE] barrel_shifter_8bit | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule