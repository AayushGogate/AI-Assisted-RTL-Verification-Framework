@echo off
iverilog -o sim_decoder_2to4.vvp rtl/combinational/decoder_2to4/decoder_2to4.v verification/combinational/decoder_2to4/tb/tb_decoder_2to4.v
if errorlevel 1 exit /b 1
vvp sim_decoder_2to4.vvp +SEED=%1 +TESTS=%2
