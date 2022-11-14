import serial
import time
import random


def write(ser, addr, data):
    print ('Write regaddr = 0x{:04x}' .format(addr))
    print ('Write data    = 0x{:08x}' .format(data))
    msg = addr.to_bytes(2, byteorder='big') + data.to_bytes(4, byteorder='big')
    msg = b'\x57' + msg
    print(msg)
    ser.write(msg)
    
    
    
ser = serial.Serial()
ser.baudrate = 115200
ser.port = 'COM3'
ser.open()
data = 0

write(ser, 0, 0xAAAAAAAA)