set_property -dict {PACKAGE_PIN W5}  [get_ports clk]
create_clock -period 10.000 [get_ports clk]

set_property -dict {PACKAGE_PIN T18} [get_ports btnU]
set_property -dict {PACKAGE_PIN U17} [get_ports btnD]
set_property -dict {PACKAGE_PIN U18} [get_ports btnC]

set_property -dict {PACKAGE_PIN W7} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN W6} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN U8} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN V8} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN U5} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN V5} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN U7} [get_ports {seg[6]}]
set_property -dict {PACKAGE_PIN V7} [get_ports dp]

set_property -dict {PACKAGE_PIN U2} [get_ports {an[0]}]
set_property -dict {PACKAGE_PIN U4} [get_ports {an[1]}]
set_property -dict {PACKAGE_PIN V4} [get_ports {an[2]}]
set_property -dict {PACKAGE_PIN W4} [get_ports {an[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {clk btnU btnD btnC dp seg[*] an[*]}]
