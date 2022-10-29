import serial
import serial.tools.list_ports
import binascii
from tkinter import *
#import tkinter as tk

C_ADR_BASE_REG  = 0x0000
C_ADR_BASE_I2C  = 0x1000

C_ADR_REG_HDL_VERSION = C_ADR_BASE_REG + 16
C_ADR_REG_OUT0        = C_ADR_BASE_REG + 0

outputfile = open("test_smc2.txt", 'w')
outputfile.write("test_smc2.txt\n")
outputfile.write("test_smc2.txt\n")

# Get a list of COM ports
for item in serial.tools.list_ports.comports():
    print(item)
    #outputfile.write(item)
    strComPort = item[0]
	

# Open last COM port in the list
ser = serial.Serial(strComPort , baudrate=115200, bytesize=8, parity='N', stopbits=1, timeout=1)
#ser = serial.Serial('COM3' , baudrate=115200, bytesize=8, parity='N', stopbits=1, timeout=1)

nAddress = C_ADR_REG_HDL_VERSION
#nAddress = 0x0010
nData    = 0x12345678
msg = [ord('R'), ((nAddress & 0xFF00)>>8), (nAddress & 0xFF), ((nData & 0xFF000000)>>24), ((nData & 0xFF0000)>>16), ((nData & 0xFF00)>>8), (nData & 0xFF)] 
txmsg = bytearray(msg)
print(txmsg)
ser.write(txmsg)

rxmsg = ser.read(5)
if chr(rxmsg[0]) == 'A':
    print("Good")
else:
    print("*** NO ACK ***")
	
hex_rxmsg = binascii.hexlify(rxmsg[1:])
print("Received = ", hex_rxmsg)
hex_str = hex_rxmsg.decode("ascii")
print(hex_str) 
outputfile.write(hex_str)
outputfile.close()

# Force LED Green on
# Set bit 28, 29 in Reg_out0
nAddress = C_ADR_REG_OUT0
nData    = (0x0 << 28) + (0x1 << 29)
msg = [ord('W'), ((nAddress & 0xFF00)>>8), (nAddress & 0xFF), ((nData & 0xFF000000)>>24), ((nData & 0xFF0000)>>16), ((nData & 0xFF00)>>8), (nData & 0xFF)] 
txmsg = bytearray(msg)
hex_txmsg = binascii.hexlify(txmsg)
print(msg[0], hex_txmsg[2:6]," ", hex_txmsg[7:])
ser.write(txmsg)

root = Tk()

w = Label(root, text="Hello Tkinter!")
w.pack()

buttonDone     = Button(mw, text = "Done", width = 6)

root.mainloop()
