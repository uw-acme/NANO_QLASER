#!/usr/bin/python3
#-------------------------------------------------------------------
#
# Python program using Tk GUI features to test clicking boxes on
# a canvas to set hit map values
#
#-------------------------------------------------------------------
from tkinter import *

root = Tk()
root.title('RD53B HitMap')

# Limits for 'Time over Threshold' values
MAXTOT      = 15
MINTOT      = 1

NUM_HM_ROW  = 384
NUM_HM_COL  = 400
nMaxRow     = NUM_HM_ROW-1
nMaxCol     = NUM_HM_COL-1

nCellSizeX  = 20
nCellSizeY  = 20

# Each hitmap is 2x8 cells. Make theCanvas NUM_CV_HITMAPS_Y hitmaps high and NUM_CV_HITMAPS_X hitmaps across  (CV = Canvas, the name for a Tk drawing area)
NUM_CV_HITMAPS_X    = 3
NUM_CV_HITMAPS_Y    = 5

# A cell is a single ToT value.  A hitmap is 8 columns and 2 rows
nCellsX     = NUM_CV_HITMAPS_X * 8
nCellsY     = NUM_CV_HITMAPS_Y * 2
nHitBorder  = 50
nTopRow     = 0     # Initial col and row of canvas top left
nLeftCol    = 0

# Geometry size of Canvas
nCanvasSizeX    = nCellSizeX * nCellsX + (2*nHitBorder)
nCanvasSizeY    = nCellSizeY * nCellsY + (2*nHitBorder)

# Set the CellId and ToT arrays to all zero 
arrHitCellId    = [[0]*nCellsY for i in range(nCellsX)] 
arrHitTot       = [[0]*nCellsY for i in range(nCellsX)] 
arrTextRow      = [0 for i in range(NUM_CV_HITMAPS_Y)] 
arrTextCol      = [0 for i in range(NUM_CV_HITMAPS_X)] 
arrTextRowId    = [0 for i in range(NUM_CV_HITMAPS_Y)]
arrTextColId    = [0 for i in range(NUM_CV_HITMAPS_X)]

#-------------------------------------------------------------------
def OnCanvasB1MouseMove(event):                  
    print ('b1 mouse move', event.x, event.y, event.widget)
    nRow    = int((event.y - nHitBorder)/nCellSizeY)
    nCol    = int((event.x - nHitBorder)/nCellSizeX)
    nLeftCol= int(strCol.get())
    nTopRow = int(strRow.get())
    nMapY   = int(nRow/2)
    nMapX   = int(nCol/8)
    nHitY   = nRow - 2*nMapY
    nHitX   = nCol - 8*nMapX
    
    # Get the ToT value and limit it to 1 to MAX
    nTimeOverThr = int(strToT.get())
    if nTimeOverThr > MAXTOT :
        nTimeOverThr = MAXTOT
        
    elif nTimeOverThr < MINTOT :
        nTimeOverThr = MINTOT
    
    
    print   ('Col , Row ', nCol, nRow)
    print   ('nLeftCol , nTopRow ', nLeftCol, nTopRow)
    print   ('Qcell X,Y ', nMapX + nLeftCol, nMapY + nTopRow)
    print   ('Bit       ', nHitX + 8*nHitY)
    

#-------------------------------------------------------------------
# This function is called whenever a mouse click occurs on the
# Canvas. The color of the hitmap cell that is under the mouse is
# toggled between cyan and grey. The array storing the ToT value for
# each cell is also toggled between 0 and the value in the Current ToT
# entry box
#-------------------------------------------------------------------
def onCanvasClick(event):                  
    print ('Got canvas click', event.x, event.y, event.widget)
    
    # Check that click is within the cell area
    if (event.x > nHitBorder) and (event.y > nHitBorder) and (event.x < (nCanvasSizeX - nHitBorder)) and (event.y < nCanvasSizeY - nHitBorder) : 
        nRow    = int((event.y - nHitBorder)/nCellSizeY)
        nCol    = int((event.x - nHitBorder)/nCellSizeX)
        nLeftCol= int(strCol.get())
        nTopRow = int(strRow.get())
        nMapY   = int(nRow/2)
        nMapX   = int(nCol/8)
        nHitY   = nRow - 2*nMapY
        nHitX   = nCol - 8*nMapX
        
        # Get the ToT value and limit it to 1 to MAX
        nTimeOverThr = int(strToT.get())
        if nTimeOverThr > MAXTOT :
            nTimeOverThr = MAXTOT
            
        elif nTimeOverThr < MINTOT :
            nTimeOverThr = MINTOT
        
        
        print   ('Col , Row ', nCol, nRow)
        print   ('nLeftCol , nTopRow ', nLeftCol, nTopRow)
        print   ('Qcell X,Y ', nMapX + nLeftCol, nMapY + nTopRow)
        print   ('Bit       ', nHitX + 8*nHitY)
        
        # Toggle the Canvas hitmap colors and store the ToT (Time over Threshold) of each hitmap cell
        if arrHitTot[nCol][nRow] == 0:
            arrHitTot[nCol][nRow] = int(strToT.get())                   # Value from dialog box
            canvas1.itemconfig(arrHitCellId[nCol][nRow], fill="cyan")   # Change color to cyan
        else:
            arrHitTot[nCol][nRow] = 0
            canvas1.itemconfig(arrHitCellId[nCol][nRow], fill="#ddd") # change color to grey
    else :
         print   ('Out of array')
       
    
