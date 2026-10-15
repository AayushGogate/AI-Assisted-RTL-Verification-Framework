@echo off
iverilog -o sim_mux_2to1.vvp rtl/combinational/mux_2to1/mux_2to1.v verification/combinational/mux_2to1/tb/tb_mux_2to1.v
if errorlevel 1 exit /b 1
vvp sim_mux_2to1.vvp +SEED=%1 +TESTS=%2
