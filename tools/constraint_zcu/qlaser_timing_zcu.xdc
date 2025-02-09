## 125MHz Clock from Ethernet PHY
# create_clock -period 3.333 -name sys_clk_pin -waveform {0.000 1.667} -add [get_ports p_clk_p]
# create_clock -period 3.333 -name sys_clk_pin -waveform {0.000 1.667} -add [get_ports p_clk_n]

# create_clock -period 10.0 -name pl_clk [get_ports */ps_clk0]










