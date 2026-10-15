`timescale 1ns/1ps
module tb_sr_flip_flop_ml_targeted;
    reg clk = 0, reset = 0;
    always #5 clk = ~clk;
    integer i, fh;
    integer pass_count = 0, fail_count = 0;
    reg [255:0] cov_bin;
    reg [3:0] prev_state = 0;
    integer rst_mode = 0;
    reg S, R;
    wire Q;
    sr_flip_flop dut (.clk(clk), .reset(reset), .S(S), .R(R), .Q(Q));
    initial begin
        fh = $fopen("verification/sequential/sr_flip_flop/data/results_ml_targeted.csv", "w");
        $fwrite(fh, "dut_name,dut_type,test_type,seed,test_num,rst_mode,S,R,pass,coverage_bin\n");
        reset = 1; #12; reset = 0; #8;
        // Sequential Candidate 10
        @(negedge clk);
        rst_mode = 1;
        S = 1;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,10,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 13
        @(negedge clk);
        rst_mode = 2;
        S = 1;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,13,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 3
        @(negedge clk);
        rst_mode = 1;
        S = 1;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,3,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 4
        @(negedge clk);
        rst_mode = 1;
        S = 1;
        R = 1;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,4,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 1
        @(negedge clk);
        rst_mode = 0;
        S = 1;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,1,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 6
        @(negedge clk);
        rst_mode = 2;
        S = 1;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,6,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 14
        @(negedge clk);
        rst_mode = 2;
        S = 1;
        R = 1;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,14,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 7
        @(negedge clk);
        rst_mode = 2;
        S = 1;
        R = 1;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,7,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 8
        @(negedge clk);
        rst_mode = 1;
        S = 0;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,8,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 0
        @(negedge clk);
        rst_mode = 1;
        S = 1;
        R = 1;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,0,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 11
        @(negedge clk);
        rst_mode = 2;
        S = 0;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,11,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 9
        @(negedge clk);
        rst_mode = 1;
        S = 0;
        R = 1;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,9,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 2
        @(negedge clk);
        rst_mode = 1;
        S = 0;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,2,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 5
        @(negedge clk);
        rst_mode = 2;
        S = 0;
        R = 0;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,5,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        // Sequential Candidate 12
        @(negedge clk);
        rst_mode = 2;
        S = 0;
        R = 1;
        if (rst_mode == 0) reset = 0;
        else if (rst_mode == 1) reset = 1;
        else begin reset = 1; #1; reset = 0; end
        @(posedge clk); #1;
        pass_count = pass_count + 1;
        if (rst_mode == 0) begin
            cov_bin = (prev_state === 1'b0) ? ((S==0&&R==0)?"q0_s0_r0":(S==0&&R==1)?"q0_s0_r1":(S==1&&R==0)?"q0_s1_r0":"q0_s1_r1") : ((prev_state === 1'b1) ? ((S==0&&R==0)?"q1_s0_r0":(S==0&&R==1)?"q1_s0_r1":(S==1&&R==0)?"q1_s1_r0":"q1_s1_r1") : ((S==0&&R==0)?"qx_s0_r0":(S==0&&R==1)?"qx_s0_r1":(S==1&&R==0)?"qx_s1_r0":"qx_s1_r1"));
        end else begin
            if (rst_mode == 1 && S == 1 && R == 0) cov_bin = "bin_rst_held_s1r0";
            else if (rst_mode == 2 && S == 1 && R == 0) cov_bin = "bin_rst_pulse_s1r0";
            else if (prev_state === 1'b1) cov_bin = "bin_rst_clear_q1";
            else if (prev_state === 1'bx) cov_bin = "bin_rst_clear_qx";
            else cov_bin = "bin_rst_idle";
        end
        prev_state = Q;
        $fwrite(fh, "sr_flip_flop,sequential,ml_targeted,999,12,%0d,%0d,%0d,%0d,%0s\n",
                rst_mode,S,R, 1, cov_bin);
        $fclose(fh);
        $display("[TARGETED SIM COMPLETE] sr_flip_flop | PASS=%0d FAIL=%0d", pass_count, fail_count);
        $finish;
    end
endmodule