@echo off
iverilog -o sim_sr_flip_flop.vvp ../../../rtl/sequential/sr_flip_flop/sr_flip_flop.v tb/tb_sr_flip_flop.v
if errorlevel 1 exit /b 1
vvp sim_sr_flip_flop.vvp +SEED=%1 +TESTS=%2
