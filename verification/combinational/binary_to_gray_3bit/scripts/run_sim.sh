#!/bin/bash
iverilog -o sim_binary_to_gray_3bit.vvp rtl/combinational/binary_to_gray_3bit/binary_to_gray_3bit.v verification/combinational/binary_to_gray_3bit/tb/tb_binary_to_gray_3bit.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_binary_to_gray_3bit.vvp +SEED=$1 +TESTS=$2
