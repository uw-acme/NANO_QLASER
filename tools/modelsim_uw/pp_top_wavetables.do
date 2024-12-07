onerror {resume}
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
add wave -noupdate -format Analog-Step -height 74 -max 1031.0 -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata
add wave -noupdate /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_state
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/pc
add wave -noupdate -radix unsigned /tb_qlaser_top/u_qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/pulse_written
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
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
WaveRestoreZoom {0 ps} {344253 ns}