#-------------------------------------------------------------------
# Increment or decrement the row position of the visible hitmap
# array in the overall array
#-------------------------------------------------------------------
def onSpinboxScrollRow():                  
    print ('Got spinbox row click')
    nTopRow     = int(strRow.get())
    print   ('Row ', nTopRow)
    
    # Update the Canvas labels
    for i in range(0, NUM_CV_HITMAPS_Y , 1):
        arrTextRow[i] = nTopRow + i
        canvas1.itemconfig(arrTextRowId[i], text=arrTextRow[i])
    
    
#-------------------------------------------------------------------
# Increment or decrement the column position of the visible hitmap
# array in the overall array
#-------------------------------------------------------------------
def onSpinboxScrollCol():                  
    print ('Got spinbox col click')
    nLeftCol     = int(strCol.get())
    print   ('Col ', nLeftCol)
    
    # Update the Canvas labels
    for i in range(0, NUM_CV_HITMAPS_X , 1):
        arrTextCol[i] = nLeftCol + i
        canvas1.itemconfig(arrTextColId[i], text=arrTextCol[i])


 
#-------------------------------------------------------------------
# Check the Hits in each of the visible array of qcells. (NUM_CV_HITMAPS_X * NUM_CV_HITMAPS_Y)
# Order is columns from left to right. Within columns, rows from top to bottom
# If a qcell has any hits then output its Row, Column and 16-bit hitmap and ToT list.
#-------------------------------------------------------------------
def onButtonGenerate(event):                  
    print ('Generate')
    nLeftCol= int(strCol.get())
    nTopRow = int(strRow.get())
    
    nMapY   = int(nRow/2)
    nMapX   = int(nCol/8)
    nHitY   = nRow - 2*nMapY
    nHitX   = nCol - 8*nMapX
    print   ('Col , Row ', nCol, nRow)
    print   ('nLeftCol , nTopRow ', nLeftCol, nTopRow)
    print   ('Qcell X,Y ', nMapX + nLeftCol, nMapY + nTopRow)
    print   ('Bit       ', nHitX + 8*nHitY)
    
    # Update the Canvas hitmap colors and store the ToT of each hitmap cell
    if arrHitTot[nCol][nRow] == 0:
        arrHitTot[nCol][nRow] = int(strToT.get())
        canvas1.itemconfig(arrHitCellId[nCol][nRow], fill="cyan") # change color
    else:
        arrHitTot[nCol][nRow] = 0
        canvas1.itemconfig(arrHitCellId[nCol][nRow], fill="#ddd") # change color to grey
    
    
#-------------------------------------------------------------------
# Function to open a file to store hit data.
# Write any necessary header information
#-------------------------------------------------------------------
def onFileName1Init():
    print   ('onFileName1Init')
    
#-------------------------------------------------------------------
# Function to write hitndata into the file.
#-------------------------------------------------------------------
def onFileName1AddTo():
    print   ('onFileName1AddTo')
    
# End of function definitions


#-----------------------------------------------------------------------------------------------------------------------------
# GUI Creation Section
#-----------------------------------------------------------------------------------------------------------------------------

#-----------------------------------------------------------------------------------------------------------------------------
# Create the canvas
#-----------------------------------------------------------------------------------------------------------------------------
canvas1 = Canvas(root, width=nCanvasSizeX, height=nCanvasSizeY)
canvas1.pack()

#-----------------------------------------------------------------------------------------------------------------------------
# Frame to hold qrow and qcolumn and ToT
#-----------------------------------------------------------------------------------------------------------------------------
strRow              = StringVar()
strCol              = StringVar()
strToT              = StringVar()
strRow.set(0)
strCol.set(0)
strToT.set(5)

