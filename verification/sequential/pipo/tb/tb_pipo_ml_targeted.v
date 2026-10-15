`timescale 1ns/1ps
module tb_pipo_ml_targeted;
    reg clk = 0, reset = 0;
    always #5 clk = ~clk;
    integer i, fh;
    integer pass_count = 0, fail_count = 0;
    reg [255:0] cov_bin;
    reg [3:0] prev_state = 0;
    integer rst_mode = 0;
    reg [3:0] parallel_in;
    wire [3:0] parallel_out;
    pipo dut (.clk(clk), .reset(reset), .parallel_in(parallel_in), .parallel_out(parallel_out));
    initial begin
        fh = $fopen("verification/sequential/pipo/data/results_ml_targeted.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,rst_mode,parallel_in,pass,coverage_bin\n");
        reset = 1; #12; reset = 0; #8;
        // Sequential Candidate 174
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,174,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 27
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,27,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 136
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,136,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 330
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,330,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 251
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,251,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 492
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,492,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 259
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 15;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,259,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 412
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,412,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 341
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 15;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,341,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 146
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 15;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,146,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 213
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,213,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 289
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,289,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 454
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,454,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 373
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,373,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 578
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,578,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 382
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 15;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,382,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 236
        @(negedge clk);
        rst_mode = 2;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,236,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 586
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 15;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,586,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 297
        @(negedge clk);
        rst_mode = 0;
        parallel_in = 15;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,297,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        // Sequential Candidate 357
        @(negedge clk);
        rst_mode = 2;
        parallel_in = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            if (parallel_in == 0) cov_bin = "bin_load_zero";
            else if (parallel_in == 15) cov_bin = "bin_load_ones";
            else if (parallel_in == 5 || parallel_in == 10) cov_bin = "bin_load_alt";
            else if (parallel_in == 1 || parallel_in == 2 || parallel_in == 4 || parallel_in == 8) cov_bin = "bin_load_onehot";
            else if (parallel_in == prev_state) cov_bin = "bin_hold_same";
            else if (parallel_in == ((~prev_state) & 4'hF)) cov_bin = "bin_all_flip";
            else cov_bin = "bin_load_other";
        end else begin
            if (rst_mode == 1 && parallel_in != 0) cov_bin = "bin_rst_held_nonzero";
            else if (rst_mode == 2 && parallel_in != 0) cov_bin = "bin_rst_pulse_nonzero";
            else if (prev_state != 0) cov_bin = "bin_rst_clear_nonzero";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = parallel_out;
        $fwrite(fh, "pipo,sequential,ml_targeted,999,357,%0d,%0d,%0d,%0s\n",
                rst_mode,parallel_in, 1, cov_bin);
        $fclose(fh);
        $display("[TARGETED SIM COMPLETE] pipo | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule