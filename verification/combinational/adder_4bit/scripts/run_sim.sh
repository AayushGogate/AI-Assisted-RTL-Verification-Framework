#!/bin/bash
iverilog -o sim_adder_4bit.vvp rtl/combinational/adder_4bit/adder_4bit.v verification/combinational/adder_4bit/tb/tb_adder_4bit.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_adder_4bit.vvp +SEED=$1 +TESTS=$2
