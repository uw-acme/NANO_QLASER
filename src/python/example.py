# Example of how to use the [qlaser_zcu library](https://github.com/uw-acme/qlaser_zcu) to generate waveforms and pulses
import numpy as np                             # for waveform generation
from qlaser_zcu.wavecli import *               # Front-end interface to convert user-defined waveform data and pulse parameters into addressable instructions
from qlaser_zcu.qlaser_fpga import QlaserFPGA  # the class that wraps the communication with the FPGA
from loguru import logger                      # a nice logging for debugging and development purpose

# generate waveforms
sin = np.sin(np.linspace(0, np.pi/2, 60))
for i, value in enumerate(sin):
    sin[i] = vdac_to_hex(value)  # convert to DAC values
    
linear = np.linspace(0, 2.3, 20)  # linear ramp from 0 to 2.3 volt
for i, value in enumerate(linear):
    linear[i] = vdac_to_hex(value)  # convert to DAC values

    
# add some waves. Make sure your are inputting integer values
wave0 = add_wave(sin.astype(int), keep_previous=False)
wave1 = add_wave(linear.astype(int))

# define some pulses
dfn = [{
        "wave_id": wave0,
        "start_time": 5,
        "scale_gain": 1.0,
        "scale_time": 1.0,
        "sustain": 4
    },
    {
        "wave_id": wave1,
        "start_time": 5 + 2*len(sin) + 4 + 5, # start after the first pulse, plus 5 ticks of delay
        "scale_gain": 1.0,
        "scale_time": 1.0,
        "sustain": 5
    },{
        # Let's have the third pulse have same profile as the first one, but runs twice as fast 
        "wave_id": wave0,
        "start_time": 5 + 2*len(sin) + 4 + 5 + 2*len(linear) + 5 + 5,  # start after the second pulse, plus 5 ticks of delay
        "scale_gain": 1.0,
        "scale_time": 2.0,  # x2 faster on its rise and fall
        "sustain": 2        # x2 shorter sustain time
    }
]

sequence_len = 10000  # 10,000 ticks, or 1.0 ms (10 us per tick)
set_defns(dfn, sequence_len, 0)
enable_channels(0)  # enable channel 0 to run the sequence

# read back the pulse definitions
logger.info("Pulse Definitions:")
logger.info(get_defns(0))
# read back the wave table
logger.info("Wave Table:")
logger.info(get_wave(wave0))
logger.info(get_wave(wave1))

# Interract with the FPGA using the core class directly
hw = QlaserFPGA()  # Note: this will ALWAYS connect to the FPGA. To make sure the port only used once, directly do `QlaserFPGA().<any functions>()` instead of assigning it to a variable.
hw.write_dc_chan(0, 1234)  # write DC channel 0 with value 1234 (out of 4096 dac values)


# PROTYTPE DEBUG ONLY
# Send a command to the FPGA to continuously trigger the pulse sequence
# To stop the pulse sequence, you can send "0t" to the FPGA
hw.ser.write(b'0t')  # "t" is the command to trigger the pulse sequence, "0" is to turn it off. Make sure to turn it off before turning it on again.
hw.ser.write(b'1t')  # "1" is to turn it on. Note that the FPGA will automatically trigger again once its resource is available.
hw.print_all()       # Dump out any messages from the FPGA

hw.read_errs()