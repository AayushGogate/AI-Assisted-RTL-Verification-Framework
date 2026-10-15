#!/bin/bash
iverilog -o sim_pipo.vvp ../../../rtl/sequential/pipo/pipo.v tb/tb_pipo.v
if [ $? -ne 0 ]; then exit 1; fi
vvp sim_pipo.vvp +SEED=$1 +TESTS=$2
