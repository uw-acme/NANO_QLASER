import serial
import serial.tools.list_ports
import binascii
from tkinter import *
#import tkinter as tk
from time import gmtime, strftime

strNow = strftime("%Y-%m-%d %H:%M:%S", gmtime())

#print strNow


root = Tk()

w = Label(root, text=strNow)
#w = Label(root, text="Hello Tkinter!")
w.pack()

buttonDone     = Button(root, text = "Done", width = 6, command=root.destroy)
buttonDone.pack()

root.mainloop()
