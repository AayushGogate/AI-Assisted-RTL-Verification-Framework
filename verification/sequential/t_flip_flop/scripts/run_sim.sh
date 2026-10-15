#!/bin/bash
iverilog -o sim_t_flip_flop.vvp ../../../rtl/sequential/t_flip_flop/t_flip_flop.v tb/tb_t_flip_flop.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_t_flip_flop.vvp +SEED=$1 +TESTS=$2
