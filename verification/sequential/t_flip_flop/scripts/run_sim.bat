@echo off
iverilog -o sim_t_flip_flop.vvp ../../../rtl/sequential/t_flip_flop/t_flip_flop.v tb/tb_t_flip_flop.v
if errorlevel 1 exit /b 1
vvp sim_t_flip_flop.vvp +SEED=%1 +TESTS=%2
