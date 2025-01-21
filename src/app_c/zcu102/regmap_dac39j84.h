//--------------------------------------------------------------------------------------------------------------------------------------------
//      Addr                       Name     Default  (MSB) Bit 15 Bit 14 Bit 13 Bit 12 Bit 11 Bit 10 Bit 9 Bit 8 Bit 7 Bit 6 Bit 5 Bit 4 Bit 3 Bit 2 Bit 1 Bit0 (LSB)
//--------------------------------------------------------------------------------------------------------------------------------------------
#define NUM_REGS_DAC_39J84  128 // Number of registers in the DAC
#define ADR_CONFIG_0    0x00    // config0   0x0218 offsetab offsetcd qmc _corrab corrcd interp(3:0) os outsum zeros alarm_out alarm pap _ena inv_sinc inv_sinc _ena _ena _ena _ena _txenable _ena _jesd _ena _out_pol _ab _ena _cd_ena _ena data_ena sfrac_ sfrac_ lfrac_ lfrac_ sfrac_ daca_ dacb_ dacc_ dacd_
#define ADR_CONFIG_1    0x01    // config1   0x0003 sfrac_ena_ab sfrac_ena_cd lfrac_ena_ab lfrac_ena_cd sfrac_sel_ab sfrac_sel_cd reserved reserved daca_compliment -- complime complime complime reserved reserved reserved reserved nt nt nt nt
#define ADR_CONFIG_2    0x02    // config2   0x2002 dac_bitwidth(1:0) zer_invalid_data shorttest_ena reserved reserved reserved reserved sif4_ena mixer_ena mixer_gain nco_ena reserved reserved twos sif_reset 
#define ADR_CONFIG_3    0x03    // config3   0xF380 coarse_dac(3:0) reserved(11:8) fif_error_zeros_data_ena reserved(6:1) sif_txenable
#define ADR_CONFIG_4    0x04    // config4   0x00FF alarms_mask(15:0)
#define ADR_CONFIG_5    0x05    // config5   0xFFFF alarms_mask(31:16)
#define ADR_CONFIG_6    0x06    // config6   0xFFFF alarms_mask(47:32)
#define ADR_CONFIG_7    0x07    // config7   0x0000 memin_tempdata(7:0) reserved memin_lane_skew(4:0)
#define ADR_CONFIG_8    0x08    // config8   0x0000 reserved reserved reserved qmc_offseta(12:0)
#define ADR_CONFIG_9    0x09    // config9   0x0000 reserved reserved reserved qmc_offsetb(12:0)
#define ADR_CONFIG_10   0x0A    // config10  0x0000 reserved reserved reserved qmc_offsetc(12:0)
#define ADR_CONFIG_11   0x0B    // config11  0x0000 reserved reserved reserved qmc_offsetd(12:0)
#define ADR_CONFIG_12   0x0C    // config12  0x0400 reserved reserved reserved reserved reserved qmc_gaina(10:0)
#define ADR_CONFIG_13   0x0D    // config13  0x0400 fs8 fs4 fs2 fsm4 reserved qmc_gainb(10:0)
#define ADR_CONFIG_14   0x0E    // config14  0x0400 reserved reserved reserved reserved reserved qmc_gainc(10:0)
#define ADR_CONFIG_15   0x0F    // config15  0x0400 output _delayab output _delaycd reserved qmc_gaind(10:0) _reserved(1:0) _reserved(1:0)
#define ADR_CONFIG_16   0x10    // config16  0x0000 reserved reserved reserved reserved qmc_phaseab(11:0)
#define ADR_CONFIG_17   0x11    // config17  0x0000 reserved reserved reserved reserved qmc_phasecd(11:0)
#define ADR_CONFIG_18   0x12    // config18  0x0000 phaseoffsetab(15:0)
#define ADR_CONFIG_19   0x13    // config19  0x0000 phaseoffsetcd(15:0)
#define ADR_CONFIG_20   0x14    // config20  0x0000 phaseaddab(15:0)
#define ADR_CONFIG_21   0x15    // config21  0x0000 phaseaddab(31:16)
#define ADR_CONFIG_22   0x16    // config22  0x0000 phaseaddab(47:32)
#define ADR_CONFIG_23   0x17    // config23  0x0000 phaseaddcd(15:0)
#define ADR_CONFIG_24   0x18    // config24  0x0000 phaseaddcd(31:16)
#define ADR_CONFIG_25   0x19    // config25  0x0000 phaseaddcd(47:32)
#define ADR_CONFIG_26   0x1A    // config26  0x0020 reserved reserved vbgr_sleep biasopamp_sleep tsense_sleep pll_sleep clkrecv_sleep daca_sleep dacb_sleep dacc_sleep dacd_sleep
#define ADR_CONFIG_27   0x1B    // config27  0x0000 extref_ena dtest_lane(2:0) dtest(3:0) reserved reserved atest(5:0) 
#define ADR_CONFIG_28   0x1C    // config28  0x0000 reserved reserved
#define ADR_CONFIG_29   0x1D    // config29  0x0000 reserved reserved
#define ADR_CONFIG_30   0x1E    // config30  0x1111 syncsel_qmoffsetab(3:0) syncsel_qmoffsetcd(3:0) syncsel_qmcorrab(3:0) syncsel_qmcorrcd(3:0)
#define ADR_CONFIG_31   0x1F    // config31  0x1140 syncsel_mixerab(3:0) syncsel_mixercd(3:0) syncsel_nco(3:0) reserved sif_sync reserved
//--------------------------------------------------------------------------------------------------------------------------------------------
//      Addr                       Name     Default  (MSB) Bit 15 Bit 14 Bit 13 Bit 12 Bit 11 Bit 10 Bit 9 Bit 8 Bit 7 Bit 6 Bit 5 Bit 4 Bit 3 Bit 2 Bit 1 Bit0 (LSB)
//--------------------------------------------------------------------------------------------------------------------------------------------
#define ADR_CONFIG_32   0x20    // config32  0x0000 syncsel_dither(3:0) reserved syncsel_pap(3:0) syncsel_fir5a(3:0)
#define ADR_CONFIG_33   0x21    // config33  0x0000 reserved
#define ADR_CONFIG_34   0x22    // config34  0x1B1B patha_in_sel(1:0) pathb_in_sel(1:0) pathc_in_sel(1:0) pathd_in_sel(1:0) patha_out_sel(1:0) pathb_out_sel(1:0) pathc_out_sel(1:0) pathd_out_sel(1:0)
#define ADR_CONFIG_35   0x23    // config35  0xFFFF sleep_cntl(15:0)
#define ADR_CONFIG_36   0x24    // config36  0x0000 reserved cdrvser_sysref_mode(2:0) reserved reserved
#define ADR_CONFIG_37   0x25    // config37  0x0000 clkjesd_div(2:0) reserved reserved reserved reserved reserved
#define ADR_CONFIG_38   0x26    // config38         dither_ena(3:0) dither_mixer_ena(3:0) dither_sra_sel3:0) reserved reserved dither _zero
#define ADR_CONFIG_39   0x27    // config39  0x0000 reserved(15:0)
#define ADR_CONFIG_40   0x28    // config40  0x0000 reserved(15:0)
#define ADR_CONFIG_41   0x29    // config41  0x0000 reserved(15:0)
#define ADR_CONFIG_42   0x2A    // config42  0x0000 reserved(15:0)
#define ADR_CONFIG_43   0x2B    // config43  0x0000 reserved(15:0)
#define ADR_CONFIG_44   0x2C    // config44  0x0000 reserved(15:0)
#define ADR_CONFIG_45   0x2D    // config45  0x0000 reserved(15:4) pap_dlylen_sel pap_gain(2:0) 
#define ADR_CONFIG_46   0x2E    // config46  0xFFFF pap_vth(15:0)
#define ADR_CONFIG_47   0x2F    // config47  0x0004 reserved titest_dieid_read_ena reserved(14:1) sifdac_ena 
#define ADR_CONFIG_48   0x30    // config48  0x0000 sifdac(15:0)
#define ADR_CONFIG_49   0x31    // config49  0x0000 lockdet_adj(2:0) pll_reset pll_ndivsync_ena pll_ena pll_cp(1:0) pll_n(4:0) memin_pll_lfvolt(2:0) 
#define ADR_CONFIG_50   0x32    // config50  0x0000 pll_m(7:0) pll_p(3:0) reserved(3:0)
#define ADR_CONFIG_51   0x33    // config51  0x0100 pll_vcosel pll_vco(5:0) pll_vcoitune(1:0) pll_cp_adj(4:0) reserved(1:0)
#define ADR_CONFIG_52   0x34    // config52  0x0000 syncb_lvds_lopwrb syncb_lvds_lopwra syncb_lvds_lpsel syncb_lvds_effuse_sel reserved(1:0)   lvds_sleep lvds_sub_ena reserved(6:0) 
#define ADR_CONFIG_53   0x35    // config53  0x0000 reserved(15:0) 
#define ADR_CONFIG_54   0x36    // config54  0x0000 reserved(15:0)
#define ADR_CONFIG_55   0x37    // config55  0x0000 reserved(15:0)
#define ADR_CONFIG_56   0x38    // config56  0x0000 reserved(15:0)
#define ADR_CONFIG_57   0x39    // config57  0x0000 reserved(15:0)
#define ADR_CONFIG_58   0x3A    // config58  0x0000 reserved(15:0)
#define ADR_CONFIG_59   0x3B    // config59  0x0000 serdes_clk_sel serdes_refclk_div(3:0) reserved(10:0) 
#define ADR_CONFIG_60   0x3C    // config60  0x0000 rw_cfgpll(15:0)
#define ADR_CONFIG_61   0x3D    // config61  0x0000 reserved(15) rw_cfgrx0_upper(14:0)
#define ADR_CONFIG_62   0x3E    // config62  0x0000 rw_cfgrx0_lower(15:0) 
#define ADR_CONFIG_63   0x3F    // config63  0x0000 reserved(15:8) INVPAIR(7:0)
#define ADR_CONFIG_64   0x40    // config64  0x0000 reserved(15:0)
#define ADR_CONFIG_65   0x41    // config65  0x0000 errorcnt_link0(15:0)
#define ADR_CONFIG_66   0x42    // config66  0x0000 errorcnt_link1(15:0)
#define ADR_CONFIG_67   0x43    // config67  0x0000 reserved
#define ADR_CONFIG_68   0x44    // config68  0x0000 reserved
#define ADR_CONFIG_69   0x45    // config69  0x0000 reserved
#define ADR_CONFIG_70   0x46    // config70  0x0044 lid0(4:0) lid1(4:0) lid2(4:0) reserved
#define ADR_CONFIG_71   0x47    // config71  0x190A lid3(4:0) lid4(4:0) lid5(4:0) reserved
#define ADR_CONFIG_72   0x48    // config72  0x31C3 lid6(4:0) lid7(4:0) reserved subclassv(2:0) jesdv
#define ADR_CONFIG_73   0x49    // config73  0x0000 link_assign(15:0)
#define ADR_CONFIG_74   0x4A    // config74  0x001E lane_ena(7:0) jesd_test_seq(1:0) dual init_state(3:0) jesd_reset_n 
#define ADR_CONFIG_75   0x4B    // config75  0x0000 reserved(15:13) rbd_m1(4:0) f_m1(7:0)
#define ADR_CONFIG_76   0x4C    // config76  0x0000 reserved(15:13) k_m1(4:0) reserved(7:5) l_m1(4:0)
#define ADR_CONFIG_77   0x4D    // config77  0x0300 m_m1(7:0) reserved(7:5) s_m1(4:0)
#define ADR_CONFIG_78   0x4E    // config78  0x0F0F reserved(15:13) nprime_m1(4:0) reserved(7) hd scr n_m1(4:0)
#define ADR_CONFIG_79   0x4F    // config79  0x1CC1 match_data(7:0) match_specific match_ctrl no_lane_sync reserved(4:1) jesd_commaalign_ena
#define ADR_CONFIG_80   0x50    // config80  0x0000 adjcnt_link0(3:0) adjdir_link0 bid_link0(3:0) cf_link0(4:0) cs_link0(1:0)
#define ADR_CONFIG_81   0x51    // config81  0x00FF did_link0(7:0) sync_request_ena_link0(7:0)
#define ADR_CONFIG_82   0x52    // config82  0x00FF reserved(15:10) disable_err_report_link0 phadj_link0 error_ena_link0(7:0) 
#define ADR_CONFIG_83   0x53    // config83  0x0000 adjcnt_link1(3:0) adjdir_link1 bid_link1(3:0) cf_link1(4:0) cs_link1(1:0)
#define ADR_CONFIG_84   0x54    // config84  0x00FF did_link1(7:0) sync_request_ena_link1(7:0)
#define ADR_CONFIG_85   0x55    // config85  0x00FF reserved(15:10) disable_err_report_link1 phadj_link0 error_ena_link1(7:0)  
#define ADR_CONFIG_86   0x56    // config86  0x0000 reserved(15:0) 
#define ADR_CONFIG_87   0x57    // config87  0x00FF reserved(15:0) 
#define ADR_CONFIG_88   0x58    // config88  0x00FF reserved(15:0) 
#define ADR_CONFIG_89   0x59    // config89  0x0000 reserved(15:0) 
#define ADR_CONFIG_90   0x5A    // config90  0x00FF reserved(15:0) 
#define ADR_CONFIG_91   0x5B    // config91  0x00FF reserved(15:0) 
#define ADR_CONFIG_92   0x5C    // config92  0x1111 reserved(15:8) err_cnt_clr_link1 sysref_mode_link1(2:0) err_cnt sysref_mode_link0(2:0)  _clr_link0
#define ADR_CONFIG_93   0x5D    // config93  0x0000 reserve(15:0)d
#define ADR_CONFIG_94   0x5E    // config94  0x0000 res1(7:0) res2(7:0)
#define ADR_CONFIG_95   0x60    // config95  0x0123 reserved octetpath_sel(0)(2:0) reserved octetpath_sel(1)(2:0) reserved octetpath_sel(2)(2:0) reserved octetpath_sel(3)(2:0)
#define ADR_CONFIG_96   0x61    // config96  0x0456 reserved octetpath_sel(4)(2:0) reserved octetpath_sel(5)(2:0) reserved octetpath_sel(6)(2:0) reserved octetpath_sel(7)(2:0)
#define ADR_CONFIG_97   0x62    // config97  0x000F syncn_pol reserved syncncd_sel(3:0) syncnab_sel(3:0) syncn_sel(3:0)
#define ADR_CONFIG_98   0x63    // config98  0x0000 reserved reserved reserved reserved
#define ADR_CONFIG_99   0x64    // config99  0x0000 reserved reserved reserved reserved Reserved
#define ADR_CONFIG_100  0x65    // config100 0x0000 alarm_l_error(0)(7:0) reserved alarm_fifo_flags(0)(3:0)
#define ADR_CONFIG_101  0x66    // config101 0x0000 alarm_l_error(1)(7:0) reserved alarm_fifo_flags(1)(3:0)
#define ADR_CONFIG_102  0x67    // config102 0x0000 alarm_l_error(2)(7:0) reserved alarm_fifo_flags(2)(3:0)
#define ADR_CONFIG_103  0x68    // config103 0x0000 alarm_l_error(3)(7:0) reserved alarm_fifo_flags(3)(3:0)
#define ADR_CONFIG_104  0x69    // config104 0x0000 alarm_l_error(4)(7:0) reserved alarm_fifo_flags(4)(3:0)
#define ADR_CONFIG_105  0x6A    // config105 0x0000 alarm_l_error(5)(7:0) reserved alarm_fifo_flags(5)(3:0)
#define ADR_CONFIG_106  0x6B    // config106 0x0000 alarm_l_error(6)(7:0) reserved alarm_fifo_flags(6)(3:0)
#define ADR_CONFIG_107  0x6C    // config107 0x0000 alarm_l_error(7)(7:0) reserved alarm_fifo_flags(7)(3:0)
#define ADR_CONFIG_108  0x6D    // config108 0x0000 alarm_sysref_err(3:0) alarm_pap(3:0) reserved(7:4) alarm_rw0_pll alarm_rw1_pll reserved(1) alarm_from_pll   
#define ADR_CONFIG_109  0x6E    // config109 0x00xx alarm_from_shorttest(7:0) memin_rw_losdct(7:0)
#define ADR_CONFIG_110  0x6F    // config110 0x0000 sfrac_coef0_ab(1:0) sfrac_coef1_ab(4:0) sfrac_coef2_ab(7:0) Reserved
#define ADR_CONFIG_111  0x70    // config111 0x0000 reserved sfrac_coef3_ab(9:0)
#define ADR_CONFIG_112  0x71    // config112 0x0000 sfrac_coef4_ab(15:0)
#define ADR_CONFIG_113  0x72    // config113 0x0000 sfrac_coef4_ab(18:16) reserved sfrac_coef5_ab(9:0)
#define ADR_CONFIG_114  0x73    // config114 0x0000 reserved sfrac_coef6_ab(8:0)
#define ADR_CONFIG_115  0x74    // config115 0x0000 sfrac_coef7_ab(6:0) sfrac_coef8_ab(4:0) sfrac_coef9_ab(1:0) Reserved
#define ADR_CONFIG_116  0x75    // config116 0x0000 sfrac_invgain_ab(15:0)
#define ADR_CONFIG_117  0x76    // config117 0x0000 sfrac_invgain_ab(19:16) reserved lfras_coefsel_a(2:0) lfras_coefsel_b(2:0)
#define ADR_CONFIG_118  0x77    // config118 0x0000 sfrac_coef0_cd(1:0) sfrac_coef1_cd(4:0) sfrac_coef2_cd7:0) Reserved
#define ADR_CONFIG_119  0x78    // config119 0x0000 reserved sfrac_coef3_cd(9:0)
#define ADR_CONFIG_120  0x79    // config120 0x0000 sfrac_coef4_cd(15:0)
#define ADR_CONFIG_121  0x7A    // config121 0x0000 sfrac_coef4_cd(18:16) reserved sfrac_coef5_cd(9:0)
#define ADR_CONFIG_122  0x7B    // config122 0x0000 reserved sfrac_coef6_cd(8:0)
#define ADR_CONFIG_123  0x7C    // config123 0x0000 sfrac_coef7_cd(6:0) sfrac_coef8_cd(4:0) sfrac_coef9_cd(1:0) Reserved
#define ADR_CONFIG_124  0x7D    // config124 0x0000 sfrac_invgain_cd(15:0)
#define ADR_CONFIG_125  0x7E    // config125 0x0000 sfrac_invgain_cd(19:16) reserved lfras_coefsel_c(2:0) lfras_coefsel_d(2:0)
#define ADR_CONFIG_126  0x7F    // config126 0x0000 reserved(15:0) 
#define ADR_CONFIG_127  0x80    // config127 0x0000 memin_efc memin_efc_error(4:0) reserved(9:5) vendorid(1:0) versionid(2:0) _autoload

