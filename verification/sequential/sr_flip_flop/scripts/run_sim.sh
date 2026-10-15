#!/bin/bash
iverilog -o sim_sr_flip_flop.vvp ../../../rtl/sequential/sr_flip_flop/sr_flip_flop.v tb/tb_sr_flip_flop.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_sr_flip_flop.vvp +SEED=$1 +TESTS=$2
