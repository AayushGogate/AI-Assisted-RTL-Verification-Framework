#!/bin/bash
iverilog -o sim_adder_subtractor_4bit.vvp rtl/combinational/adder_subtractor_4bit/adder_subtractor_4bit.v verification/combinational/adder_subtractor_4bit/tb/tb_adder_subtractor_4bit.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_adder_subtractor_4bit.vvp +SEED=$1 +TESTS=$2
