#---------------------------------------------------------------
# GUI program for Quantum Laser Control FPGA on Eclypse board
# with 16 DAC channels (2x PMOD-DAC4)
#---------------------------------------------------------------

from tkinter import *
import serial
import serial.tools.list_ports
#print(list(serial.tools.list_ports.comports()))

adrRegVersion = 0x8008
adrRegGpo     = 0x0008
dataGpo       = 0x55555555

#---------------------------------------------------------------
#---------------------------------------------------------------
root = Tk()
root.title('QLASER_DAC_DC')
strMsg              = StringVar()
strMsg1             = StringVar()
strRegReadAddr      = StringVar()
strRegReadData      = StringVar()
strReadData         = StringVar()
strRegWriteAddr     = StringVar()
strRegWriteData     = StringVar()
strRow              = StringVar()
strCol              = StringVar()
strFileNameHitText  = StringVar()

strReadData.set("0x----")
strRegWriteAddr.set("0x0001")

# Version reg address is 0x2000 i.e. bit 13 set
strRegReadAddr.set("0x2000")
strRegReadData.set("- -") 
#strFileNameHitText.set("HitDataText.txt") 

strRegWriteData.set("0x12345678")
#nRow = 32
#nCol = 15
#strRow.set(nRow)
#strCol.set(nCol)

#listHitCols = []
#listHitRows = []
#listHitMaps = []

#---------------------------------------------------------------
# Send a 
#---------------------------------------------------------------
def gj_send(ser, byte):
    print ('Send {}' .format(byte))
    ser.write(byte)

#---------------------------------------------------------------
# Read an entire line from the receive UART
#---------------------------------------------------------------
def gj_recvline(ser):
    line = ser.readline()
    print ('{}' .format(line))
    

#---------------------------------------------------------------
# Read a register from the FPGA
# Convert address into a byte array.
# Send a read command sequence ('R' address16 data32)
#---------------------------------------------------------------
def gj_reg_read(ser, strRegAddr):
    regaddr     = 0
    regaddr = int(strRegAddr.get(), base = 16)
    wdata   = 0xFFFFFFFE # dummy data to get the correct message length
    print ('Read regaddr    = 0x{:04x}' .format(regaddr))
    print ('Write data      = 0x{:08x}' .format(wdata))
    strMsg = regaddr.to_bytes(2, byteorder='big') + wdata.to_bytes(4, byteorder='big')

    ser.write(b'\x52')
    ser.write(strMsg)

    # Read 5 characters from serial port ('A' data32)
    rdata = ser.read(5)
    print ('Read data     0x' + str(rdata[1:].hex()))
    str_rdata = str(rdata[1:].hex())
    str_rdata = '0x' + str_rdata.upper()
    #print ('Read data     = 0x{:5x}' .format(rdata))
    strRegReadData.set(str_rdata) 


#---------------------------------------------------------------
# Write 32-bit data to a 16-bit register address in the FPGA.
# Convert address and data into byte arrays.
# Send a write command sequence (W address16 data32)
#---------------------------------------------------------------
def gj_reg_write(ser, strRegAddr, strRegData):
    
    regaddr     = 0
    wdata       = 0

    regaddr = int(strRegAddr.get(), base = 16)
    wdata   = int(strRegData.get(), base = 16)

    print ('Write regaddr   = 0x{:04x}' .format(regaddr))
    print ('Write data      = 0x{:08x}' .format(wdata))

    strMsg = regaddr.to_bytes(2, byteorder='big') + wdata.to_bytes(4, byteorder='big')
    ser.write(b'\x57')
    ser.write(strMsg)
     
     
#---------------------------------------------------------------
# Write 32-bit data to a 16-bit register address in the FPGA.
# Convert address and data into byte arrays.
# Send a write command sequence (W address16 data32)
#---------------------------------------------------------------
def gj_reg_write_int(ser, regaddress, wdata):
    
    print ('Write regaddress = 0x{:04x}' .format(regaddress))
    print ('Write data       = 0x{:08x}' .format(wdata))
    strMsg = regaddress.to_bytes(2, byteorder='big') + wdata.to_bytes(4, byteorder='big')
    ser.write(b'\x57')
    ser.write(strMsg)


#---------------------------------------------------------------
    
lambda: gj_recv(ser)

#---------------------------------------------------------------
# Get a list of serial ports. Open first COM port.
#---------------------------------------------------------------
comlist = (list(serial.tools.list_ports.comports()))
print('Number of ports = {0:8}' .format(len(comlist)))

