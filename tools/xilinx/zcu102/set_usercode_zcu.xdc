##---------------------------------------------------------------------------------------
## Filename : set_usercode_zcu.xdc
##
## Vivado constraint file to set user version number into the bitfile
##---------------------------------------------------------------------------------------

#----------------------------------------------------------------------------------------
#-- Usercode major revisions
#----------------------------------------------------------------------------------------
#-- 0x0000_NNNN     : Early debug and test. No PMODs,ZMODs, DACs etc
#-- 0x1AC0_NNNN     : DC PMODs, 4? single bit pulses.  NNN incremented each bitfile
#-- 0x1DC0_NNNN     : DC PMODs DAC versions.           NNN incremented each bitfile
#-- 0x2AC0_NNNN     : DC PMODs, AC ZMODs. 4 channel    NNN incremented each bitfile
#-- 0x3AC0_NNNN     : DC PMODs, JESD AC (16ch Abaco board)    NNN incremented each bitfile
#
#----------------------------------------------------------------------------------------
#-- Usercode history
#----------------------------------------------------------------------------------------
#-- 0x1DC0_0001     : Original release 
#-- 0x1DC0_0002     : Modified double blink and added QSPI and SD into the PS1 block
#-- 0x1DC0_0003     : SD pins on 1.8V bank. Add SD_CD on MIO47
#-- 0x1DC0_0004     : SD clock dropped from 100MHz to 20Mhz
#-- 0x1DC0_0005     : Restore internal reference enable for pmod DACs
#-- 0x3AC0_0006     : Existing working codes ported to ZCU102
#-- 0x3AC0_0007     : ZCU102 with PS system and axi_cpuint
#--
#-- 0xC102_0001     : ZC102 with single pulse channel
#-- 0xC102_0002     : Minor LED change
#-- 0xC102_0003     : Drop lower 2 PS addr bits from cpuint to convert from byte addr to word addr. Output tdata on debug
#-- 0xC102_0004     : Fix in qlaser_cif to only set rdata_dv high for one cycle when reading RAMs
#-- 0xC102_0005     : Updated axi_cpuint to remove 'unused variable' error in the test function. Use 4 full pulse channels
#-- 0xC102_0006     : Updated axi_cpuint header. Empty channels have a single r/w register. Use 4 full pulse channels
#-- 0xC102_0007     : Added two jesd204 IP blocks
#-- 0xC102_0007     : Added two jesd204 IP blocks
#-- 0xC102_0008     : Changed clock pin locations
#-- 0xC102_0009     : Added all FMC0 and FMC1 JESD interfaces
#-- 0xC102_000A     : Changed all 32 pulse channels to be 'ramp' generators
#-- 0xC102_000B     : Added JESD data switch block
#-- 0xC102_000C     : Disconnect FMC1 JESD and send FMC1 clocks to p_debug pins
#-- 0xC102_000D     : Add additional p_debug pins
#-- 0xC102_000E     : 32 Ramp pulse generators
#-- 0xC102_000F     : Output fmc0 sysclk on debug pin. Fast debug outputs
#-- 0xC102_0010     : Output 100 MHz logic clock on debug pin 9 to use as external clock to FMC216
#-- 0xC102_0011     : Reset the ramp generator channel enable register to enable channel 0 
#-- 0xC102_0012     : Byte swap. JESD PHY Ref clock changed to 100 MHz because of DAC interpolation
#----------------------------------------------------------------------------------------
# In VHDL package : constant C_QLASER_VERSION   : std_logic_vector(31 downto 0)
#----------------------------------------------------------------------------------------
set_property BITSTREAM.CONFIG.USERID 32'hC1020012 [current_design]
