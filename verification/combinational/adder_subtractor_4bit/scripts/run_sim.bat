@echo off
iverilog -o sim_adder_subtractor_4bit.vvp rtl/combinational/adder_subtractor_4bit/adder_subtractor_4bit.v verification/combinational/adder_subtractor_4bit/tb/tb_adder_subtractor_4bit.v
if errorlevel 1 exit /b 1
vvp sim_adder_subtractor_4bit.vvp +SEED=%1 +TESTS=%2