//-- END --
#define DEF_CONFIG_0    0x0218  //   offsetab offsetcd qmc _corrab corrcd interp(3:0) os outsum zeros alarm_out alarm pap _ena inv_sinc inv_sinc _ena _ena _ena _ena _txenable _ena _jesd _ena _out_pol _ab _ena _cd_ena _ena data_ena sfrac_ sfrac_ lfrac_ lfrac_ sfrac_ daca_ dacb_ dacc_ dacd_
#define DEF_CONFIG_1    0x0003  //   sfrac_ena_ab sfrac_ena_cd lfrac_ena_ab lfrac_ena_cd sfrac_sel_ab sfrac_sel_cd reserved reserved daca_compliment -- complime complime complime reserved reserved reserved reserved nt nt nt nt
#define DEF_CONFIG_2    0x2002  //   dac_bitwidth(1:0) zer_invalid_data shorttest_ena reserved reserved reserved reserved sif4_ena mixer_ena mixer_gain nco_ena reserved reserved twos sif_reset 
#define DEF_CONFIG_3    0xF380  //   coarse_dac(3:0) reserved(11:8) fif_error_zeros_data_ena reserved(6:1) sif_txenable
#define DEF_CONFIG_4    0x00FF  //   alarms_mask(15:0)
#define DEF_CONFIG_5    0xFFFF  //   alarms_mask(31:16)
#define DEF_CONFIG_6    0xFFFF  //   alarms_mask(47:32)
#define DEF_CONFIG_7    0x0000  //   memin_tempdata(7:0) reserved memin_lane_skew(4:0)
#define DEF_CONFIG_8    0x0000  //   reserved reserved reserved qmc_offseta(12:0)
#define DEF_CONFIG_9    0x0000  //   reserved reserved reserved qmc_offsetb(12:0)
#define DEF_CONFIG_10   0x0000  //   reserved reserved reserved qmc_offsetc(12:0)
#define DEF_CONFIG_11   0x0000  //   reserved reserved reserved qmc_offsetd(12:0)
#define DEF_CONFIG_12   0x0400  //   reserved reserved reserved reserved reserved qmc_gaina(10:0)
#define DEF_CONFIG_13   0x0400  //   fs8 fs4 fs2 fsm4 reserved qmc_gainb(10:0)
#define DEF_CONFIG_14   0x0400  //   reserved reserved reserved reserved reserved qmc_gainc(10:0)
#define DEF_CONFIG_15   0x0400  //   output _delayab output _delaycd reserved qmc_gaind(10:0) _reserved(1:0) _reserved(1:0)
#define DEF_CONFIG_16   0x0000  //   reserved reserved reserved reserved qmc_phaseab(11:0)
#define DEF_CONFIG_17   0x0000  //   reserved reserved reserved reserved qmc_phasecd(11:0)
#define DEF_CONFIG_18   0x0000  //   phaseoffsetab(15:0)
#define DEF_CONFIG_19   0x0000  //   phaseoffsetcd(15:0)
#define DEF_CONFIG_20   0x0000  //   phaseaddab(15:0)
#define DEF_CONFIG_21   0x0000  //   phaseaddab(31:16)
#define DEF_CONFIG_22   0x0000  //   phaseaddab(47:32)
#define DEF_CONFIG_23   0x0000  //   phaseaddcd(15:0)
#define DEF_CONFIG_24   0x0000  //   phaseaddcd(31:16)
#define DEF_CONFIG_25   0x0000  //   phaseaddcd(47:32)
#define DEF_CONFIG_26   0x0020  //   reserved reserved vbgr_sleep biasopamp_sleep tsense_sleep pll_sleep clkrecv_sleep daca_sleep dacb_sleep dacc_sleep dacd_sleep
#define DEF_CONFIG_27   0x0000  //   extref_ena dtest_lane(2:0) dtest(3:0) reserved reserved atest(5:0) 
#define DEF_CONFIG_28   0x0000  //   reserved reserved
#define DEF_CONFIG_29   0x0000  //   reserved reserved
#define DEF_CONFIG_30   0x1111  //   syncsel_qmoffsetab(3:0) syncsel_qmoffsetcd(3:0) syncsel_qmcorrab(3:0) syncsel_qmcorrcd(3:0)
#define DEF_CONFIG_31   0x1140  //   syncsel_mixerab(3:0) syncsel_mixercd(3:0) syncsel_nco(3:0) reserved sif_sync reserved
#define DEF_CONFIG_32   0x0000  //   syncsel_dither(3:0) reserved syncsel_pap(3:0) syncsel_fir5a(3:0)
#define DEF_CONFIG_33   0x0000  //   reserved
#define DEF_CONFIG_34   0x1B1B  //   patha_in_sel(1:0) pathb_in_sel(1:0) pathc_in_sel(1:0) pathd_in_sel(1:0) patha_out_sel(1:0) pathb_out_sel(1:0) pathc_out_sel(1:0) pathd_out_sel(1:0)
#define DEF_CONFIG_35   0xFFFF  //   sleep_cntl(15:0)
#define DEF_CONFIG_36   0x0000  //   reserved cdrvser_sysref_mode(2:0) reserved reserved
#define DEF_CONFIG_37   0x8000  //   clkjesd_div(2:0) reserved reserved reserved reserved reserved
#define DEF_CONFIG_38   0x0000  //   dither_ena(3:0) dither_mixer_ena(3:0) dither_sra_sel3:0) reserved reserved dither _zero
#define DEF_CONFIG_39   0x0000  //   reserved(15:0)
#define DEF_CONFIG_40   0x0000  //   reserved(15:0)
#define DEF_CONFIG_41   0x0000  //   reserved(15:0)
#define DEF_CONFIG_42   0x0000  //   reserved(15:0)
#define DEF_CONFIG_43   0x0000  //   reserved(15:0)
#define DEF_CONFIG_44   0x0000  //   reserved(15:0)
#define DEF_CONFIG_45   0x0000  //   reserved(15:4) pap_dlylen_sel pap_gain(2:0) 
#define DEF_CONFIG_46   0xFFFF  //   pap_vth(15:0)
#define DEF_CONFIG_47   0x0004  //   reserved titest_dieid_read_ena reserved(14:1) sifdac_ena 
#define DEF_CONFIG_48   0x0000  //   sifdac(15:0)
#define DEF_CONFIG_49   0x0000  //   lockdet_adj(2:0) pll_reset pll_ndivsync_ena pll_ena pll_cp(1:0) pll_n(4:0) memin_pll_lfvolt(2:0) 
#define DEF_CONFIG_50   0x0000  //   pll_m(7:0) pll_p(3:0) reserved(3:0)
#define DEF_CONFIG_51   0x0100  //   pll_vcosel pll_vco(5:0) pll_vcoitune(1:0) pll_cp_adj(4:0) reserved(1:0)
#define DEF_CONFIG_52   0x0000  //   syncb_lvds_lopwrb syncb_lvds_lopwra syncb_lvds_lpsel syncb_lvds_effuse_sel reserved(1:0)   lvds_sleep lvds_sub_ena reserved(6:0) 
#define DEF_CONFIG_53   0x0000  //   reserved(15:0) 
#define DEF_CONFIG_54   0x0000  //   reserved(15:0)
#define DEF_CONFIG_55   0x0000  //   reserved(15:0)
#define DEF_CONFIG_56   0x0000  //   reserved(15:0)
#define DEF_CONFIG_57   0x0000  //   reserved(15:0)
#define DEF_CONFIG_58   0x0000  //   reserved(15:0)
#define DEF_CONFIG_59   0x0000  //   serdes_clk_sel serdes_refclk_div(3:0) reserved(10:0) 
#define DEF_CONFIG_60   0x0000  //   rw_cfgpll(15:0)
#define DEF_CONFIG_61   0x0000  //   reserved(15) rw_cfgrx0_upper(14:0)
#define DEF_CONFIG_62   0x0000  //   rw_cfgrx0_lower(15:0) 
#define DEF_CONFIG_63   0x0000  //   reserved(15:8) INVPAIR(7:0)
#define DEF_CONFIG_64   0x0000  //   reserved(15:0)
#define DEF_CONFIG_65   0x0000  //   errorcnt_link0(15:0)
#define DEF_CONFIG_66   0x0000  //   errorcnt_link1(15:0)
#define DEF_CONFIG_67   0x0000  //   reserved
#define DEF_CONFIG_68   0x0000  //   reserved
#define DEF_CONFIG_69   0x0000  //   reserved
#define DEF_CONFIG_70   0x0044  //   lid0(4:0) lid1(4:0) lid2(4:0) reserved
#define DEF_CONFIG_71   0x190A  //   lid3(4:0) lid4(4:0) lid5(4:0) reserved
#define DEF_CONFIG_72   0x31C3  //   lid6(4:0) lid7(4:0) reserved subclassv(2:0) jesdv
#define DEF_CONFIG_73   0x0000  //   link_assign(15:0)
#define DEF_CONFIG_74   0x001E  //   lane_ena(7:0) jesd_test_seq(1:0) dual init_state(3:0) jesd_reset_n 
#define DEF_CONFIG_75   0x0000  //   reserved(15:13) rbd_m1(4:0) f_m1(7:0)
#define DEF_CONFIG_76   0x0000  //   reserved(15:13) k_m1(4:0) reserved(7:5) l_m1(4:0)
#define DEF_CONFIG_77   0x0300  //   m_m1(7:0) reserved(7:5) s_m1(4:0)
#define DEF_CONFIG_78   0x0F0F  //   reserved(15:13) nprime_m1(4:0) reserved(7) hd scr n_m1(4:0)
#define DEF_CONFIG_79   0x1CC1  //   match_data(7:0) match_specific match_ctrl no_lane_sync reserved(4:1) jesd_commaalign_ena
#define DEF_CONFIG_80   0x0000  //   adjcnt_link0(3:0) adjdir_link0 bid_link0(3:0) cf_link0(4:0) cs_link0(1:0)
#define DEF_CONFIG_81   0x00FF  //   did_link0(7:0) sync_request_ena_link0(7:0)
#define DEF_CONFIG_82   0x00FF  //   reserved(15:10) disable_err_report_link0 phadj_link0 error_ena_link0(7:0) 
#define DEF_CONFIG_83   0x0000  //   adjcnt_link1(3:0) adjdir_link1 bid_link1(3:0) cf_link1(4:0) cs_link1(1:0)
#define DEF_CONFIG_84   0x00FF  //   did_link1(7:0) sync_request_ena_link1(7:0)
#define DEF_CONFIG_85   0x00FF  //   reserved(15:10) disable_err_report_link1 phadj_link0 error_ena_link1(7:0)  
#define DEF_CONFIG_86   0x0000  //   reserved(15:0) 
#define DEF_CONFIG_87   0x00FF  //   reserved(15:0) 
#define DEF_CONFIG_88   0x00FF  //   reserved(15:0) 
#define DEF_CONFIG_89   0x0000  //   reserved(15:0) 
#define DEF_CONFIG_90   0x00FF  //   reserved(15:0) 
#define DEF_CONFIG_91   0x00FF  //   reserved(15:0) 
#define DEF_CONFIG_92   0x1111  //   reserved(15:8) err_cnt_clr_link1 sysref_mode_link1(2:0) err_cnt sysref_mode_link0(2:0)  _clr_link0
#define DEF_CONFIG_93   0x0000  //   reserve(15:0)d
#define DEF_CONFIG_94   0x0000  //   res1(7:0) res2(7:0)
#define DEF_CONFIG_95   0x0123  //   reserved octetpath_sel(0)(2:0) reserved octetpath_sel(1)(2:0) reserved octetpath_sel(2)(2:0) reserved octetpath_sel(3)(2:0)
#define DEF_CONFIG_96   0x0456  //   reserved octetpath_sel(4)(2:0) reserved octetpath_sel(5)(2:0) reserved octetpath_sel(6)(2:0) reserved octetpath_sel(7)(2:0)
#define DEF_CONFIG_97   0x000F  //   syncn_pol reserved syncncd_sel(3:0) syncnab_sel(3:0) syncn_sel(3:0)
#define DEF_CONFIG_98   0x0000  //   reserved reserved reserved reserved
#define DEF_CONFIG_99   0x0000  //   reserved reserved reserved reserved Reserved
#define DEF_CONFIG_100  0x0000  //   alarm_l_error(0)(7:0) reserved alarm_fifo_flags(0)(3:0)
#define DEF_CONFIG_101  0x0000  //   alarm_l_error(1)(7:0) reserved alarm_fifo_flags(1)(3:0)
#define DEF_CONFIG_102  0x0000  //   alarm_l_error(2)(7:0) reserved alarm_fifo_flags(2)(3:0)
#define DEF_CONFIG_103  0x0000  //   alarm_l_error(3)(7:0) reserved alarm_fifo_flags(3)(3:0)
#define DEF_CONFIG_104  0x0000  //   alarm_l_error(4)(7:0) reserved alarm_fifo_flags(4)(3:0)
#define DEF_CONFIG_105  0x0000  //   alarm_l_error(5)(7:0) reserved alarm_fifo_flags(5)(3:0)
#define DEF_CONFIG_106  0x0000  //   alarm_l_error(6)(7:0) reserved alarm_fifo_flags(6)(3:0)
#define DEF_CONFIG_107  0x0000  //   alarm_l_error(7)(7:0) reserved alarm_fifo_flags(7)(3:0)
#define DEF_CONFIG_108  0x0000  //   alarm_sysref_err(3:0) alarm_pap(3:0) reserved(7:4) alarm_rw0_pll alarm_rw1_pll reserved(1) alarm_from_pll   
#define DEF_CONFIG_109  0x0000  //   alarm_from_shorttest(7:0) memin_rw_losdct(7:0)
#define DEF_CONFIG_110  0x0000  //   sfrac_coef0_ab(1:0) sfrac_coef1_ab(4:0) sfrac_coef2_ab(7:0) Reserved
#define DEF_CONFIG_111  0x0000  //   reserved sfrac_coef3_ab(9:0)
#define DEF_CONFIG_112  0x0000  //   sfrac_coef4_ab(15:0)
#define DEF_CONFIG_113  0x0000  //   sfrac_coef4_ab(18:16) reserved sfrac_coef5_ab(9:0)
#define DEF_CONFIG_114  0x0000  //   reserved sfrac_coef6_ab(8:0)
#define DEF_CONFIG_115  0x0000  //   sfrac_coef7_ab(6:0) sfrac_coef8_ab(4:0) sfrac_coef9_ab(1:0) Reserved
#define DEF_CONFIG_116  0x0000  //   sfrac_invgain_ab(15:0)
#define DEF_CONFIG_117  0x0000  //   sfrac_invgain_ab(19:16) reserved lfras_coefsel_a(2:0) lfras_coefsel_b(2:0)
#define DEF_CONFIG_118  0x0000  //   sfrac_coef0_cd(1:0) sfrac_coef1_cd(4:0) sfrac_coef2_cd7:0) Reserved
#define DEF_CONFIG_119  0x0000  //   reserved sfrac_coef3_cd(9:0)
#define DEF_CONFIG_120  0x0000  //   sfrac_coef4_cd(15:0)
#define DEF_CONFIG_121  0x0000  //   sfrac_coef4_cd(18:16) reserved sfrac_coef5_cd(9:0)
#define DEF_CONFIG_122  0x0000  //   reserved sfrac_coef6_cd(8:0)
#define DEF_CONFIG_123  0x0000  //   sfrac_coef7_cd(6:0) sfrac_coef8_cd(4:0) sfrac_coef9_cd(1:0) Reserved
#define DEF_CONFIG_124  0x0000  //   sfrac_invgain_cd(15:0)
#define DEF_CONFIG_125  0x0000  //   sfrac_invgain_cd(19:16) reserved lfras_coefsel_c(2:0) lfras_coefsel_d(2:0)
#define DEF_CONFIG_126  0x0000  //   reserved(15:0) 
#define DEF_CONFIG_127  0x0000  //   memin_efc memin_efc_error(4:0) reserved(9:5) vendorid(1:0) versionid(2:0) _autoload

