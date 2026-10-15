#!/bin/bash
iverilog -o sim_comparator_2bit.vvp rtl/combinational/comparator_2bit/comparator_2bit.v verification/combinational/comparator_2bit/tb/tb_comparator_2bit.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_comparator_2bit.vvp +SEED=$1 +TESTS=$2
