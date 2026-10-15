@echo off
iverilog -o sim_full_adder.vvp rtl/combinational/full_adder/full_adder.v verification/combinational/full_adder/tb/tb_full_adder.v
if errorlevel 1 exit /b 1
vvp sim_full_adder.vvp +SEED=%1 +TESTS=%2
