onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/reset
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/clk
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/enable
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/start
add wave -noupdate -radix unsigned /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cnt_time
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/busy
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_addr
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_wdata
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_wr
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_sel
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_rdata
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_rdata_dv
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tready
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tdata
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tvalid
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/axis_tlast
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_addra
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_dina
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_douta
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_we
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_addrb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_pulse_doutb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_rdata_dv_e1
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/cpu_rdata_ramsel
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_ena
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_wea
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_addra
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_dina
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_douta
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_enb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_web
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_addrb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_dinb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/ram_waveform_doutb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_state
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_wavedata
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_wavedata_dv
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/sm_busy
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_wr_en
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_full
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_empty
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_wr_rst_busy
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_rd_rst_busy
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_rd_en
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_wr_ack
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_overflow
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_valid
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/fifo_underflow
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/start_d1
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dac_pulse/enable_d1
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
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
configure wave -timelineunits fs
update
WaveRestoreZoom {0 fs} {434658 ns}
