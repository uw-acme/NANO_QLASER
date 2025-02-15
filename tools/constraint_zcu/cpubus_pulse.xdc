

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 4 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER true [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 131072 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL true [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list u_ps2/ps1_i/zynq_ultra_ps_e_0/U0/pl_clk0]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 3 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {arr_cpu_dout_dv[0]} {arr_cpu_dout_dv[1]} {arr_cpu_dout_dv[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 2 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {dacs_pulse_axis_treadys[0]} {dacs_pulse_axis_treadys[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 16 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {fifo_axis0_tdata[0]} {fifo_axis0_tdata[1]} {fifo_axis0_tdata[2]} {fifo_axis0_tdata[3]} {fifo_axis0_tdata[4]} {fifo_axis0_tdata[5]} {fifo_axis0_tdata[6]} {fifo_axis0_tdata[7]} {fifo_axis0_tdata[8]} {fifo_axis0_tdata[9]} {fifo_axis0_tdata[10]} {fifo_axis0_tdata[11]} {fifo_axis0_tdata[12]} {fifo_axis0_tdata[13]} {fifo_axis0_tdata[14]} {fifo_axis0_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 23 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {arr_cpu_dout[1][0]} {arr_cpu_dout[1][1]} {arr_cpu_dout[1][2]} {arr_cpu_dout[1][3]} {arr_cpu_dout[1][4]} {arr_cpu_dout[1][6]} {arr_cpu_dout[1][7]} {arr_cpu_dout[1][10]} {arr_cpu_dout[1][11]} {arr_cpu_dout[1][14]} {arr_cpu_dout[1][15]} {arr_cpu_dout[1][16]} {arr_cpu_dout[1][18]} {arr_cpu_dout[1][19]} {arr_cpu_dout[1][22]} {arr_cpu_dout[1][23]} {arr_cpu_dout[1][25]} {arr_cpu_dout[1][26]} {arr_cpu_dout[1][27]} {arr_cpu_dout[1][28]} {arr_cpu_dout[1][29]} {arr_cpu_dout[1][30]} {arr_cpu_dout[1][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 2 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {dacs_pulse_axis_tlasts[0]} {dacs_pulse_axis_tlasts[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 16 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {fifo_axis1_tdata[0]} {fifo_axis1_tdata[1]} {fifo_axis1_tdata[2]} {fifo_axis1_tdata[3]} {fifo_axis1_tdata[4]} {fifo_axis1_tdata[5]} {fifo_axis1_tdata[6]} {fifo_axis1_tdata[7]} {fifo_axis1_tdata[8]} {fifo_axis1_tdata[9]} {fifo_axis1_tdata[10]} {fifo_axis1_tdata[11]} {fifo_axis1_tdata[12]} {fifo_axis1_tdata[13]} {fifo_axis1_tdata[14]} {fifo_axis1_tdata[15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 2 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {dacs_dc_busy[2]} {dacs_dc_busy[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 3 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {arr_cpu_dout[3][0]} {arr_cpu_dout[3][1]} {arr_cpu_dout[3][4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 2 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {dacs_pulse_axis_tvalids[0]} {dacs_pulse_axis_tvalids[1]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 16 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {dacs_pulse_axis_tdatas[0][0]} {dacs_pulse_axis_tdatas[0][1]} {dacs_pulse_axis_tdatas[0][2]} {dacs_pulse_axis_tdatas[0][3]} {dacs_pulse_axis_tdatas[0][4]} {dacs_pulse_axis_tdatas[0][5]} {dacs_pulse_axis_tdatas[0][6]} {dacs_pulse_axis_tdatas[0][7]} {dacs_pulse_axis_tdatas[0][8]} {dacs_pulse_axis_tdatas[0][9]} {dacs_pulse_axis_tdatas[0][10]} {dacs_pulse_axis_tdatas[0][11]} {dacs_pulse_axis_tdatas[0][12]} {dacs_pulse_axis_tdatas[0][13]} {dacs_pulse_axis_tdatas[0][14]} {dacs_pulse_axis_tdatas[0][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 3 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {arr_cpu_dout[0][0]} {arr_cpu_dout[0][2]} {arr_cpu_dout[0][3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 16 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {dacs_pulse_axis_tdatas[1][0]} {dacs_pulse_axis_tdatas[1][1]} {dacs_pulse_axis_tdatas[1][2]} {dacs_pulse_axis_tdatas[1][3]} {dacs_pulse_axis_tdatas[1][4]} {dacs_pulse_axis_tdatas[1][5]} {dacs_pulse_axis_tdatas[1][6]} {dacs_pulse_axis_tdatas[1][7]} {dacs_pulse_axis_tdatas[1][8]} {dacs_pulse_axis_tdatas[1][9]} {dacs_pulse_axis_tdatas[1][10]} {dacs_pulse_axis_tdatas[1][11]} {dacs_pulse_axis_tdatas[1][12]} {dacs_pulse_axis_tdatas[1][13]} {dacs_pulse_axis_tdatas[1][14]} {dacs_pulse_axis_tdatas[1][15]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 15 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {ps_cpu_addr[2]} {ps_cpu_addr[3]} {ps_cpu_addr[4]} {ps_cpu_addr[5]} {ps_cpu_addr[6]} {ps_cpu_addr[7]} {ps_cpu_addr[8]} {ps_cpu_addr[9]} {ps_cpu_addr[10]} {ps_cpu_addr[11]} {ps_cpu_addr[12]} {ps_cpu_addr[13]} {ps_cpu_addr[14]} {ps_cpu_addr[16]} {ps_cpu_addr[17]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 32 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {ps_cpu_wdata[0]} {ps_cpu_wdata[1]} {ps_cpu_wdata[2]} {ps_cpu_wdata[3]} {ps_cpu_wdata[4]} {ps_cpu_wdata[5]} {ps_cpu_wdata[6]} {ps_cpu_wdata[7]} {ps_cpu_wdata[8]} {ps_cpu_wdata[9]} {ps_cpu_wdata[10]} {ps_cpu_wdata[11]} {ps_cpu_wdata[12]} {ps_cpu_wdata[13]} {ps_cpu_wdata[14]} {ps_cpu_wdata[15]} {ps_cpu_wdata[16]} {ps_cpu_wdata[17]} {ps_cpu_wdata[18]} {ps_cpu_wdata[19]} {ps_cpu_wdata[20]} {ps_cpu_wdata[21]} {ps_cpu_wdata[22]} {ps_cpu_wdata[23]} {ps_cpu_wdata[24]} {ps_cpu_wdata[25]} {ps_cpu_wdata[26]} {ps_cpu_wdata[27]} {ps_cpu_wdata[28]} {ps_cpu_wdata[29]} {ps_cpu_wdata[30]} {ps_cpu_wdata[31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 5 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {pulse_errors[0][0]} {pulse_errors[0][1]} {pulse_errors[0][2]} {pulse_errors[0][3]} {pulse_errors[0][4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 5 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {pulse_errors[1][0]} {pulse_errors[1][1]} {pulse_errors[1][2]} {pulse_errors[1][3]} {pulse_errors[1][4]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 19 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[1]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[2]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[3]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[4]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[5]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[6]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[7]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[8]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[9]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[10]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[11]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[12]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[13]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[14]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[15]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[16]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[17]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[18]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/sm_state2[19]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 8 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {u_dacs_pulse/g_ch[0].ch_full.u_ch/pc[2]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/pc[3]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/pc[4]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/pc[5]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/pc[6]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/pc[7]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/pc[8]} {u_dacs_pulse/g_ch[0].ch_full.u_ch/pc[9]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list fifo_almost_empty0]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list fifo_almost_empty1]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list fifo_axis0_tready]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list fifo_axis0_tvalid]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list u_dac_pulse/pulse2pmod0_busy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list u_dac_pulse/pulse2pmod1_busy]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list trigger_dacs_pulse]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]
