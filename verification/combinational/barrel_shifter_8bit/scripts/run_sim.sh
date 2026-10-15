#!/bin/bash
iverilog -o sim_barrel_shifter_8bit.vvp rtl/combinational/barrel_shifter_8bit/barrel_shifter_8bit.v verification/combinational/barrel_shifter_8bit/tb/tb_barrel_shifter_8bit.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_barrel_shifter_8bit.vvp +SEED=$1 +TESTS=$2
