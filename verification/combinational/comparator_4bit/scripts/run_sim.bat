@echo off
iverilog -o sim_comparator_4bit.vvp rtl/combinational/comparator_4bit/comparator_4bit.v verification/combinational/comparator_4bit/tb/tb_comparator_4bit.v
if errorlevel 1 exit /b 1
vvp sim_comparator_4bit.vvp +SEED=%1 +TESTS=%2
