#!/bin/bash
iverilog -o sim_jk_flip_flop.vvp ../../../rtl/sequential/jk_flip_flop/jk_flip_flop.v tb/tb_jk_flip_flop.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_jk_flip_flop.vvp +SEED=$1 +TESTS=$2
