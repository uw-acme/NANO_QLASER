##---------------------------------------------------------------------------------------
## Filename : set_usercode.xdc
##
## Vivado onstraint file to set user version number into the bitfile
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
#--
#----------------------------------------------------------------------------------------
# In VHDL package : constant C_QLASER_VERSION   : std_logic_vector(31 downto 0)
#----------------------------------------------------------------------------------------
set_property BITSTREAM.CONFIG.USERID 32'h3AC00006 [current_design]





