#!/bin/bash
iverilog -o sim_multiplier_4bit.vvp rtl/combinational/multiplier_4bit/multiplier_4bit.v verification/combinational/multiplier_4bit/tb/tb_multiplier_4bit.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_multiplier_4bit.vvp +SEED=$1 +TESTS=$2
