@echo off
iverilog -o sim_barrel_shifter_8bit.vvp rtl/combinational/barrel_shifter_8bit/barrel_shifter_8bit.v verification/combinational/barrel_shifter_8bit/tb/tb_barrel_shifter_8bit.v
if errorlevel 1 exit /b 1
vvp sim_barrel_shifter_8bit.vvp +SEED=%1 +TESTS=%2
