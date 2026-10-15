@echo off
iverilog -o sim_mux_4to2.vvp rtl/combinational/mux_4to2/mux_4to2.v verification/combinational/mux_4to2/tb/tb_mux_4to2.v
if errorlevel 1 exit /b 1
vvp sim_mux_4to2.vvp +SEED=%1 +TESTS=%2
