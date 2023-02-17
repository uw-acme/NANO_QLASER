#---------------------------------------------------------------
#--  File         : dc_dacs_gui.py
#--  Description  : Python script to set DAC output values using a GUI
#---------------------------------------------------------------

import serial
import time
import random
import PySimpleGUI as gui

# Writes a single message out on the UART interface with the given address and data.
def write(ser, addr, data):
    print ('Write regaddr = 0x{:04x}' .format(addr))
    print ('Write data    = 0x{:08x}' .format(data))
    msg = addr.to_bytes(2, byteorder='big') + data.to_bytes(4, byteorder='big')
    msg = b'\x57' + msg
    print(msg)
    ser.write(msg)

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
    

# Set up serial port
ser = serial.Serial()
ser.baudrate = 115200
ser.port = 'COM3'
ser.open()

# Enable the internal references.
# This can be removed once the external reference supply has been connected (pmod board modification)
write(ser, 0x0028, 0x00000000)

# Power on all DACs
write(ser, 0x0030, 0x00000000)






layout = [[gui.Text("DC Channels")], 
          [gui.Text('Channel 0', size=(15, 1)), gui.InputText(0), gui.Button("Enter Channel 0")],
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
    elif event:
        e = event.split()
        # The last item in e is the channel number
        valIndex = int(e[len(e) - 1])
        # Retrieve the entered value
        val = values[valIndex]
        # Update the channel
        update_channel(valIndex, val)
        

window.close()
    
