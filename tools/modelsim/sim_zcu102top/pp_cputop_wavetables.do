onerror {resume}
quietly virtual signal -install /qlaser_top/u_pulse2pmod0/u_dac_pulse { (context /qlaser_top/u_pulse2pmod0/u_dac_pulse )( axis_tdata(0) & axis_tdata(1) & axis_tdata(2) & axis_tdata(3) & axis_tdata(4) & axis_tdata(5) & axis_tdata(6) & axis_tdata(7) & axis_tdata(8) & axis_tdata(9) & axis_tdata(10) & axis_tdata(11) )} spi_data
quietly virtual signal -install /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch { /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(11 downto 0)} axis_tdata_small
quietly virtual signal -install /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch { (context /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch )( cpu_wdata(0) & cpu_wdata(1) & cpu_wdata(2) & cpu_wdata(3) & cpu_wdata(4) & cpu_wdata(5) & cpu_wdata(6) & cpu_wdata(7) & cpu_wdata(8) & cpu_wdata(9) & cpu_wdata(10) & cpu_wdata(11) & cpu_wdata(12) & cpu_wdata(13) & cpu_wdata(14) & cpu_wdata(15) & cpu_wdata(16) )} cpu_wdata_low
quietly virtual signal -install /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch { (context /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch )( cpu_wdata(0) & cpu_wdata(1) & cpu_wdata(2) & cpu_wdata(3) & cpu_wdata(4) & cpu_wdata(5) & cpu_wdata(6) & cpu_wdata(7) & cpu_wdata(8) & cpu_wdata(9) & cpu_wdata(10) & cpu_wdata(11) & cpu_wdata(12) & cpu_wdata(13) & cpu_wdata(14) & cpu_wdata(15) )} cpu_wdata_lo
quietly virtual signal -install /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch { (context /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch )( cpu_wdata(16) & cpu_wdata(17) & cpu_wdata(18) & cpu_wdata(19) & cpu_wdata(20) & cpu_wdata(21) & cpu_wdata(22) & cpu_wdata(23) & cpu_wdata(24) & cpu_wdata(25) & cpu_wdata(26) & cpu_wdata(27) & cpu_wdata(28) & cpu_wdata(29) & cpu_wdata(30) & cpu_wdata(31) )} cpu_wdara_hi
quietly WaveActivateNextPane {} 0
add wave -noupdate -radix unsigned /qlaser_top/u_pulse2pmod0/s_axis_tdata
add wave -noupdate -radix unsigned -childformat {{/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(11) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(10) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(9) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(8) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(7) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(6) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(5) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(4) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(3) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(2) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(1) -radix unsigned} {/qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data(0) -radix unsigned}} -subitemconfig {/qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(0) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(1) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(2) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(3) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(4) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(5) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(6) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(7) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(8) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(9) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(10) {-radix unsigned} /qlaser_top/u_pulse2pmod0/u_dac_pulse/axis_tdata(11) {-radix unsigned}} /qlaser_top/u_pulse2pmod0/u_dac_pulse/spi_data
add wave -noupdate -radix unsigned -childformat {{/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(15) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(14) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(13) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(12) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(11) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(10) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(9) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(8) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(7) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(6) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(5) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(4) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(3) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(2) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(1) -radix unsigned} {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(0) -radix unsigned}} -subitemconfig {/qlaser_top/u_pulse2pmod0/fifo_axis_tdata(15) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(14) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(13) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(12) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(11) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(10) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(9) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(8) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(7) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(6) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(5) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(4) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(3) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(2) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(1) {-height 15 -radix unsigned} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata(0) {-height 15 -radix unsigned}} /qlaser_top/u_pulse2pmod0/fifo_axis_tdata
add wave -noupdate /qlaser_top/u_pulse2pmod0/fifo_axis_tvalid
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tlast
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tready
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tvalid
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/busy
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/clk
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cnt_time
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_addr
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_rdata_dv
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_wdata
add wave -noupdate -radix hexadecimal /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_wdata_lo
add wave -noupdate -radix hexadecimal /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/cpu_wdara_hi
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/erros
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata_small
add wave -noupdate /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tvalid
add wave -noupdate -format Analog-Step -height 74 -max 1031.0 -radix unsigned -childformat {{/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(15) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(14) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(13) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(12) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(11) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(10) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(9) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(8) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(7) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(6) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(5) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(4) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(3) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(2) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(1) -radix unsigned} {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(0) -radix unsigned}} -subitemconfig {/qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(15) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(14) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(13) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(12) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(11) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(10) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(9) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(8) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(7) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(6) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(5) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(4) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(3) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(2) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(1) {-height 15 -radix unsigned} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata(0) {-height 15 -radix unsigned}} /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/axis_tdata
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_pulse_flattop
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_pulse_time
add wave -noupdate -radix hexadecimal /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_scale_gain
add wave -noupdate -radix hexadecimal /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_scale_time
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_wave_end_addr
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_wave_length
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/reg_wave_start_addr
add wave -noupdate /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/sm_state
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/pc
add wave -noupdate -radix unsigned /qlaser_top/u_dacs_pulse/g_ch(0)/ch_full/u_ch/pulse_written
add wave -noupdate /qlaser_top/trigger_dacs_pulse
add wave -noupdate /qlaser_top/u_pulse2pmod0/fifo_almost_empty
add wave -noupdate /qlaser_top/u_pulse2pmod0/fifo_almost_full
add wave -noupdate -radix unsigned /qlaser_top/u_pulse2pmod0/fifo_axis_tdata
add wave -noupdate /qlaser_top/u_pulse2pmod0/fifo_axis_tready
add wave -noupdate /qlaser_top/u_pulse2pmod0/fifo_axis_tvalid
add wave -noupdate /qlaser_top/u_dacs_pulse/enable
add wave -noupdate /qlaser_top/u_dacs_pulse/done_seq
add wave -noupdate /qlaser_top/u_dacs_pulse/trigger
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {74186945 ps} 0}
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
WaveRestoreZoom {0 ps} {412681500 ps}