if len(comlist) > 0:
    portinfo = comlist[0]
    portname = portinfo[0]
    print(portname)

     # Open serial port
    ser = serial.Serial(
        port = portname,\
        baudrate=115200,\
        parity=serial.PARITY_NONE,\
        stopbits=serial.STOPBITS_ONE,\
        bytesize=serial.EIGHTBITS,\
        timeout=1)

    strMsg.set(ser.name)
    strMsg1.set(comlist[0][0])

else:
    print("No ports")
    strMsg.set("None")
    strMsg1.set("0")
#---------------------------------------------------------------


#---------------------------------------------------------------
# Build GUI
#---------------------------------------------------------------
frameSerialPorts = Frame(root, padx = 5, pady = 2)
Label (frameSerialPorts, text = 'Serial Ports').pack(side = LEFT, padx = 5, pady = 5)
Entry (frameSerialPorts, width = 10, textvariable = strMsg1).pack(side=RIGHT, padx = 5, pady = 5)
frameSerialPorts.pack(side=TOP, padx = 10, pady = 5)

#frameStartStop = Frame(root, borderwidth=3, relief=GROOVE, padx = 5, pady = 5)
#buttonStart     = Button (frameStartStop, width = 10, text = "Start", state=DISABLED,  command = lambda: gj_send(ser, b'\x53') )
#buttonStart.pack(side=LEFT,  padx = 5, pady = 5)
#buttonStop      = Button (frameStartStop, width = 10, text = "Stop" , state=DISABLED,  command = lambda: gj_send(ser, b'\x73') )
#buttonStop.pack(side=RIGHT, padx = 5, pady = 5)
#frameStartStop.pack(side=TOP, padx = 5, pady = 5)

#-----------------------------------------------------------------------------------------------------------------------------
# Frame to hold row and column
#-----------------------------------------------------------------------------------------------------------------------------
#frameRowCol   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)
#Label (frameRowCol, text = 'Row').pack(side = LEFT, padx = 5, pady = 5)
#Entry (frameRowCol, width = 10, textvariable = strRow).pack(side=LEFT, padx = 5, pady = 5)
#Label (frameRowCol, text = 'Col').pack(side = LEFT, padx = 5, pady = 5)
#Entry (frameRowCol, width = 10, textvariable = strCol).pack(side=LEFT, padx = 5, pady = 5)
#buttonRowColSet  = Button (frameRowCol, width = 10, text = "Set",        command = lambda: gj_row_col_set(ser), state=DISABLED)
#buttonRowColSet.pack(side=LEFT)
#frameRowCol.pack(side=TOP, padx = 5, pady = 5)
#
## Define an array of variables for the hitmap
#arrHitMap = []
#for i in range(0,16,1):
#    arrHitMap.append(IntVar())
## Make a frame to hold a row of checkboxes representing the upper section of the hitmap
#frameHitMapUp   = Frame(root, borderwidth=3,relief=GROOVE, padx = 1, pady = 1)
#frameHitMapLo   = Frame(root, borderwidth=3,relief=GROOVE, padx = 1, pady = 1)
#
#cbHitMap0       = Checkbutton(frameHitMapUp, text="", variable=arrHitMap[0]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap1       = Checkbutton(frameHitMapUp, text="", variable=arrHitMap[1]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap2       = Checkbutton(frameHitMapUp, text="", variable=arrHitMap[2]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap3       = Checkbutton(frameHitMapUp, text="", variable=arrHitMap[3]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap4       = Checkbutton(frameHitMapUp, text="", variable=arrHitMap[4]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap5       = Checkbutton(frameHitMapUp, text="", variable=arrHitMap[5]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap6       = Checkbutton(frameHitMapUp, text="", variable=arrHitMap[6]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap7       = Checkbutton(frameHitMapUp, text="", variable=arrHitMap[7]).pack(side=LEFT, padx = 1, pady = 1)
#
#cbHitMap8       = Checkbutton(frameHitMapLo, text="", variable=arrHitMap[8]).pack(side=LEFT,  padx = 1, pady = 1)
#cbHitMap9       = Checkbutton(frameHitMapLo, text="", variable=arrHitMap[9]).pack(side=LEFT,  padx = 1, pady = 1)
#cbHitMap10      = Checkbutton(frameHitMapLo, text="", variable=arrHitMap[10]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap11      = Checkbutton(frameHitMapLo, text="", variable=arrHitMap[11]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap12      = Checkbutton(frameHitMapLo, text="", variable=arrHitMap[12]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap13      = Checkbutton(frameHitMapLo, text="", variable=arrHitMap[13]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap14      = Checkbutton(frameHitMapLo, text="", variable=arrHitMap[14]).pack(side=LEFT, padx = 1, pady = 1)
#cbHitMap15      = Checkbutton(frameHitMapLo, text="", variable=arrHitMap[15]).pack(side=LEFT, padx = 1, pady = 1)
#
#frameHitMapUp.pack(side=TOP)
#frameHitMapLo.pack(side=TOP)

