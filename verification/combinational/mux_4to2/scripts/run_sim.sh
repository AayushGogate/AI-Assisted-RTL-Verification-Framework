#!/bin/bash
iverilog -o sim_mux_4to2.vvp rtl/combinational/mux_4to2/mux_4to2.v verification/combinational/mux_4to2/tb/tb_mux_4to2.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_mux_4to2.vvp +SEED=$1 +TESTS=$2
