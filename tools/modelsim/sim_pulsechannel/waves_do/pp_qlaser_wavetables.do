onerror {resume}
quietly virtual signal -install /qlaser_dacs_pulse_tb/u_dac_pulse { /qlaser_dacs_pulse_tb/u_dac_pulse/reg_pulse_time(31 downto 16)} reg_pulse_time_31_16
quietly virtual signal -install /qlaser_dacs_pulse_tb/u_dac_pulse { /qlaser_dacs_pulse_tb/u_dac_pulse/reg_pulse_time(15 downto 0)} reg_pulse_time_15_0
quietly WaveActivateNextPane {} 0
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/clk
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/start
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/reset
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/busy
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/cnt_time
add wave -noupdate -radix binary /qlaser_dacs_pulse_tb/u_dac_pulse/cpu_addr
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/cpu_wdata
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/cpu_wr
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/cpu_sel
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/cpu_rdata
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/cpu_rdata_dv
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/ram_pulse_addra
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/ram_pulse_dina
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/ram_pulse_douta
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/ram_pulse_we
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/sm_state
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/pc
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/ram_pulse_addrb
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/ram_pulse_doutb
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/reg_pulse_time
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/reg_scale_gain
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/reg_scale_time
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/reg_wave_start_addr
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/reg_wave_length
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/reg_pulse_flattop
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/ram_waveform_wea
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/ram_waveform_addra
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/ram_waveform_dina
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/ram_waveform_douta
add wave -noupdate -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/ram_waveform_addrb
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/ram_waveform_doutb
add wave -noupdate -radix hexadecimal /qlaser_dacs_pulse_tb/u_dac_pulse/sm_wavedata
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/sm_wavedata_dv
add wave -noupdate -format Analog-Step -height 74 -max 204.0 -radix unsigned /qlaser_dacs_pulse_tb/u_dac_pulse/axis_tdata
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/axis_tvalid
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/axis_tlast
add wave -noupdate /qlaser_dacs_pulse_tb/u_dac_pulse/axis_tready
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {62275000000 fs} 0}
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
WaveRestoreZoom {61852729312 fs} {62817270688 fs}
