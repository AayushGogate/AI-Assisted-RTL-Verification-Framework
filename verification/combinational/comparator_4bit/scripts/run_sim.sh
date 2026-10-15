#!/bin/bash
iverilog -o sim_comparator_4bit.vvp rtl/combinational/comparator_4bit/comparator_4bit.v verification/combinational/comparator_4bit/tb/tb_comparator_4bit.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_comparator_4bit.vvp +SEED=$1 +TESTS=$2
