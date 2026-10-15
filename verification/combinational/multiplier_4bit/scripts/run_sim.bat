@echo off
iverilog -o sim_multiplier_4bit.vvp rtl/combinational/multiplier_4bit/multiplier_4bit.v verification/combinational/multiplier_4bit/tb/tb_multiplier_4bit.v
if errorlevel 1 exit /b 1
vvp sim_multiplier_4bit.vvp +SEED=%1 +TESTS=%2
