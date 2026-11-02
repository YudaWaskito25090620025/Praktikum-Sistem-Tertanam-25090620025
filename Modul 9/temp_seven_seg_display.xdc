## =============================================================
## top_pipe2.xdc
## Constraint minimal untuk Prosedur 4 - top-level fixed_mul_pipe2
## langsung (sudah punya port clk sendiri, tanpa wrapper tambahan).
## Sama seperti top_comb_wrapper.xdc: hanya clock yang dikonstrain,
## port a/b/result tidak dipetakan ke pin fisik.
## =============================================================

## Clock 100 MHz (periode 10 ns) -> SAMA dengan top_comb_wrapper.xdc
## agar perbandingan WNS adil (apple-to-apple) pada frekuensi target yang sama
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.000 -waveform {0 5} [get_ports clk]
set_input_delay -clock sys_clk_pin 0.000 [all_inputs -filter {NAME != clk}]
set_output_delay -clock sys_clk_pin 0.000 [all_outputs]