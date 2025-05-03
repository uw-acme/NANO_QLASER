onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/clk
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reset
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/busy
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cnt_time
add wave -noupdate -radix binary /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_addr
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_wdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_wr
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_sel
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_rdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_rdata_dv
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_addra
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_dina
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_douta
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_we
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_state
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pc
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_addrb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_doutb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_time
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_sizes
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_factors
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_flattop
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {277726970613 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 99
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
configure wave -timelineunits fs
update
WaveRestoreZoom {277686713216 fs} {277803286784 fs}
