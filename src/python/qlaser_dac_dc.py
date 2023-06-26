#---------------------------------------------------------------
# GUI program for Quantum Laser Control FPGA on Eclypse board
# with 16 DAC channels (2x PMOD-DAC4)
#---------------------------------------------------------------
# The Pmod DA4 utilizes Analog Devices AD5628-1 to provide a 
# single DAC capable of 8 simultaneous output channels. 
# With its internal reference voltage of 1.25V and a gain of 2,
# a resolution of approximately 1 mV can be achieved.
#---------------------------------------------------------------

from tkinter import *
import serial
import serial.tools.list_ports

#---------------------------------------------------------------
# DAC chips on the PMOD DAC4 boards use a 1.25V internal reference by default.
# Internal reference has a 2x gain so outputs can be up to 2.5V
# A board modification is required to use an external refernce which would allow voltages up to 3.3V
#---------------------------------------------------------------
VREF_INTERNAL = "internal"
VREF_EXTERNAL = "external"
VREF_TYPE     = VREF_INTERNAL   # or 'external'
VOLTAGE_REF   = 1.25
#VOLTAGE_REF   = 3.3

# Configuration
DAC_BITS_RES  = 12
NUM_CHAN_DC   = 16
NUM_CHAN_AC   =  4


# Version reg address is 0x2000 i.e. bit 13 set
ADDR_REG_VERSION    = 0x2000
ADDR_REG_GPO        = 0x0008
dataGpo             = 0x55555555

#---------------------------------------------------------------
#---------------------------------------------------------------
root = Tk()
root.title('QLASER_DAC_DC v1.2')

strMsg              = StringVar()
strMsg1             = StringVar()

strAddrRegVersion   = StringVar()
strAddrRegVersion.set(str(hex(ADDR_REG_VERSION)))
strVersion          = StringVar()
print (strAddrRegVersion.get())
strVersion.set("- -") 


#---------------------------------------------------------------
# Initialize the DC channel voltage values
#---------------------------------------------------------------
listVdc = [] 
for i in range(NUM_CHAN_DC):   #  0 to 31
    listVdc.append(StringVar())
    listVdc[i].set(float(i)/10.0)
    


strFileNameAC       = StringVar()
strFileNameAC.set("AC.txt") 

#strRegWriteAddr     = StringVar()
#strRegWriteData     = StringVar()
#strRegWriteAddr.set("0x0001")
#strRegWriteData.set("0x12345678")


#---------------------------------------------------------------
# Send a single byte to COM port
#---------------------------------------------------------------
def gj_send(ser, byte):
    print ('Send {}' .format(byte))
    ser.write(byte)

#---------------------------------------------------------------
# Read an entire line from the receive COM port
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

    # Read 5 characters from serial port ('A' and data32)
    rdata = ser.read(5)

    # Convert 32-bit data into a hex string, print it and set it into the GUI entry box
    str_rdata = str(rdata[1:].hex())
    rvalue = int(str_rdata, 16)
    str_rdata = '0x' + str_rdata.upper()
    print ('Read data     = ' + str_rdata)
    return rvalue


#---------------------------------------------------------------
# Read version register from FPGA and set value in Entry box
#---------------------------------------------------------------
def read_version(ser):
    rvalue = gj_reg_read(ser, strAddrRegVersion)
    str_rdata = hex(rvalue)
    strVersion.set(str_rdata) 


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
# Convert the requested DAC output voltage to a binary representation
# based on the reference voltage.
# The number of bits for the output is determined by the 'dac_bits' parameter.
# E.g. If reference voltage is 2.5 and the number of DAC bits is 12 then 0xFFF will output 2.5V
#---------------------------------------------------------------
def vdac_to_hex(voltage, dac_bits, vref, vref_type):

    print('')
    #print('Voltage : ' + str(voltage) + '  DAC bits : ' + str(dac_bits) + ' vref : ' + str(vref) + ' vref_type : ' + vref_type)

    # Limit input to be between zero and the reference voltage
    if ((vref_type == VREF_INTERNAL) and (voltage > (2.0 * vref))):
        print('Limiting max voltage to 2x internal vref: ' + str(2.0*vref))
        voltage = 2.0 * vref

    elif (vref_type == VREF_EXTERNAL) and (voltage > vref) :
        print('Limiting max voltage to ext ref : ' + str(vref))
        voltage = vref

    elif (voltage < 0) :
        print('Limiting min voltage to : 0.0')
        voltage = 0
        
    # Convert voltage to DAC setting
    if (vref_type == 'internal'):
        step = 2.0 * vref / (2.0 ** dac_bits)
    else:
        step = vref / (2.0 ** dac_bits)

    # Make DAC code
    dac_code = int(voltage/step)

    if (dac_code > (2** dac_bits) - 1): 
        dac_code = (2**dac_bits) - 1
        print('Limiting max dac_code to : ' + hex(dac_code))

   #print('Step : ' + str(step) + '  Code : ' + str(dac_code) + ' (' + hex(dac_code) + ')')

    return dac_code


