onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_cpubus_dacs_pulse_channel/ADR_RAM_PULSE
add wave -noupdate /tb_cpubus_dacs_pulse_channel/ADR_RAM_WAVE
add wave -noupdate /tb_cpubus_dacs_pulse_channel/CLK_FREQ_MHZ
add wave -noupdate /tb_cpubus_dacs_pulse_channel/CLK_PER
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/axis_tdatas
add wave -noupdate /tb_cpubus_dacs_pulse_channel/axis_tlasts
add wave -noupdate /tb_cpubus_dacs_pulse_channel/axis_treadys
add wave -noupdate /tb_cpubus_dacs_pulse_channel/axis_tvalids
add wave -noupdate /tb_cpubus_dacs_pulse_channel/busy
add wave -noupdate /tb_cpubus_dacs_pulse_channel/clk
add wave -noupdate -radix decimal /tb_cpubus_dacs_pulse_channel/cpu_addr
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/cpu_rdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/cpu_rdata_dv
add wave -noupdate /tb_cpubus_dacs_pulse_channel/cpu_sel
add wave -noupdate -radix hexadecimal -radixshowbase 0 /tb_cpubus_dacs_pulse_channel/cpu_wdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/cpu_wr
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/done_seq
add wave -noupdate /tb_cpubus_dacs_pulse_channel/enable
add wave -noupdate /tb_cpubus_dacs_pulse_channel/err
add wave -noupdate /tb_cpubus_dacs_pulse_channel/error_latched
add wave -noupdate /tb_cpubus_dacs_pulse_channel/jesd_syncs
add wave -noupdate /tb_cpubus_dacs_pulse_channel/ready
add wave -noupdate /tb_cpubus_dacs_pulse_channel/reset
add wave -noupdate /tb_cpubus_dacs_pulse_channel/sim_done
add wave -noupdate /tb_cpubus_dacs_pulse_channel/trigger
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/reg_ch_en
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/reg_ch_sels
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/any_errs_jesd
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/axis_tdatas
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/axis_tlasts
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/axis_treadys
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/axis_tvalids
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/busy
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/busy_i
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/ch_busy
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/ch_enables
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/ch_errs_jesd
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/ch_errs_wave
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/cpu_ch_addr
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/cpu_ch_rdata_dvs
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/cpu_ch_rdatas
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/cpu_ch_sels
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/enable_d1
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/errs_jesd_latched
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/reg_rdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/reg_rdata_dv
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/reg_sequence_len
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/reg_status
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/reg_status_jesd
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/sm_busy
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/sm_cnt_time
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/sm_state
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/trigger_d1
add wave -noupdate -divider CH0
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tlast
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tready
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tvalid
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/busy
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_ADDR_LENGTH
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_ADDR_PULSE
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_ADDR_START
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_ADDR_TOP
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_ADDR_WAVE
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_GAIN_FACTOR
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_TIME_FACTOR
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_TIME_FRAC
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_BITS_TIME_INT
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_LEN_PULSE
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_LENGTH_WAVEFORM
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_PC_INCR
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_RAM_SELECT
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/C_START_TIME
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/clk
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cnt_time
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cnt_wave_len
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cnt_wave_top
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_addr
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata_dv
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata_dv_e1
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata_dv_e2
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata_ramsel_d1
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata_ramsel_d2
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_sel
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_wdata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_wr
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/enable
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/enable_d1
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/err_wave
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/pc
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_pulse_addra
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_pulse_addrb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_pulse_dina
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_pulse_douta
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_pulse_doutb
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_pulse_we
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_waveform_addra
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_waveform_addrb
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_waveform_dina
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_waveform_douta
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_waveform_doutb
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/ram_waveform_wea
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_pulse_flattop
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_pulse_time
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_scale_gain
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_scale_time
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_wave_length
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_wave_start_addr
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reset
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_busy
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_state
add wave -noupdate -format Analog-Step -height 74 -max 158.0 -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_wavedata
add wave -noupdate -radix hexadecimal /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_wavedata
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_wavedata_dv
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/start
add wave -noupdate /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/start_d1
add wave -noupdate -divider CH1
add wave -noupdate -divider WAVES
add wave -noupdate -format Analog-Step -height 74 -label wavedata_0 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_1 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(1)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_2 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(2)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_3 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(3)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_4 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(4)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_5 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(5)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_6 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(6)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_7 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(7)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_8 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(8)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_9 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(9)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_10 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(10)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_11 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(11)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_12 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(12)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_13 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(13)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_14 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(14)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_15 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(15)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_16 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(16)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_17 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(17)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_18 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(18)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_19 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(19)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_20 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(20)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_21 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(21)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_22 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(22)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_23 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(23)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_24 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(24)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_25 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(25)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_26 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(26)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_27 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(27)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_28 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(28)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_29 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(29)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_30 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(30)/ch_full/u_ch/sm_wavedata
add wave -noupdate -format Analog-Step -height 74 -label wavedata_31 -max 4.0 /tb_cpubus_dacs_pulse_channel/u_dacs_pulse/g_ch(31)/ch_full/u_ch/sm_wavedata
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 2} {18104923032 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 163
configure wave -valuecolwidth 199
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
WaveRestoreZoom {17963540075 fs} {19576459926 fs}
