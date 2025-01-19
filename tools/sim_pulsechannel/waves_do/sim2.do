onerror {resume}
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_addrb(19 downto 8)} waveform_addrb
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_dina(31 downto 16)} dina_upper
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_dina(15 downto 0)} dina_lower
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_dina(31 downto 16)} waveform_dina_upper
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_dina(15 downto 0)} waveform_dina_lower
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(15 downto 8)} scale_time_int
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(9 downto 2)} total_pulses
quietly virtual signal -install /tb_cpubus_dacs_pulse_channel/u_dac_pulse { /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pc(9 downto 2)} pc_divide_4
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/clk
add wave -noupdate /tb_cpubus_dacs_pulse_channel/sim_done
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cnt_time
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/start
add wave -noupdate /tb_cpubus_dacs_pulse_channel/wave_values
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tvalid
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tlast
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_state
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_wavedata_dv
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_last
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pc
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pc_divide_4
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written
add wave -noupdate -radix unsigned -childformat {{/tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses(9) -radix unsigned} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses(8) -radix unsigned} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses(7) -radix unsigned} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses(6) -radix unsigned} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses(5) -radix unsigned} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses(4) -radix unsigned} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses(3) -radix unsigned} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses(2) -radix unsigned}} -subitemconfig {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(9) {-radix unsigned} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(8) {-radix unsigned} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(7) {-radix unsigned} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(6) {-radix unsigned} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(5) {-radix unsigned} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(4) {-radix unsigned} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(3) {-radix unsigned} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/pulse_written(2) {-radix unsigned}} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/total_pulses
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/erros
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_state
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_time
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_wave_start_addr
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_wave_length
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_wave_end_addr
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_gain
add wave -noupdate -radix hexadecimal -childformat {{/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(15) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(14) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(13) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(12) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(11) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(10) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(9) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(8) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(7) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(6) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(5) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(4) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(3) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(2) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(1) -radix hexadecimal} {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(0) -radix hexadecimal}} -subitemconfig {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(15) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(14) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(13) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(12) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(11) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(10) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(9) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(8) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(7) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(6) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(5) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(4) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(3) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(2) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(1) {-height 15 -radix hexadecimal} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time(0) {-height 15 -radix hexadecimal}} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_scale_time
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/scale_time_int
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reg_pulse_flattop
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_we
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_addra
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_dina
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_douta
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_addrb
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_doutb
add wave -noupdate -radix unsigned -childformat {{/tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_wea(0) -radix unsigned}} -subitemconfig {/tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_wea(0) {-height 15 -radix unsigned}} /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_wea
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_addra
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/waveform_dina_upper
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/waveform_dina_lower
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_douta
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/waveform_addrb
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_doutb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1385000 ps} 0} {{Cursor 2} {10576092 ps} 0}
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
WaveRestoreZoom {1014273 ps} {2277085 ps}
