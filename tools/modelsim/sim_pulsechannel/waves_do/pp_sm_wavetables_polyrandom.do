onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /tb_pulse_channel_random_polynomials/cnt_time
add wave -noupdate -radix unsigned /tb_pulse_channel_random_polynomials/wave_values
add wave -noupdate -radix unsigned /tb_pulse_channel_random_polynomials/u_dac_pulse/axis_tdata
add wave -noupdate /tb_pulse_channel_random_polynomials/u_dac_pulse/axis_tvalid
add wave -noupdate -radix unsigned /tb_pulse_channel_random_polynomials/diffs
add wave -noupdate /tb_pulse_channel_random_polynomials/sm_mode
add wave -noupdate /tb_pulse_channel_random_polynomials/u_dac_pulse/sm_state
add wave -noupdate /tb_pulse_channel_random_polynomials/start_times
add wave -noupdate /tb_pulse_channel_random_polynomials/pulse_times
add wave -noupdate /tb_pulse_channel_random_polynomials/start_idx
add wave -noupdate /tb_pulse_channel_random_polynomials/pulse_delays
add wave -noupdate -radix unsigned /tb_pulse_channel_random_polynomials/u_dac_pulse/reg_pulse_time
add wave -noupdate -radix unsigned /tb_pulse_channel_random_polynomials/u_dac_pulse/reg_wave_start_addr
add wave -noupdate -radix unsigned /tb_pulse_channel_random_polynomials/u_dac_pulse/reg_wave_length
add wave -noupdate -radix hexadecimal /tb_pulse_channel_random_polynomials/u_dac_pulse/reg_wave_end_addr
add wave -noupdate -radix hexadecimal /tb_pulse_channel_random_polynomials/u_dac_pulse/reg_scale_gain
add wave -noupdate -radix hexadecimal /tb_pulse_channel_random_polynomials/u_dac_pulse/reg_scale_time
add wave -noupdate -radix unsigned /tb_pulse_channel_random_polynomials/u_dac_pulse/reg_pulse_flattop
add wave -noupdate /tb_pulse_channel_random_polynomials/fakeram_wt
add wave -noupdate /tb_pulse_channel_random_polynomials/u_dac_pulse/err_addr_of
add wave -noupdate /tb_pulse_channel_random_polynomials/u_dac_pulse/err_invalid_length
add wave -noupdate /tb_pulse_channel_random_polynomials/u_dac_pulse/err_big_step
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {151055000 ps} 0}
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
WaveRestoreZoom {0 ps} {250551 ns}