#---------------------------------------------------------------
# Given a DC channel number, returns register address in the FPGA.    
#---------------------------------------------------------------
def chan_dc_to_addr(channel):
    spi = int(channel / 8)
    dac_channel = int(channel % 8)

    # Format address
    addr = (spi << 3) + dac_channel ;
    
    print('Channel : ' + str(channel) + ' =>  Port : ' + str(spi) + '   FPGA address : ' + hex(addr))
     
    return addr


#---------------------------------------------------------------
# Takes SPI channel number and desired voltage and writes 
# to the PMOD DAC 
#---------------------------------------------------------------
def set_chan_dc(ser, dac_chan, voltage):

    # Convert voltage to DAC data value
    # If reference voltage is 2.5 and the number of DAC bits is 12 then 0xFFF will output 2.5V
    wdata = vdac_to_hex(float(voltage), DAC_BITS_RES, VOLTAGE_REF, VREF_TYPE)
    
    # Convert channel number to FPGA address
    regaddress = chan_dc_to_addr(dac_chan)

    # Write to the FPGA
    gj_reg_write_int(ser, regaddress, wdata)


#---------------------------------------------------------------
# Set all DACs to values in Entry boxes
#---------------------------------------------------------------
def set_all_dc():
    for i in range(16):
        set_chan_dc(ser, i, listVdc[i].get())


#---------------------------------------------------------------
# ENOD OF FUNCTION DEFINITIONS
#---------------------------------------------------------------

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
# Enable the internal reference.
# This can be removed once the external reference supply has 
# been connected (pmod board modification)
#---------------------------------------------------------------
if (VREF_TYPE == 'internal'):
    gj_reg_write_int(ser, 0x0028, 0x00000000)

#---------------------------------------------------------------
# Power on all DACs
#---------------------------------------------------------------
gj_reg_write_int(ser, 0x0030, 0x00000000)


#---------------------------------------------------------------
# Build GUI
#---------------------------------------------------------------
frameSerialPorts = Frame(root, padx = 1, pady = 1)
Label (frameSerialPorts, text = 'Serial Ports').pack(side = LEFT, padx = 5, pady = 1)
Entry (frameSerialPorts, width = 10, textvariable = strMsg1).pack(side=RIGHT, padx = 5, pady = 1)
frameSerialPorts.pack(side=TOP, padx = 10, pady = 1)

# Set all DAC channels 
frameSetAllDC = Frame(root, borderwidth=3, relief=FLAT, padx = 5, pady = 5)
buttonSetAllDC     = Button (frameSetAllDC, width = 10, text = "Set All",  command = lambda: set_all_dc(), state=DISABLED)
buttonSetAllDC.pack(side=LEFT,  padx = 5, pady = 5)
frameSetAllDC.pack(side=TOP, padx = 5, pady = 5)


#-----------------------------------------------------------------------------------------------------------------------------
# Frame for filename of text file containing a set of AC DAC data
#-----------------------------------------------------------------------------------------------------------------------------
#frameFileAC  = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)
#Label   (frameFileAC, text = 'File').pack(side = LEFT, padx = 5, pady = 5)
#Entry   (frameFileHitTextWrite, width = 15, textvariable = strFileNameHitText).pack(side=LEFT, padx = 5, pady = 5)
#buttonFileHitTextWrite  = Button (frameFileHitTextWrite, width = 10, text = "Write File",        command = lambda: FileHitDataTextWrite(strFileNameHitText.get()), state=DISABLED)
#buttonFileHitTextWrite.pack(side=LEFT)
#frameFileHitTextWrite.pack(side=TOP, padx = 5, pady = 5)

#-----------------------------------------------------------------------------------------------------------------------------
# Write a register
#-----------------------------------------------------------------------------------------------------------------------------
#frameRegWrite   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 1)
#Label (frameRegWrite, text = 'Write Address').pack(side = LEFT, padx = 5, pady = 5)
#Entry (frameRegWrite, width = 10, textvariable = strRegWriteAddr).pack(side=LEFT, padx = 5, pady = 5)
#Label (frameRegWrite, text = 'Data').pack(side = LEFT, padx = 5, pady = 5)
#Entry (frameRegWrite, width = 12, textvariable = strRegWriteData).pack(side=LEFT, padx = 5, pady = 5)
#buttonRegWrite  = Button (frameRegWrite, width = 10, text = "Write",        command = lambda: gj_reg_write(ser, strRegWriteAddr, strRegWriteData), state=DISABLED)
#buttonRegWrite.pack(side=LEFT)
#frameRegWrite.pack(side=TOP, padx = 5, pady = 1)

arrFrameCh      = []
arrButtonSetCh  = []
#-----------------------------------------------------------------------------------------------------------------------------
# Frame for PMOD A channels 0 to 7
#-----------------------------------------------------------------------------------------------------------------------------
framePmodTop    = Frame(root, borderwidth=3, padx = 5, pady = 0)
framePmodATop   = Frame(framePmodTop, borderwidth=1, padx = 5, pady = 0)
Label (framePmodATop, text = 'PMOD-A').pack(side = LEFT, padx = 5, pady = 2)

