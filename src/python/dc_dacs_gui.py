
#---------------------------------------------------------------
#--  File         : dc_dacs_gui.py
#--  Description  : Python script to set DAC output values using a GUI
#---------------------------------------------------------------

import serial
import time
import random
import PySimpleGUI as gui

import pandas as pd



# Writes a single message out on the UART interface with the given address and data.
def write(ser, addr, data):
    print ('Write regaddr = 0x{:04x}' .format(addr))
    print ('Write data    = 0x{:08x}' .format(data))
    msg = addr.to_bytes(2, byteorder='big') + data.to_bytes(4, byteorder='big')
    msg = b'\x57' + msg
    print(msg)
    ser.write(msg)

# Writes a message to the FPGA with Read command at an address. The FPGA should return 32 bits of data    
def read(ser, addr):
    print ('Write regaddr = 0x{:04x}' .format(addr))
    print ('Write data    = 0x{:08x}' .format(0))
    msg = addr.to_bytes(2, byteorder='big') + data.to_bytes(4, byteorder='big')
    msg = b'\x52' + msg
    print(msg)
    # Send a message to the FPGA in the form "RAAAADDDDDDDD"
    ser.write(msg)
    
    # Read the 4 bytes that get sent back.
    return ser.read(4)

# Calculates the binary representation as of the desired voltage given the reference voltage.
# Output the number of bits for the output is determined by the resolution parameter.
def get_value(val, ref, resolution):
    # Cap val at the reference voltage and non negative
    if val > ref:
        val = ref
    elif val < 0:
        val = 0
    
    
    step = ref / (2.0 ** resolution - 1)
    data = int(val / step)
    return data

# Given a SPI channel number, returns spi number for a pmod it's address in the FPGA.    
def get_address(val):
    spi = val / 8
    addr = val % 8
    
    return int(spi), addr

# Takes SPI channel number and desired voltage and makes the update on the Pmod.
def update_channel(ch, val):
    data = get_value(float(val), 3.3, 12)
    print(data)
    # Convert channel number in SPI # and DAC address within SPI
    spi, addr = get_address(ch)
    print(spi)
    print(addr)
    # Format address
    addr = (spi << 3) + addr;
    print(addr)
    # Write to the FPGA
    write(ser, addr, data)
    

def add_pulse(ch, amplitude, duration, last):
    # Convert the amplitude to the binary data value
    data = get_value(float(amplitude), 3.3, 16)
    ## select the pulse block
    addr = 1 << 12
    
    ## add the channel id to the address, which is just channel
    addr = addr + ch
    
    # send the start time of the pulse first
    write(ser, addr, int(times[ch] * 10))
    # add duration to the channel time, so that the next added pulse sends that time.
    times[ch] = times[ch] + duration
    
    # send the amplitude of the pulse
    write(ser, addr, data)
    
    # If this is the last pulse on the channel for the experiment, send an amplitude of 0 with the end time.
    if last:
        write(ser, addr, int(times[ch] * 10))
        times[ch] = 0
        write(ser, addr, 0)
        
def linear_ramp(ch, start_amp, end_amp, duration):
    
    # Calculate amplitude step value
    step = (end_amp - start_amp) / duration
    
    current_amp = start_amp
    
    # add pulses starting at start_amp and step up until end_amp
    for i in range(0, duration + 1):
        if current_amp == end_amp:
            add_pulse(ch, current_amp, 1, True)
        else:
            add_pulse(ch, current_amp, 1, False)
        
        current_amp = current_amp + step
        
   
    
    
ser.port = 'COM3'
ser.open()

# Power on all DACs
write(ser, 0x0030, 0x00000000)
times = [0] * 32

add_pulse(5, 2.2, 5, False)
add_pulse(5, 3.3, 10, False)

linear_ramp(6, 0, 3.3, 3)

print(times)

ser.port = 'COM4'
ser.open()

# Enable the internal references.
# This can be removed once the external reference supply has been connected (pmod board modification)
write(ser, 0x0028, 0x00000000)

# Power on all DACs
write(ser, 0x0030, 0x00000000)






layout = [[gui.Text("DC Channels")], 

          [gui.Text('Channel 1', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 1")],
          [gui.Text('Channel 2', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 2")],
          [gui.Text('Channel 3', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 3")],
          [gui.Text('Channel 4', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 4")],
          [gui.Text('Channel 5', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 5")],
          [gui.Text('Channel 6', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 6")],
          [gui.Text('Channel 7', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 7")],
          [gui.Text('Channel 8', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 8")],
          [gui.Text('Channel 9', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 9")],
          [gui.Text('Channel 10', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 10")],
          [gui.Text('Channel 11', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 11")],
          [gui.Text('Channel 12', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 12")],
          [gui.Text('Channel 13', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 13")],
          [gui.Text('Channel 14', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 14")],
          [gui.Text('Channel 15', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 15")],
          [gui.Text('Update All', size=(15, 1)), gui.Button("Enter")],
          [gui.Text('Set All Channels', size=(15, 1)), gui.InputText(), gui.Button("Enter All")],
          [gui.Text('Version', size=(15, 1)), gui.Text("Press button to read Version ->", key='Version'), gui.Button("Read Version")],

          [gui.Text('Choose a file: ', size=(15, 1)), gui.Input(), gui.FileBrowse(key="FileName"), gui.Button("Submit")],
          ]    
window = gui.Window("DC Dacs", layout)
val = 0

while True:
    event, values = window.read()
    if event == gui.WIN_CLOSED:
        break
    elif event == "Enter All":
        data = get_value(float(values[16]), 3.3, 12)
        addr = 4 << 3
        write(ser, addr, data)
    elif event == "Enter":
        for i in range(0, 16):
            update_channel(i, values[i])
    elif event == "Read Version":
        # Select the misc block
        addr = 1 << 13
        # To read the version register, addr bits 3 downto 0 should be 0.
        num = read(ser, addr)
        window['Version'].update(hex(num))

    elif event == "Submit":
        path = values["FileName"]
        df = pd.read_excel(path)
        print(path)
        print(df)
        addr = -1
        for i in range(0, 32):
            j = 1
            addr = addr + 1
            time = 0
            while(df.loc[i].iat[j] != "end"):
                val = df.loc[i].iat[j]
                
                # If j is odd, we are sending a duration
                if j % 2 == 1:
                    # The duration entry in the excel sheet is number of 100 ns periods
                    # The fpga is looking for 10 ns periods
                    # Send time * 10, then add val to the overall time.
                    write(ser, addr, int(time * 10))
                    time = time + val
                else:
                    # We are sending an amplitude, get the binary representation and send it.
                    data = get_value(float(val), 3.3, 16)
                    write(ser, addr, data)
               
                j = j + 1
            
            # At the end, send the final time value to finish the last pulse, and send an amplitude of 0
            write(ser, addr, int(time * 10))
            write(ser, addr, 0)
                
                

    elif event:
        e = event.split()
        # The last item in e is the channel number
        valIndex = int(e[len(e) - 1])
        # Retrieve the entered value
        val = values[valIndex]
        # Update the channel
        update_channel(valIndex, val)
        

window.close()
    
