import serial
import serial.tools.list_ports
import binascii

from tkinter import *
from tkinter import ttk
#import tkinter as tk
from tkinter.scrolledtext import ScrolledText



root = Tk()
root.title("test_notebook")

note1 = ttk.Notebook(root)

# adding Frames as pages for the ttk.Notebook 
# first page, which would get widgets gridded into it
page1 = ttk.Frame(note1)

# second page
page2 = ttk.Frame(note1)
text = ScrolledText(page2)
text.pack(expand=1, fill="both")

note1.add(page1, text='One')
note1.add(page2, text='Two')

note1.pack(expand=1, fill="both")

#w = Label(note1, text="Hello Tkinter!")
#w.pack()

buttonDone1     = Button(page1, text = "Done1", width = 6, command=root.destroy)
buttonDone1.pack()

buttonDone2     = Button(page2, text = "Done2", width = 10, command=root.destroy)
buttonDone2.pack()

root.mainloop()