#-----------------------------------------------------------------------------------------------------------------------------
# Frame for filename of output text file containing a set of hit descriptions in a readable text format
#-----------------------------------------------------------------------------------------------------------------------------
#frameFileHitTextWrite   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)
#Label   (frameFileHitTextWrite, text = 'File').pack(side = LEFT, padx = 5, pady = 5)
#Entry   (frameFileHitTextWrite, width = 15, textvariable = strFileNameHitText).pack(side=LEFT, padx = 5, pady = 5)
#buttonFileHitTextWrite  = Button (frameFileHitTextWrite, width = 10, text = "Write File",        command = lambda: FileHitDataTextWrite(strFileNameHitText.get()), state=DISABLED)
#buttonFileHitTextWrite.pack(side=LEFT)
#frameFileHitTextWrite.pack(side=TOP, padx = 5, pady = 5)

#-----------------------------------------------------------------------------------------------------------------------------
# Write a register
#-----------------------------------------------------------------------------------------------------------------------------
frameRegWrite   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)
Label (frameRegWrite, text = 'Write Address').pack(side = LEFT, padx = 5, pady = 5)
Entry (frameRegWrite, width = 10, textvariable = strRegWriteAddr).pack(side=LEFT, padx = 5, pady = 5)
Label (frameRegWrite, text = 'Data').pack(side = LEFT, padx = 5, pady = 5)
Entry (frameRegWrite, width = 12, textvariable = strRegWriteData).pack(side=LEFT, padx = 5, pady = 5)
buttonRegWrite  = Button (frameRegWrite, width = 10, text = "Write",        command = lambda: gj_reg_write(ser, strRegWriteAddr, strRegWriteData), state=DISABLED)
buttonRegWrite.pack(side=LEFT)
frameRegWrite.pack(side=TOP, padx = 5, pady = 5)

#-----------------------------------------------------------------------------------------------------------------------------
# Read a register
#-----------------------------------------------------------------------------------------------------------------------------
frameRegRead   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)
Label (frameRegRead, text = 'Read Address').pack(side = LEFT, padx = 5, pady = 5)
Entry (frameRegRead, width = 10, textvariable = strRegReadAddr).pack(side=LEFT, padx = 5, pady = 5)
Label (frameRegRead, text = 'Data').pack(side = LEFT, padx = 5, pady = 5)
Entry (frameRegRead, width = 12, textvariable = strRegReadData).pack(side=LEFT, padx = 5, pady = 5)
buttonRegRead  = Button (frameRegRead, width = 10, text = "Read",        command = lambda: gj_reg_read(ser, strRegReadAddr), state=DISABLED)
buttonRegRead.pack(side=LEFT)
frameRegRead.pack(side=TOP, padx = 5, pady = 5)


#buttonWriteGPO  = Button (root, width = 10, text = "Write GPO",   command = lambda: gj_reg_write_int(ser, adrRegGpo, dataGpo))
#buttonWriteGPO.pack(side=BOTTOM, padx = 5, pady = 5)

#buttonReadGPO   = Button (root, width = 10, text = "Read GPO",    command = lambda: gj_reg_read_int(ser, adrRegGpo))
#buttonReadGPO.pack(side=BOTTOM, padx = 5, pady = 5)

#frameQuitHelp   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)

frameQuitHelp   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)
buttonHelp      = Button (frameQuitHelp, width = 10, text = "Help",        command = lambda: gj_send(ser, b'\x68')).pack(side=LEFT, padx = 5, pady = 5)
buttonQuit      = Button (frameQuitHelp, width = 10, text = "Quit",        command = root.quit).pack(side=RIGHT, padx = 5, pady = 5)
frameQuitHelp.pack(side=BOTTOM, padx = 5, pady = 5)

# Enable buttons if a COM port is present
if len(comlist) != 0:
   #buttonStart.config(state=NORMAL)
   #buttonStop.config(state=NORMAL)
    buttonRegWrite.config(state=NORMAL)
    buttonRegRead.config(state=NORMAL)
   #buttonRowColSet.config(state=NORMAL)
   #buttonFileHitTextWrite.config(state=NORMAL)
#    buttonFileHitTextRead.config(state=NORMAL)

mainloop()

