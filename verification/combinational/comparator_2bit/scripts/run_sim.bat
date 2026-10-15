@echo off
iverilog -o sim_comparator_2bit.vvp rtl/combinational/comparator_2bit/comparator_2bit.v verification/combinational/comparator_2bit/tb/tb_comparator_2bit.v
if errorlevel 1 exit /b 1
vvp sim_comparator_2bit.vvp +SEED=%1 +TESTS=%2
