@echo off
iverilog -o sim_pipo.vvp ../../../rtl/sequential/pipo/pipo.v tb/tb_pipo.v
if errorlevel 1 exit /b 1
vvp sim_pipo.vvp +SEED=%1 +TESTS=%2