framePmodA = Frame(framePmodATop, borderwidth=1,relief=GROOVE, padx = 2, pady = 2)
for i in range(8):   #  0 to 7
    arrFrameCh.append(Frame(framePmodA, borderwidth=1, padx = 2, pady = 1))
    Label (arrFrameCh[i], text = ('ch'+ str(i))).pack(side = LEFT, padx = 2, pady = 1)
    Entry (arrFrameCh[i], width = 8, textvariable = listVdc[i]).pack(side=LEFT, padx = 2, pady = 1)
    Label (arrFrameCh[i], text = 'V').pack(side = LEFT, padx = 1, pady = 1)
    ButtonSetCh = Button(arrFrameCh[i], width = 5, text = ('Set ' + str(i)), command = lambda ch=i: set_chan_dc(ser, ch, listVdc[ch].get()), state=DISABLED)
    arrButtonSetCh.append(ButtonSetCh)
    ButtonSetCh.pack(side=LEFT)
    arrFrameCh[i].pack(side=TOP, padx = 2, pady = 1)

framePmodA.pack(side=TOP, padx = 5, pady = 0)
framePmodATop.pack(side=LEFT, padx = 5, pady = 0)

#-----------------------------------------------------------------------------------------------------------------------------
# Frame for PMOD B channels 8 to 15
#-----------------------------------------------------------------------------------------------------------------------------
framePmodBTop   = Frame(framePmodTop, borderwidth=1, padx = 5, pady = 0)
Label (framePmodBTop, text = 'PMOD-B').pack(side = LEFT, padx = 5, pady = 0)

framePmodB = Frame(framePmodBTop, borderwidth=1,relief=GROOVE, padx = 2, pady = 2)
for i in range(8,16):   #  8 to 15
    arrFrameCh.append(Frame(framePmodB, borderwidth=1, padx = 2, pady = 1))
    Label (arrFrameCh[i], text = ('ch'+ str(i))).pack(side = LEFT, padx = 2, pady = 1)
    Entry (arrFrameCh[i], width = 8, textvariable = listVdc[i]).pack(side=LEFT, padx = 2, pady = 1)
    Label (arrFrameCh[i], text = 'V').pack(side = LEFT, padx = 1, pady = 1)
    ButtonSetCh = Button(arrFrameCh[i], width = 5, text = ('Set ' + str(i)), command = lambda ch=i: set_chan_dc(ser, ch, listVdc[ch].get()), state=DISABLED)
    ButtonSetCh.pack(side=LEFT)
    arrButtonSetCh.append(ButtonSetCh)
    arrFrameCh[i].pack(side=TOP, padx = 2, pady = 1)

framePmodB.pack(side=TOP, padx = 5, pady = 0)
framePmodBTop.pack(side=LEFT, padx = 5, pady = 0)

framePmodTop.pack(side=TOP, padx = 5, pady = 0)


#-----------------------------------------------------------------------------------------------------------------------------
# Read FPGA version
#-----------------------------------------------------------------------------------------------------------------------------
frameVersion   = Frame(root, borderwidth=3,relief=FLAT, padx = 5, pady = 2)
Label (frameVersion, text = 'Version ').pack(side = LEFT, padx = 5, pady = 2)
Entry (frameVersion, width = 12, textvariable = strVersion).pack(side=LEFT, padx = 5, pady = 2)
buttonVerRead  = Button (frameVersion, width = 10, text = "Read",  command = lambda: read_version(ser), state=DISABLED)
buttonVerRead.pack(side=LEFT)
frameVersion.pack(side=TOP, padx = 5, pady = 2)


#buttonWriteGPO  = Button (root, width = 10, text = "Write GPO",   command = lambda: gj_reg_write_int(ser, adrRegGpo, dataGpo))
#buttonWriteGPO.pack(side=BOTTOM, padx = 5, pady = 5)

#buttonReadGPO   = Button (root, width = 10, text = "Read GPO",    command = lambda: gj_reg_read_int(ser, adrRegGpo))
#buttonReadGPO.pack(side=BOTTOM, padx = 5, pady = 5)

#frameQuitHelp   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)

frameQuitHelp   = Frame(root, borderwidth=3,relief=FLAT, padx = 5, pady = 5)
#buttonHelp      = Button (frameQuitHelp, width = 10, text = "Help",        command = lambda: gj_send(ser, b'\x68')).pack(side=LEFT, padx = 5, pady = 5)
buttonQuit      = Button (frameQuitHelp, width = 10, text = "Quit",        command = root.quit).pack(side=RIGHT, padx = 5, pady = 5)
frameQuitHelp.pack(side=BOTTOM, padx = 5, pady = 5)

#-----------------------------------------------------------------------------------------------------------------------------
# Enable buttons if a COM port is present
#-----------------------------------------------------------------------------------------------------------------------------
if len(comlist) != 0:

    buttonSetAllDC.config(state=NORMAL)
    buttonVerRead.config(state=NORMAL)
    for i in range(NUM_CHAN_DC):  
        arrButtonSetCh[i].config(state=NORMAL)

mainloop()

