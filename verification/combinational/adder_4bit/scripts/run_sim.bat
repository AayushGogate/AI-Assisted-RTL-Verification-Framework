@echo off
iverilog -o sim_adder_4bit.vvp rtl/combinational/adder_4bit/adder_4bit.v verification/combinational/adder_4bit/tb/tb_adder_4bit.v
if errorlevel 1 exit /b 1
vvp sim_adder_4bit.vvp +SEED=%1 +TESTS=%2