// Define an integer array of all default values
int arr_reg_dac_defaults[128] = {
    DEF_CONFIG_0,   DEF_CONFIG_1,   DEF_CONFIG_2,   DEF_CONFIG_3,  
    DEF_CONFIG_4,   DEF_CONFIG_5,   DEF_CONFIG_6,   DEF_CONFIG_7,  
    DEF_CONFIG_8,   DEF_CONFIG_9,   DEF_CONFIG_10,  DEF_CONFIG_11,  
    DEF_CONFIG_12,  DEF_CONFIG_13,  DEF_CONFIG_14,  DEF_CONFIG_15,  
    DEF_CONFIG_16,  DEF_CONFIG_17,  DEF_CONFIG_18,  DEF_CONFIG_19,  
    DEF_CONFIG_20,  DEF_CONFIG_21,  DEF_CONFIG_22,  DEF_CONFIG_23,  
    DEF_CONFIG_24,  DEF_CONFIG_25,  DEF_CONFIG_26,  DEF_CONFIG_27,  
    DEF_CONFIG_28,  DEF_CONFIG_29,  DEF_CONFIG_30,  DEF_CONFIG_31,  
    DEF_CONFIG_32,  DEF_CONFIG_33,  DEF_CONFIG_34,  DEF_CONFIG_35,  
    DEF_CONFIG_36,  DEF_CONFIG_37,  DEF_CONFIG_38,  DEF_CONFIG_39,  
    DEF_CONFIG_40,  DEF_CONFIG_41,  DEF_CONFIG_42,  DEF_CONFIG_43,  
    DEF_CONFIG_44,  DEF_CONFIG_45,  DEF_CONFIG_46,  DEF_CONFIG_47,  
    DEF_CONFIG_48,  DEF_CONFIG_49,  DEF_CONFIG_50,  DEF_CONFIG_51,  
    DEF_CONFIG_52,  DEF_CONFIG_53,  DEF_CONFIG_54,  DEF_CONFIG_55,  
    DEF_CONFIG_56,  DEF_CONFIG_57,  DEF_CONFIG_58,  DEF_CONFIG_59,  
    DEF_CONFIG_60,  DEF_CONFIG_61,  DEF_CONFIG_62,  DEF_CONFIG_63,  
    DEF_CONFIG_64,  DEF_CONFIG_65,  DEF_CONFIG_66,  DEF_CONFIG_67,  
    DEF_CONFIG_68,  DEF_CONFIG_69,  DEF_CONFIG_70,  DEF_CONFIG_71,  
    DEF_CONFIG_72,  DEF_CONFIG_73,  DEF_CONFIG_74,  DEF_CONFIG_75,  
    DEF_CONFIG_76,  DEF_CONFIG_77,  DEF_CONFIG_78,  DEF_CONFIG_79,  
    DEF_CONFIG_80,  DEF_CONFIG_81,  DEF_CONFIG_82,  DEF_CONFIG_83,  
    DEF_CONFIG_84,  DEF_CONFIG_85,  DEF_CONFIG_86,  DEF_CONFIG_87,  
    DEF_CONFIG_88,  DEF_CONFIG_89,  DEF_CONFIG_90,  DEF_CONFIG_91,  
    DEF_CONFIG_92,  DEF_CONFIG_93,  DEF_CONFIG_94,  DEF_CONFIG_95,  
    DEF_CONFIG_96,  DEF_CONFIG_97,  DEF_CONFIG_98,  DEF_CONFIG_99,  
    DEF_CONFIG_100, DEF_CONFIG_101, DEF_CONFIG_102, DEF_CONFIG_103, 
    DEF_CONFIG_104, DEF_CONFIG_105, DEF_CONFIG_106, DEF_CONFIG_107, 
    DEF_CONFIG_108, DEF_CONFIG_109, DEF_CONFIG_110, DEF_CONFIG_111, 
    DEF_CONFIG_112, DEF_CONFIG_113, DEF_CONFIG_114, DEF_CONFIG_115, 
    DEF_CONFIG_116, DEF_CONFIG_117, DEF_CONFIG_118, DEF_CONFIG_119, 
    DEF_CONFIG_120, DEF_CONFIG_121, DEF_CONFIG_122, DEF_CONFIG_123, 
    DEF_CONFIG_124, DEF_CONFIG_125, DEF_CONFIG_126, DEF_CONFIG_127  
};
