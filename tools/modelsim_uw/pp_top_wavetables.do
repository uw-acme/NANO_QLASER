onerror {resume}
quietly virtual signal -install /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch { /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(11 downto 0)} axis_tdata_small
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tlast
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tready
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tvalid
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/busy
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/clk
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cnt_time
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_addr
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata_dv
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_wdata
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/erros
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata_small
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tvalid
add wave -noupdate -format Analog-Step -height 74 -max 1031.0 -radix unsigned -childformat {{/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(15) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(14) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(13) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(12) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(11) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(10) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(9) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(8) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(7) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(6) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(5) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(4) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(3) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(2) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(1) -radix unsigned} {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(0) -radix unsigned}} -subitemconfig {/tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(15) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(14) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(13) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(12) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(11) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(10) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(9) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(8) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(7) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(6) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(5) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(4) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(3) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(2) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(1) {-height 15 -radix unsigned} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(0) {-height 15 -radix unsigned}} /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_state
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/pc
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/pulse_written
add wave -noupdate /tb_qlaser_top/u_qlaser_top/trigger_dacs_pulse
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fifo/almost_full
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_axi0_fifo/m_axis_tdata
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fifo/m_axis_tlast
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fifo/m_axis_tready
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fifo/m_axis_tvalid
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fif1/almost_empty
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fif1/almost_full
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_axi0_fif1/m_axis_tdata
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fif1/m_axis_tlast
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fif1/m_axis_tready
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_axi0_fif1/m_axis_tvalid
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(1)/ch_full/u_ch/axis_tdata
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(1)/ch_full/u_ch/axis_tlast
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(1)/ch_full/u_ch/axis_tready
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(1)/ch_full/u_ch/axis_tvalid
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {68765000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {412566 ns}