frameRowCol   = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)
Label (frameRowCol, text = 'Row').pack(side = LEFT, padx = 5, pady = 5)
entryRow = Spinbox (frameRowCol, width = 10, from_ = 0, to = nMaxRow-4, textvariable = strRow, command = onSpinboxScrollRow).pack(side=LEFT, padx = 5, pady = 5)
Label (frameRowCol, text = 'Col').pack(side = LEFT, padx = 5, pady = 5)
entryCol = Spinbox (frameRowCol, width = 10, from_ = 0, to = nMaxCol-2, textvariable = strCol, command = onSpinboxScrollCol).pack(side=LEFT, padx = 5, pady = 5)
Label (frameRowCol, text = 'ToT').pack(side = LEFT, padx = 5, pady = 5)

# Spinbox to set ToT 'Time over Threshold' value
Spinbox (frameRowCol, width = 5, from_ = MINTOT, to = MAXTOT, textvariable = strToT).pack(side=LEFT, padx = 5, pady = 5)
frameRowCol.pack(side=TOP, padx = 5, pady = 5)

#-----------------------------------------------------------------------------------------------------------------------------
# Frame to hold filenames
#-----------------------------------------------------------------------------------------------------------------------------
strFileName1        = StringVar()
strFileName1.set("hitdata.txt")

frameFileNames      = Frame(root, borderwidth=3,relief=GROOVE, padx = 5, pady = 5)
Label (frameFileNames, text = 'FileName1').pack(side = LEFT, padx = 5, pady = 5)
entryFileName1      = Entry (frameFileNames, width = 15, textvariable = strFileName1).pack(side=LEFT, padx = 5, pady = 5)
buttonFile1Init     = Button(frameFileNames, text = "Init", width = 6, command=onFileName1Init).pack()
buttonFile1AddTo    = Button(frameFileNames, text = "Add",  width = 6, command=onFileName1AddTo).pack()
# Pack the frame
frameFileNames.pack(side=TOP, padx = 5, pady = 5)


#-----------------------------------------------------------------------------------------------------------------------------
# Draw the canvas
#-----------------------------------------------------------------------------------------------------------------------------
# Init the strings for Row and Column text labels
nTopRow     = int(strRow.get())
for i in range(0, NUM_CV_HITMAPS_Y , 1):
    arrTextRow[i] = nTopRow + i
    
nLeftCol    = int(strCol.get())
for i in range(0, NUM_CV_HITMAPS_X , 1):
    arrTextCol[i] = nLeftCol + i

#-------------------------------------------------------------------
# Create an array of 3 x 5 hitmaps. Each hitmap is 8x by 2y 
#-------------------------------------------------------------------
for x in range(0, nCellsX, 1):     # Columns
    for y in range(0, nCellsY, 1): # Rows
        nXpos = nHitBorder + (nCellSizeX * x)
        nYpos = nHitBorder + (nCellSizeY * y)
        
        arrHitCellId[x][y] = canvas1.create_rectangle(nXpos, nYpos, nXpos + nCellSizeX, nYpos + nCellSizeY, fill='#ddd')
        
print (arrHitCellId)

canvas1.bind("<B1-Motion>", OnCanvasB1MouseMove)
        
# Draw Horizontal lines to separate Qcell hitmaps
nLinePitchY = 2*nCellSizeY
for i in range(0, NUM_CV_HITMAPS_Y +1, 1):
    canvas1.create_line(0, nHitBorder+i*nLinePitchY, nCanvasSizeX, nHitBorder+i*nLinePitchY, fill="green", width=2)
    
# Vertical lines to separate Qcell hitmaps
nLinePitchX = 8*nCellSizeX
for i in range(0, NUM_CV_HITMAPS_X +1, 1):
    canvas1.create_line(nHitBorder+i*nLinePitchX, 0, nHitBorder+i*nLinePitchX, nCanvasSizeY, fill="red", width=2)

# label the rows
for i in range(0, NUM_CV_HITMAPS_Y , 1):
    arrTextRowId[i] = canvas1.create_text(20, nHitBorder+i*nLinePitchY + nLinePitchY/2, text=arrTextRow[i])

# label the cols
for i in range(0, NUM_CV_HITMAPS_X , 1):
    arrTextColId[i] = canvas1.create_text(nHitBorder+nLinePitchX/2+i*nLinePitchX, nHitBorder/2, text=arrTextCol[i])

# Set the function to call when a mouse click occurs in the Canvas
canvas1.bind('<Button-1>', onCanvasClick)                  

#-----------------------------------------------------------------------------------------------------------------------------
# Start the event loop and run forever
#-----------------------------------------------------------------------------------------------------------------------------
mainloop()
