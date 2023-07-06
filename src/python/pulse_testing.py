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
    

# Set up serial port
ser = serial.Serial()
ser.baudrate = 115200
ser.port = 'COM3'
ser.open()

addr = 1 << 12
data = 1
write(ser, addr, data)
time.sleep(0.2)
data = 2
write(ser, addr, data)
time.sleep(0.2)
data = 3
write(ser, addr, data)
time.sleep(0.2)
data = 4
write(ser, addr, data)
time.sleep(0.2)
