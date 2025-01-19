onerror {resume}
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_time(31 downto 16)} reg_pulse_time_31_16
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_time(15 downto 0)} reg_pulse_time_15_0
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/clk
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/start
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
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_state_d1
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pc
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_addrb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_doutb
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_time
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_gain
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_wave_start_addr
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_wave_length
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_wave_end_addr
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_flattop
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_wea
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_addra
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_dina
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_douta
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cnt_addr
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cnt_wave_top
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cnt_wave_len
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/wave_last_addr
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_addrb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_doutb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_wavedata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_wavedata_dv
add wave -noupdate -format Analog-Step -height 74 -max 70.0 -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tvalid
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tlast
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tready
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/done_seq
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {62521930491 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 163
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
WaveRestoreZoom {62366292805 fs} {63694887423 fs}
