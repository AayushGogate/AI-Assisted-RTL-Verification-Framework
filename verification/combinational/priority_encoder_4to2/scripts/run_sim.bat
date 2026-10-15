@echo off
iverilog -o sim_priority_encoder_4to2.vvp rtl/combinational/priority_encoder_4to2/priority_encoder_4to2.v verification/combinational/priority_encoder_4to2/tb/tb_priority_encoder_4to2.v
if errorlevel 1 exit /b 1
vvp sim_priority_encoder_4to2.vvp +SEED=%1 +TESTS=%2
