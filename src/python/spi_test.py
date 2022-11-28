import serial
import time
import random
import PySimpleGUI as gui


def write(ser, addr, data):
    print ('Write regaddr = 0x{:04x}' .format(addr))
    print ('Write data    = 0x{:08x}' .format(data))
    msg = addr.to_bytes(2, byteorder='big') + data.to_bytes(4, byteorder='big')
    msg = b'\x57' + msg
    print(msg)
    ser.write(msg)

def get_value(val, ref, resolution):
    step = ref / (2.0 ** resolution - 1)
    data = int(val / step)
    return data
    
def get_address(val):
    spi = val / 8
    addr = val % 8
    
    return int(spi) << 10, addr
    

# Set up serial port
ser = serial.Serial()
ser.baudrate = 115200
ser.port = 'COM3'
ser.open()

# Turn on all DACs
write(ser, 0x0000, 0x08000001)
write(ser, 0x0000, 0x04000000)
write(ser, 0x0000, 0x04100000)
write(ser, 0x0000, 0x04200000)
write(ser, 0x0000, 0x04300000)
write(ser, 0x0000, 0x04400000)
write(ser, 0x0000, 0x04500000)
write(ser, 0x0000, 0x04600000)
write(ser, 0x0000, 0x04700000)

write(ser, 0x0400, 0x08000001)
write(ser, 0x0400, 0x04000000)
write(ser, 0x0400, 0x04100000)
write(ser, 0x0400, 0x04200000)
write(ser, 0x0400, 0x04300000)
write(ser, 0x0400, 0x04400000)
write(ser, 0x0400, 0x04500000)
write(ser, 0x0400, 0x04600000)
write(ser, 0x0400, 0x04700000)


layout = [[gui.Text("DC Channels")], 
          [gui.Text('Channel 0', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 0")],
          [gui.Text('Channel 1', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 1")],
          [gui.Text('Channel 2', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 2")],
          [gui.Text('Channel 3', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 3")],
          [gui.Text('Channel 4', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 4")],
          [gui.Text('Channel 5', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 5")],
          [gui.Text('Channel 6', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 6")],
          [gui.Text('Channel 7', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 7")],
          [gui.Text('Channel 8', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 8")],
          [gui.Text('Channel 9', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 9")],
          [gui.Text('Channel 10', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 10")],
          [gui.Text('Channel 11', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 11")],
          [gui.Text('Channel 12', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 12")],
          [gui.Text('Channel 13', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 13")],
          [gui.Text('Channel 14', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 14")],
          [gui.Text('Channel 15', size=(15, 1)), gui.InputText(), gui.Button("Enter Channel 15")]]    
window = gui.Window("DC Dacs", layout)
val = 0

while True:
    event, values = window.read()
    if event == gui.WIN_CLOSED:
        break
    elif event:
        e = event.split()
        # The last item in e is the channel number
        valIndex = int(e[len(e) - 1])
        print(valIndex)
        # Retrieve the entered value
        val = values[valIndex]
        print(val)
        # Convert the value to a number between 0 and 4095
        data = get_value(float(val), 2.5, 12)
        print(data)
        # Convert channel number in SPI # and DAC address within SPI
        spi, addr = get_address(valIndex)
        print(spi)
        print(addr)
        # Format data
        data = (3 << 16) + (addr << 12) + data
        print(data)
        # Write to the FPGA
        write(ser, spi, data << 8)
        

window.close()
    
