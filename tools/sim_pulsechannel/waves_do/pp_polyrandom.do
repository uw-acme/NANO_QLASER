onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Analog-Step -height 74 -max 71808.899999999994 /tb_pulse_channel_random_polynomials/wave_values
add wave -noupdate /tb_pulse_channel_random_polynomials/start_times
add wave -noupdate /tb_pulse_channel_random_polynomials/pulse_times
add wave -noupdate /tb_pulse_channel_random_polynomials/start_idx
add wave -noupdate /tb_pulse_channel_random_polynomials/pulse_delays
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
quietly wave cursor active 0
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
WaveRestoreZoom {0 fs} {109147500 ps}
