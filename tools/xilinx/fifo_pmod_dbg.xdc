create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 131072 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list u_ps2/ps1_i/zynq_ultra_ps_e_0/U0/pl_clk0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 16 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {dacs_pulse_axis_tdatas[1][0]} {dacs_pulse_axis_tdatas[1][1]} {dacs_pulse_axis_tdatas[1][2]} {dacs_pulse_axis_tdatas[1][3]} {dacs_pulse_axis_tdatas[1][4]} {dacs_pulse_axis_tdatas[1][5]} {dacs_pulse_axis_tdatas[1][6]} {dacs_pulse_axis_tdatas[1][7]} {dacs_pulse_axis_tdatas[1][8]} {dacs_pulse_axis_tdatas[1][9]} {dacs_pulse_axis_tdatas[1][10]} {dacs_pulse_axis_tdatas[1][11]} {dacs_pulse_axis_tdatas[1][12]} {dacs_pulse_axis_tdatas[1][13]} {dacs_pulse_axis_tdatas[1][14]} {dacs_pulse_axis_tdatas[1][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {dacs_pulse_axis_tvalids[0]} {dacs_pulse_axis_tvalids[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {fifo_axis1_tdata[0]} {fifo_axis1_tdata[1]} {fifo_axis1_tdata[2]} {fifo_axis1_tdata[3]} {fifo_axis1_tdata[4]} {fifo_axis1_tdata[5]} {fifo_axis1_tdata[6]} {fifo_axis1_tdata[7]} {fifo_axis1_tdata[8]} {fifo_axis1_tdata[9]} {fifo_axis1_tdata[10]} {fifo_axis1_tdata[11]} {fifo_axis1_tdata[12]} {fifo_axis1_tdata[13]} {fifo_axis1_tdata[14]} {fifo_axis1_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 16 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {fifo_axis0_tdata[0]} {fifo_axis0_tdata[1]} {fifo_axis0_tdata[2]} {fifo_axis0_tdata[3]} {fifo_axis0_tdata[4]} {fifo_axis0_tdata[5]} {fifo_axis0_tdata[6]} {fifo_axis0_tdata[7]} {fifo_axis0_tdata[8]} {fifo_axis0_tdata[9]} {fifo_axis0_tdata[10]} {fifo_axis0_tdata[11]} {fifo_axis0_tdata[12]} {fifo_axis0_tdata[13]} {fifo_axis0_tdata[14]} {fifo_axis0_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 16 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {dacs_pulse_axis_tdatas[0][0]} {dacs_pulse_axis_tdatas[0][1]} {dacs_pulse_axis_tdatas[0][2]} {dacs_pulse_axis_tdatas[0][3]} {dacs_pulse_axis_tdatas[0][4]} {dacs_pulse_axis_tdatas[0][5]} {dacs_pulse_axis_tdatas[0][6]} {dacs_pulse_axis_tdatas[0][7]} {dacs_pulse_axis_tdatas[0][8]} {dacs_pulse_axis_tdatas[0][9]} {dacs_pulse_axis_tdatas[0][10]} {dacs_pulse_axis_tdatas[0][11]} {dacs_pulse_axis_tdatas[0][12]} {dacs_pulse_axis_tdatas[0][13]} {dacs_pulse_axis_tdatas[0][14]} {dacs_pulse_axis_tdatas[0][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 2 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {dacs_pulse_axis_tlasts[0]} {dacs_pulse_axis_tlasts[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 2 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {dacs_pulse_axis_treadys[0]} {dacs_pulse_axis_treadys[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 1 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list fifo_almost_empty0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 1 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list fifo_almost_empty1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 1 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list fifo_axis0_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 1 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list fifo_axis0_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 1 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list fifo_axis0_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list fifo_axis1_tlast]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list fifo_axis1_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list fifo_axis1_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list p2p0_busy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list p2p1_busy]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
