#!/bin/bash
iverilog -o sim_full_adder.vvp rtl/combinational/full_adder/full_adder.v verification/combinational/full_adder/tb/tb_full_adder.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_full_adder.vvp +SEED=$1 +TESTS=$2
