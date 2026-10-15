@echo off
iverilog -o sim_d_flip_flop.vvp ../../../rtl/sequential/d_flip_flop/d_flip_flop.v tb/tb_d_flip_flop.v
if errorlevel 1 exit /b 1
vvp sim_d_flip_flop.vvp +SEED=%1 +TESTS=%2
