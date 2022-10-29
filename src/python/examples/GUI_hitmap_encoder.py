#!/usr/bin/python3
#-------------------------------------------------------------------
#
# Python program using Tk GUI features to display
# hit map values and compressed output
#
#-------------------------------------------------------------------
from tkinter import *
#from tkinter.font import Font
import tkinter.font as tkFont

root = Tk()
root.title('RD53B HitMap Encoder v1.1')

# Limits for 'Time over Threshold' values
TOT_MAX     = 15
TOT_MIN     = 1
TOT_OFF     = 0

NUM_HM_ROW  = 384
NUM_HM_COL  = 400
nMaxRow     = NUM_HM_ROW-1
nMaxCol     = NUM_HM_COL-1

nCellSizeX  = 20  # Dimensions of hitmap square
nCellSizeY  = 20
nNodeSizeX  = 40  # Dimensions of Node box
nNodeSizeY  = 40

# Each hitmap is 2x8 cells. Make theCanvas NUM_CV_HITMAPS_Y hitmaps high and NUM_CV_HITMAPS_X hitmaps across  (CV = Canvas, the name for a Tk drawing area)
NUM_CV_HITMAPS_X    = 1
NUM_CV_HITMAPS_Y    = 1

# A cell is a single ToT value.  A hitmap is 8 columns and 2 rows
nCellsX     = NUM_CV_HITMAPS_X * 8
nCellsY     = NUM_CV_HITMAPS_Y * 2

# Top-left (x,y) co-ordinate of each level of hitmap expansion
nHitMapOrigin1x  = 200
nHitMapOrigin1y  =  80

nHitMapOrigin2x  = 200
nHitMapOrigin2y  = 200

nHitMapOrigin3x  = 180
nHitMapOrigin3y  = 380

nHitMapOrigin4x  = 160
nHitMapOrigin4y  = 520

nTopRow     = 0     # Initial col and row of canvas top left
nLeftCol    = 0

# Geometry size of Canvas
nCanvasSizeX    = 1100  # 
nCanvasSizeY    = 780   # 

# Set the CellId and ToT arrays to all zero 
arrHitCellId1   = [[0]*nCellsY for i in range(nCellsX)] 
arrHitCellId2   = [[0]*nCellsY for i in range(nCellsX)] 
arrHitCellId3   = [[0]*nCellsY for i in range(nCellsX)] 
arrHitCellId4   = [[0]*nCellsY for i in range(nCellsX)]
arrNodeId       = [[0]*8 for i in range(4)]
arrNodeText     = [[0]*8 for i in range(4)]
arrLineId       = [[0]*8 for i in range(4)] # 4 levels with up to 8 lines per level
fontNodeOn      = tkFont.Font(family="Times New Roman", size=12, weight = "bold")
fontNodeOff     = tkFont.Font(family="Times New Roman", size=10, weight = "normal")
fontHitResult   = tkFont.Font(family="System", size=12, weight = "bold")


arrHitTot       = [[0]*nCellsY for i in range(nCellsX)] 
arrTextHitValue = [[0]*16 for i in range(4)]

arrTextHitBits  = [[0]*8 for i in range(4)]
arrTextHitBits2 = [[0]*8 for i in range(4)]


listNodeNames = ["A", "B", "C", "D", "E", "F","G","H","I","J","K","L","M","N","O"]



#-------------------------------------------------------------------
# This function is called whenever a mouse click occurs on the
# Canvas. The color of the hitmap cell that is under the mouse is
# toggled between cyan and lightgrey. The array storing the ToT value for
# each cell is also toggled between 0 and the value in the Current ToT
# entry box
#-------------------------------------------------------------------
def OnCanvasClick(event):                  

    #print ('Got canvas click', event.x, event.y, event.widget)
    
    # Check that click is within the cell area
    if (event.x > nHitMapOrigin1x) and (event.y > nHitMapOrigin1y) and (event.x < (nHitMapOrigin1x + 8*nCellSizeX)) and (event.y < nHitMapOrigin1y + 8*nCellSizeX) : 
        nRow    = int((event.y - nHitMapOrigin1y)/nCellSizeY)
        nCol    = int((event.x - nHitMapOrigin1x)/nCellSizeX)
        nLeftCol= int(strCol.get())
        nTopRow = int(strRow.get())
        nMapY   = int(nRow/2)
        nMapX   = int(nCol/8)
        nHitY   = nRow - 2*nMapY
        nHitX   = nCol - 8*nMapX
        
        # Get the ToT value and limit it to MIN to MAX
        nTimeOverThr = int(strToT.get())
        if nTimeOverThr > TOT_MAX :
            nTimeOverThr = TOT_MAX
        
        elif nTimeOverThr < TOT_MIN :
            nTimeOverThr = TOT_MIN
        
        
        print   ('Col , Row ', nCol, nRow)
        print   ('nLeftCol , nTopRow ', nLeftCol, nTopRow)
        print   ('Qcell X,Y ', nMapX + nLeftCol, nMapY + nTopRow)
        print   ('Bit       ', nHitX + 8*nHitY)
        
        # Toggle the Canvas hitmap colors and store the ToT (Time over Threshold) of each hitmap cell
        if arrHitTot[nCol][nRow] == 0:
            arrHitTot[nCol][nRow] = int(strToT.get())                    # Value from dialog box
            canvas1.itemconfig(arrHitCellId1[nCol][nRow], fill="cyan")   # Change color to cyan
            canvas1.itemconfig(arrHitCellId2[nCol][nRow], fill="cyan")   # 
            canvas1.itemconfig(arrHitCellId3[nCol][nRow], fill="cyan")   # 
            canvas1.itemconfig(arrHitCellId4[nCol][nRow], fill="cyan")   # 
        else:
            arrHitTot[nCol][nRow] = 0
            canvas1.itemconfig(arrHitCellId1[nCol][nRow], fill="lightgrey") # change color to grey
            canvas1.itemconfig(arrHitCellId2[nCol][nRow], fill="lightgrey") # 
            canvas1.itemconfig(arrHitCellId3[nCol][nRow], fill="lightgrey") # 
            canvas1.itemconfig(arrHitCellId4[nCol][nRow], fill="lightgrey") # 
    else :
         print   ('Out of array')
    
    #---------------------------------------------------------------
    # Update the first level top/bottom arrTextHitValue bit values
    #---------------------------------------------------------------
    sum = 0
    for n in range(0, 8):
        sum = sum + arrHitTot[n][0] 

    if (sum > 0) :  # Top
        canvas1.itemconfig(arrTextHitValue[0][0], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[0][0], text="0")

    sum = 0
    for n in range(0, 8): # Bottom
        sum = sum + arrHitTot[n][1] 
    if (sum > 0) :
        canvas1.itemconfig(arrTextHitValue[0][1], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[0][1], text="0")
    
    #---------------------------------------------------------------
    # Update the second level left/right arrTextHitValue bit values
    #---------------------------------------------------------------
    sum = 0
    for n in range(0, 4):
        sum = sum + arrHitTot[n][0] 

    if (sum > 0) :
        canvas1.itemconfig(arrTextHitValue[1][0], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[1][0], text="0")

    sum = 0
    for n in range(4, 8):
        sum = sum + arrHitTot[n][0] 
    if (sum > 0) :
        canvas1.itemconfig(arrTextHitValue[1][1], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[1][1], text="0")
    
    sum = 0
    for n in range(0, 4):
        sum = sum + arrHitTot[n][1] 

    if (sum > 0) :
        canvas1.itemconfig(arrTextHitValue[1][2], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[1][2], text="0")

    sum = 0
    for n in range(4, 8):
        sum = sum + arrHitTot[n][1] 
    if (sum > 0) :
        canvas1.itemconfig(arrTextHitValue[1][3], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[1][3], text="0")
    

    #---------------------------------------------------------------
    # Update the third level left/right arrTextHitValue bit values
    #---------------------------------------------------------------
    if ((arrHitTot[0][0] + arrHitTot[1][0]) > 0) :
        canvas1.itemconfig(arrTextHitValue[2][0], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[2][0], text="0")

    if (arrHitTot[2][0] + arrHitTot[3][0]) > 0 :
        canvas1.itemconfig(arrTextHitValue[2][1], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[2][1], text="0")

    if (arrHitTot[4][0] + arrHitTot[5][0]) > 0 :
        canvas1.itemconfig(arrTextHitValue[2][2], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[2][2], text="0")

    if (arrHitTot[6][0] + arrHitTot[7][0]) > 0 :
        canvas1.itemconfig(arrTextHitValue[2][3], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[2][3], text="0")

 
    if (arrHitTot[0][1] + arrHitTot[1][1]) > 0 :
        canvas1.itemconfig(arrTextHitValue[2][4], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[2][4], text="0")

    if (arrHitTot[2][1] + arrHitTot[3][1]) > 0 :
        canvas1.itemconfig(arrTextHitValue[2][5], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[2][5], text="0")

    if (arrHitTot[4][1] + arrHitTot[5][1]) > 0 :
        canvas1.itemconfig(arrTextHitValue[2][6], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[2][6], text="0")

    if (arrHitTot[6][1] + arrHitTot[7][1]) > 0 :
        canvas1.itemconfig(arrTextHitValue[2][7], text="1")
    else :
        canvas1.itemconfig(arrTextHitValue[2][7], text="0")


    #---------------------------------------------------------------
    # Update the fourth level arrTextHitValue bit values
    #---------------------------------------------------------------
    for n in range(0, 8):
        if arrHitTot[n][0] > 0 :
            canvas1.itemconfig(arrTextHitValue[3][n], text="1")
        else :
            canvas1.itemconfig(arrTextHitValue[3][n], text="0")
 
        if arrHitTot[n][1] > 0 :
            canvas1.itemconfig(arrTextHitValue[3][n+8], text="1")
        else :
            canvas1.itemconfig(arrTextHitValue[3][n+8], text="0")
 
    #---------------------------------------------------------------
    # Update Node output line color
    #---------------------------------------------------------------
    # A to B (Level 0, line 0)
    if canvas1.itemcget(arrTextHitValue[0][0], 'text') == '0' : 
        canvas1.itemconfig(arrLineId[0][0], fill = "lightgrey")
    else :
        canvas1.itemconfig(arrLineId[0][0], fill = "red")

    # A to C (Level 0, line 1)
    if canvas1.itemcget(arrTextHitValue[0][1], 'text') == '0' : 
        canvas1.itemconfig(arrLineId[0][1], fill = "lightgrey")
    else :
        canvas1.itemconfig(arrLineId[0][1], fill = "red")

    # B and C to next level (Level 1 to Level 2)
    for i in range (0, 4):
        if canvas1.itemcget(arrTextHitValue[1][i], 'text') == '0' : 
            canvas1.itemconfig(arrLineId[1][i], fill = "lightgrey")
        else :
            canvas1.itemconfig(arrLineId[1][i], fill = "red")

    # Level 2 to Level 3
    for i in range (0, 8):
        if canvas1.itemcget(arrTextHitValue[2][i], 'text') == '0' : 
            canvas1.itemconfig(arrLineId[2][i], fill = "lightgrey")
        else :
            canvas1.itemconfig(arrLineId[2][i], fill = "red")


    #---------------------------------------------------------------
    # Update 2-bit Node text and node color
    #---------------------------------------------------------------
    # A
    NewText = canvas1.itemcget(arrTextHitValue[0][0], 'text') + canvas1.itemcget(arrTextHitValue[0][1], 'text')
    update_node         (canvas1, arrNodeId[0][0],   NewText)
    update_node_text    (canvas1, arrNodeText[0][0], NewText)
    update_hitmap_text  (canvas1, arrTextHitBits[0][0], arrTextHitBits2[0][0], NewText)

    # B
    NewText = canvas1.itemcget(arrTextHitValue[1][0], 'text') + canvas1.itemcget(arrTextHitValue[1][1], 'text')
    update_node         (canvas1, arrNodeId[1][0],   NewText)
    update_node_text    (canvas1, arrNodeText[1][0], NewText)
    update_hitmap_text  (canvas1, arrTextHitBits[1][0], arrTextHitBits2[1][0], NewText)
    # C
    NewText = canvas1.itemcget(arrTextHitValue[1][2], 'text') + canvas1.itemcget(arrTextHitValue[1][3], 'text')
    update_node         (canvas1, arrNodeId[1][1],   NewText)
    update_node_text    (canvas1, arrNodeText[1][1], NewText)
    update_hitmap_text  (canvas1, arrTextHitBits[1][1], arrTextHitBits2[1][1], NewText)

    # D,E,F,G
    for i in range (0, 4):
        NewText = canvas1.itemcget(arrTextHitValue[2][2*i], 'text') + canvas1.itemcget(arrTextHitValue[2][2*i+1], 'text')
        update_node         (canvas1, arrNodeId[2][i],   NewText)
        update_node_text    (canvas1, arrNodeText[2][i], NewText)
        update_hitmap_text  (canvas1, arrTextHitBits[2][i], arrTextHitBits2[2][i], NewText)

    # H to O
    for i in range (0, 8):
        NewText = canvas1.itemcget(arrTextHitValue[3][2*i], 'text') + canvas1.itemcget(arrTextHitValue[3][2*i+1], 'text')
        update_node         (canvas1, arrNodeId[3][i],   NewText)
        update_node_text    (canvas1, arrNodeText[3][i], NewText)
        update_hitmap_text  (canvas1, arrTextHitBits[3][i], arrTextHitBits2[3][i], NewText)

    #---------------------------------------------------------------
    # Update bit counts of compressed patterns before and after '01'->'0'
    #---------------------------------------------------------------
    canvas1.itemconfig(idNumBits1, text=str(size_bit_text(canvas1, arrTextHitBits ))+" bits")
    canvas1.itemconfig(idNumBits2, text=str(size_bit_text(canvas1, arrTextHitBits2))+" bits")

    # Update final output bits and size
    strBitsFinal  = makeStringFinal(canvas1,arrTextHitBits2)
    canvas1.itemconfig(idFinalBits, text= strBitsFinal, fill="black")
    canvas1.itemconfig(idNumBits3, text=str(len(strBitsFinal))+" bits")


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
        canvas1.itemconfig(arrHitCellId1[nCol][nRow], fill="cyan") # change color
    else:
        arrHitTot[nCol][nRow] = 0
        canvas1.itemconfig(arrHitCellId1[nCol][nRow], fill="grey") # change color to grey
    
    
#-------------------------------------------------------------------
# Function to open a file to store hit data.
# Write any necessary header information
#-------------------------------------------------------------------
def onFileName1Init():
    print   ('onFileName1Init')
    
#-------------------------------------------------------------------
# Function to write hitdata into the file.
#-------------------------------------------------------------------
def onFileName1AddTo():
    print   ('onFileName1AddTo')
    

#-------------------------------------------------------------------
# Draw a circle used to identify nodes
#-------------------------------------------------------------------
def circle(canvas,x,y, r):
   id = canvas.create_oval(x-r,y-r,x+r,y+r)
   return id

#-------------------------------------------------------------------
# Use the text in a node to decide if 'on' or 'off' and change its 
# appearance.
#-------------------------------------------------------------------
def update_node(canvas, node, text):

    if text == "00" :
        canvas.itemconfig(node,   fill    = "lightgrey")
        canvas.itemconfig(node,   outline = "grey")
        canvas.itemconfig(node,   width   = 1)
    else :
        canvas.itemconfig(node,   fill    = "red")
        canvas.itemconfig(node,   outline = "black")
        canvas.itemconfig(node,   width   = 3)

#-------------------------------------------------------------------
# Use the text in a node to set its appearance.
# i.e. size, and if bold or normal
#-------------------------------------------------------------------
def update_node_text(canvas, nodetext, textnew):

    canvas.itemconfig(nodetext, text = textnew)

    if textnew == "00" :
        canvas.itemconfig(nodetext, font = fontNodeOff)
    else :
        canvas.itemconfig(nodetext, font = fontNodeOn)


#-------------------------------------------------------------------
# Use the text string to set the first compressed hitmap text color to 
# grey,normal if "00", else black,bold.
# For second string, convert any '01' to '0' and make the color red 
#-------------------------------------------------------------------
def update_hitmap_text (canvas, idText1, idText2, textnew):

    canvas.itemconfig(idText1, text = textnew)

    if textnew == "00" :
        canvas.itemconfig(idText1, fill = "lightgrey")
    else :
        canvas.itemconfig(idText1, fill = "black")

    if textnew == "00" :
        canvas.itemconfig(idText2, fill = "lightgrey")
        canvas.itemconfig(idText2, text = textnew)
    elif textnew == "01" :
        canvas.itemconfig(idText2, fill = "red")
        canvas.itemconfig(idText2, text = "0")
    else :
        canvas.itemconfig(idText2, fill = "black")
        canvas.itemconfig(idText2, text = textnew)


#-------------------------------------------------------------------
# Return length of bit string
#-------------------------------------------------------------------
def size_bit_text(canvas, IdText):

    nbits = 0

    for row in range (0, 4):
        for col in range(0, 8):
            str = canvas1.itemcget(IdText[row][col],'text')

            if str == "0" :
                nbits = nbits + 1
            elif str == "01" :
                nbits = nbits + 2
            elif str == "10" :
                nbits = nbits + 2
            elif str == "11" :
                nbits = nbits + 2

    return nbits


#-------------------------------------------------------------------
# Return final bit string
#-------------------------------------------------------------------
def makeStringFinal(canvas, IdText):

    stringFinal = ""

    if (canvas.itemcget(IdText[0][0], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[0][0],'text')
    if (canvas.itemcget(IdText[1][0], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[1][0],'text')
    if (canvas.itemcget(IdText[2][0], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[2][0],'text')
    if (canvas.itemcget(IdText[2][1], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[2][1],'text')
    if (canvas.itemcget(IdText[3][0], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[3][0],'text')
    if (canvas.itemcget(IdText[3][1], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[3][1],'text')
    if (canvas.itemcget(IdText[3][2], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[3][2],'text')
    if (canvas.itemcget(IdText[3][3], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[3][3],'text')
    if (canvas.itemcget(IdText[1][1], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[1][1],'text')
    if (canvas.itemcget(IdText[2][2], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[2][2],'text')
    if (canvas.itemcget(IdText[2][3], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[2][3],'text')
    if (canvas.itemcget(IdText[3][4], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[3][4],'text')
    if (canvas.itemcget(IdText[3][5], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[3][5],'text')
    if (canvas.itemcget(IdText[3][6], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[3][6],'text')
    if (canvas.itemcget(IdText[3][7], 'text') != "00") :
         stringFinal = stringFinal + canvas1.itemcget(IdText[3][7],'text')

    return stringFinal


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


#-----------------------------------------------------------------------------------------------------------------------------
# Draw the canvas
#-----------------------------------------------------------------------------------------------------------------------------

#-------------------------------------------------------------------
# Create first stage hitmap. Hitmap is 8x by 2y 
#-------------------------------------------------------------------
canvas1.create_text(160, 60, anchor=SW, font=fontHitResult, text="Click on hitmap box to toggle state") 
for x in range(0, nCellsX, 1):     # Columns
    for y in range(0, nCellsY, 1): # Rows
        nXpos = nHitMapOrigin1x + (nCellSizeX * x)
        nYpos = nHitMapOrigin1y + (nCellSizeY * y)

        arrHitCellId1[x][y] = canvas1.create_rectangle(nXpos, nYpos, nXpos + nCellSizeX, nYpos + nCellSizeY, fill='lightgrey')

# Dashed line to split top/bottom
canvas1.create_line(nHitMapOrigin1x-20, nHitMapOrigin1y+20, nHitMapOrigin1x+8*nCellSizeX+20 , nHitMapOrigin1y+20, fill="black", width=1, dash=(3,3))

# Circular label to refer to the node 
nXpos = nHitMapOrigin1x - 50 ; nYpos = nHitMapOrigin1y + 20    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[0])

# Init the strings for hitmap top/bottom and left/right results
arrTextHitValue[0][0] = canvas1.create_text(nHitMapOrigin1x-10, nHitMapOrigin1y+10,text='0')    # upper bit sum
arrTextHitValue[0][1] = canvas1.create_text(nHitMapOrigin1x-10, nHitMapOrigin1y+30,text='0')    # lower bit sum
        
#-------------------------------------------------------------------
# Create second stage hitmap. Two rows of 8 
#-------------------------------------------------------------------
for x in range(0, nCellsX, 1):     # Columns
    for y in range(0, nCellsY, 1): # Rows
        nXpos = nHitMapOrigin2x + (nCellSizeX * x)
        nYpos = nHitMapOrigin2y + (nCellSizeY * y) + 20*y
        
        arrHitCellId2[x][y] = canvas1.create_rectangle(nXpos, nYpos, nXpos + nCellSizeX, nYpos + nCellSizeY, fill='lightgrey')

# Dashed line to split left/right
canvas1.create_line(nHitMapOrigin2x+4*nCellSizeX, nHitMapOrigin2y-20, nHitMapOrigin2x+4*nCellSizeX , nHitMapOrigin2y+80, fill="black", width=1, dash=(3,3))

# Circular labels to refer to the nodes 
nXpos = nHitMapOrigin2x - 30 ; nYpos = nHitMapOrigin2y + 10    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[1])
nXpos = nHitMapOrigin2x - 30 ; nYpos = nHitMapOrigin2y + 50    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[2])

# Init the strings for hitmap top/bottom and left/right results
arrTextHitValue[1][0] = canvas1.create_text(nHitMapOrigin2x+40 , nHitMapOrigin2y-10,text='0')    # upper left
arrTextHitValue[1][1] = canvas1.create_text(nHitMapOrigin2x+120, nHitMapOrigin2y-10,text='0')    # upper right
arrTextHitValue[1][2] = canvas1.create_text(nHitMapOrigin2x+40 , nHitMapOrigin2y+70,text='0')    # lower left
arrTextHitValue[1][3] = canvas1.create_text(nHitMapOrigin2x+120, nHitMapOrigin2y+70,text='0')    # lower right

#-------------------------------------------------------------------
# Create third stage hitmap. Two rows of 2 groups of 4 
#-------------------------------------------------------------------
for x in range(0, nCellsX, 1):     # Columns
    for y in range(0, nCellsY, 1): # Rows
        nXpos = nHitMapOrigin3x + (nCellSizeX * x) + 40*(int(x/4))
        nYpos = nHitMapOrigin3y + (nCellSizeY * y) + 40*y
        
        arrHitCellId3[x][y] = canvas1.create_rectangle(nXpos, nYpos, nXpos + nCellSizeX, nYpos + nCellSizeY, fill='lightgrey')
        
# Dashed lines to split left/right
canvas1.create_line(nHitMapOrigin3x+2*nCellSizeX, nHitMapOrigin3y-20, nHitMapOrigin3x+2*nCellSizeX , nHitMapOrigin3y+100, fill="black", width=1, dash=(3,3))
canvas1.create_line(nHitMapOrigin3x+8*nCellSizeX, nHitMapOrigin3y-20, nHitMapOrigin3x+8*nCellSizeX , nHitMapOrigin3y+100, fill="black", width=1, dash=(3,3))

# Circular labels to refer to the nodes 
nXpos = nHitMapOrigin3x - 10    ; nYpos = nHitMapOrigin3y - 10
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[3])
nXpos = nHitMapOrigin3x + 110   ; nYpos = nHitMapOrigin3y - 10
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[4])
nXpos = nHitMapOrigin3x - 10    ; nYpos = nHitMapOrigin3y + 50
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[5])
nXpos = nHitMapOrigin3x + 110   ; nYpos = nHitMapOrigin3y + 50
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[6])

# Init the strings for hitmap left/right results
arrTextHitValue[2][0] = canvas1.create_text(nHitMapOrigin3x+20 , nHitMapOrigin3y-10,text='0')    # upper, left-to-right
arrTextHitValue[2][1] = canvas1.create_text(nHitMapOrigin3x+60 , nHitMapOrigin3y-10,text='0')    #
arrTextHitValue[2][2] = canvas1.create_text(nHitMapOrigin3x+140, nHitMapOrigin3y-10,text='0')    #
arrTextHitValue[2][3] = canvas1.create_text(nHitMapOrigin3x+180, nHitMapOrigin3y-10,text='0')    #
arrTextHitValue[2][4] = canvas1.create_text(nHitMapOrigin3x+20 , nHitMapOrigin3y+50,text='0')    # lower, left-to-right
arrTextHitValue[2][5] = canvas1.create_text(nHitMapOrigin3x+60 , nHitMapOrigin3y+50,text='0')    #
arrTextHitValue[2][6] = canvas1.create_text(nHitMapOrigin3x+140, nHitMapOrigin3y+50,text='0')    #
arrTextHitValue[2][7] = canvas1.create_text(nHitMapOrigin3x+180, nHitMapOrigin3y+50,text='0')    #

#-------------------------------------------------------------------
# Create fourth stage hitmap. Two rows of 4 groups of two 
#-------------------------------------------------------------------
for x in range(0, nCellsX, 1):     # Columns
    for y in range(0, nCellsY, 1): # Rows
        nXpos = nHitMapOrigin4x + (nCellSizeX * x) + 20*(int(x/4)) + 20*(int(x/2))
        nYpos = nHitMapOrigin4y + (nCellSizeY * y) + 40*y

        arrHitCellId4[x][y] = canvas1.create_rectangle(nXpos, nYpos, nXpos + nCellSizeX, nYpos + nCellSizeY, fill='lightgrey')

# Circular labels to refer to the nodes 
nXpos = nHitMapOrigin4x + 20    ; nYpos = nHitMapOrigin4y - 30    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[7])
nXpos = nHitMapOrigin4x + 80    ; nYpos = nHitMapOrigin4y - 30    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[8])
nXpos = nHitMapOrigin4x + 160   ; nYpos = nHitMapOrigin4y - 30    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[9])
nXpos = nHitMapOrigin4x + 220   ; nYpos = nHitMapOrigin4y - 30    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[10])
nXpos = nHitMapOrigin4x + 20    ; nYpos = nHitMapOrigin4y + 100    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[11])
nXpos = nHitMapOrigin4x + 80    ; nYpos = nHitMapOrigin4y + 100    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[12])
nXpos = nHitMapOrigin4x + 160   ; nYpos = nHitMapOrigin4y + 100    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[13])
nXpos = nHitMapOrigin4x + 220   ; nYpos = nHitMapOrigin4y + 100    
circle(canvas1,nXpos,nYpos, 10) ; canvas1.create_text(nXpos, nYpos,text=listNodeNames[14])
        
# Init the strings for hitmap left/right results
arrTextHitValue[3][0]  = canvas1.create_text(nHitMapOrigin4x+10  , nHitMapOrigin4y-10,text='0')    # upper, left-to-right
arrTextHitValue[3][1]  = canvas1.create_text(nHitMapOrigin4x+30  , nHitMapOrigin4y-10,text='0')
arrTextHitValue[3][2]  = canvas1.create_text(nHitMapOrigin4x+70  , nHitMapOrigin4y-10,text='0')
arrTextHitValue[3][3]  = canvas1.create_text(nHitMapOrigin4x+90  , nHitMapOrigin4y-10,text='0')
arrTextHitValue[3][4]  = canvas1.create_text(nHitMapOrigin4x+150 , nHitMapOrigin4y-10,text='0')
arrTextHitValue[3][5]  = canvas1.create_text(nHitMapOrigin4x+170 , nHitMapOrigin4y-10,text='0')
arrTextHitValue[3][6]  = canvas1.create_text(nHitMapOrigin4x+210 , nHitMapOrigin4y-10,text='0')
arrTextHitValue[3][7]  = canvas1.create_text(nHitMapOrigin4x+230 , nHitMapOrigin4y-10,text='0')

arrTextHitValue[3][8]  = canvas1.create_text(nHitMapOrigin4x+10  , nHitMapOrigin4y+50,text='0')    # lower, left-to-right
arrTextHitValue[3][9]  = canvas1.create_text(nHitMapOrigin4x+30  , nHitMapOrigin4y+50,text='0')
arrTextHitValue[3][10] = canvas1.create_text(nHitMapOrigin4x+70  , nHitMapOrigin4y+50,text='0')
arrTextHitValue[3][11] = canvas1.create_text(nHitMapOrigin4x+90  , nHitMapOrigin4y+50,text='0')
arrTextHitValue[3][12] = canvas1.create_text(nHitMapOrigin4x+150 , nHitMapOrigin4y+50,text='0')
arrTextHitValue[3][13] = canvas1.create_text(nHitMapOrigin4x+170 , nHitMapOrigin4y+50,text='0')
arrTextHitValue[3][14] = canvas1.create_text(nHitMapOrigin4x+210 , nHitMapOrigin4y+50,text='0')
arrTextHitValue[3][15] = canvas1.create_text(nHitMapOrigin4x+230 , nHitMapOrigin4y+50,text='0')

#-------------------------------------------------------------------
# Create first node (A)
#-------------------------------------------------------------------
nXpos = 740;    nYpos = 80
arrNodeId[0][0]     = canvas1.create_rectangle(nXpos, nYpos, nXpos + nNodeSizeX, nYpos + nNodeSizeY, fill='lightgrey', outline='black')
arrNodeText[0][0]   = canvas1.create_text(nXpos+nNodeSizeX/2, nYpos+nNodeSizeY/2 ,text="00", font=fontNodeOff)
circle(canvas1,nXpos-nNodeSizeX/2,nYpos + nNodeSizeY/2, 10) ; canvas1.create_text(nXpos-nNodeSizeX/2, nYpos + nNodeSizeY/2,text=listNodeNames[0])

#-------------------------------------------------------------------
# Create two second level nodes (B and C)
#-------------------------------------------------------------------
nXpos = 580;    nYpos = 220;
arrNodeId[1][0]     = canvas1.create_rectangle(nXpos, nYpos, nXpos + nNodeSizeX, nYpos + nNodeSizeY, fill='lightgrey')
arrNodeText[1][0]   = canvas1.create_text(nXpos+nNodeSizeX/2, nYpos+nNodeSizeY/2 ,text="00", font=fontNodeOff)
circle(canvas1,nXpos-nNodeSizeX/2,nYpos + nNodeSizeY/2, 10) ; canvas1.create_text(nXpos-nNodeSizeX/2, nYpos + nNodeSizeY/2,text=listNodeNames[1])

nXpos = 900;    nYpos = 220;
arrNodeId[1][1]     = canvas1.create_rectangle(nXpos, nYpos, nXpos + nNodeSizeX, nYpos + nNodeSizeY, fill='lightgrey')
arrNodeText[1][1]   = canvas1.create_text(nXpos+nNodeSizeX/2, nYpos+nNodeSizeY/2 ,text="00", font=fontNodeOff)
circle(canvas1,nXpos-nNodeSizeX/2,nYpos + nNodeSizeY/2, 10) ; canvas1.create_text(nXpos-nNodeSizeX/2, nYpos + nNodeSizeY/2,text=listNodeNames[2])

#-------------------------------------------------------------------
# Create four third level nodes (D, E, F, and G)
#-------------------------------------------------------------------
nXpos = 500;    nYpos = 400;
arrNodeId[2][0]     = canvas1.create_rectangle(nXpos, nYpos, nXpos + nNodeSizeX, nYpos + nNodeSizeY, fill='lightgrey')
arrNodeText[2][0]   = canvas1.create_text(nXpos+nNodeSizeX/2, nYpos+nNodeSizeY/2 ,text="00", font=fontNodeOff)
circle(canvas1,nXpos-nNodeSizeX/2,nYpos + nNodeSizeY/2, 10) ; canvas1.create_text(nXpos-nNodeSizeX/2, nYpos + nNodeSizeY/2,text=listNodeNames[3])

nXpos = 660;    nYpos = 400;
arrNodeId[2][1]     = canvas1.create_rectangle(nXpos, nYpos, nXpos + nNodeSizeX, nYpos + nNodeSizeY, fill='lightgrey')
arrNodeText[2][1]   = canvas1.create_text(nXpos+nNodeSizeX/2, nYpos+nNodeSizeY/2 ,text="00", font=fontNodeOff)
circle(canvas1,nXpos-nNodeSizeX/2,nYpos + nNodeSizeY/2, 10) ; canvas1.create_text(nXpos-nNodeSizeX/2, nYpos + nNodeSizeY/2,text=listNodeNames[4])

nXpos = 820;    nYpos = 400;
arrNodeId[2][2]     = canvas1.create_rectangle(nXpos, nYpos, nXpos + nNodeSizeX, nYpos + nNodeSizeY, fill='lightgrey')
arrNodeText[2][2]   = canvas1.create_text(nXpos+nNodeSizeX/2, nYpos+nNodeSizeY/2 ,text="00", font=fontNodeOff)
circle(canvas1,nXpos-nNodeSizeX/2,nYpos + nNodeSizeY/2, 10) ; canvas1.create_text(nXpos-nNodeSizeX/2, nYpos + nNodeSizeY/2,text=listNodeNames[5])

nXpos = 980;    nYpos = 400;
arrNodeId[2][3]     = canvas1.create_rectangle(nXpos, nYpos, nXpos + nNodeSizeX, nYpos + nNodeSizeY, fill='lightgrey')
arrNodeText[2][3]   = canvas1.create_text(nXpos+nNodeSizeX/2, nYpos+nNodeSizeY/2 ,text="00", font=fontNodeOff)
circle(canvas1,nXpos-nNodeSizeX/2,nYpos + nNodeSizeY/2, 10) ; canvas1.create_text(nXpos-nNodeSizeX/2, nYpos + nNodeSizeY/2,text=listNodeNames[6])

#-------------------------------------------------------------------
# Create eight fourth level nodes (H through O) 
#-------------------------------------------------------------------
nXpos = 460;    nYpos = 540;
for x in range(0, 8, 1):     # Eight nodes
    arrNodeId[3][x]     = canvas1.create_rectangle(nXpos+(x*80), nYpos, nXpos + nNodeSizeX + (x*80), nYpos+nNodeSizeY, fill='lightgrey', width=1)
    arrNodeText[3][x]   = canvas1.create_text(nXpos+nNodeSizeX/2+(x*80), nYpos+nNodeSizeY/2 ,text="00", font=fontNodeOff)
    circle(canvas1,nXpos+(x*80)+nNodeSizeX/2, nYpos + 3*nNodeSizeY/2, 10) ; canvas1.create_text(nXpos+(x*80)+nNodeSizeX/2, nYpos + 3*nNodeSizeY/2,text=listNodeNames[7+x])



#-------------------------------------------------------------------
# Lines from Node A to B and C
#-------------------------------------------------------------------
arrLineId[0][0] = canvas1.create_line(760, 121, 600, 219, fill="lightgrey", width=3)
arrLineId[0][1] = canvas1.create_line(760, 121, 920, 219, fill="lightgrey", width=3)

#-------------------------------------------------------------------
# Lines from Node B to D and E
#-------------------------------------------------------------------
arrLineId[1][0] = canvas1.create_line(600, 260, 520, 400, fill="lightgrey", width=3)
arrLineId[1][1] = canvas1.create_line(600, 260, 680, 400, fill="lightgrey", width=3)

#-------------------------------------------------------------------
# Lines from Node C to F and G
#-------------------------------------------------------------------
arrLineId[1][2] = canvas1.create_line(900+20, 260, 820+20, 400, fill="lightgrey", width=3)
arrLineId[1][3] = canvas1.create_line(900+20, 260, 980+20, 400, fill="lightgrey", width=3)

#-------------------------------------------------------------------
# Lines from Node D to H and I
#-------------------------------------------------------------------
arrLineId[2][0] = canvas1.create_line(500+20, 400+40, 460+20, 540, fill="lightgrey", width=3)
arrLineId[2][1] = canvas1.create_line(500+20, 400+40, 540+20, 540, fill="lightgrey", width=3)
#-------------------------------------------------------------------
# Lines from Node E to J and K
#-------------------------------------------------------------------
arrLineId[2][2] = canvas1.create_line(660+20, 400+40, 620+20, 540, fill="lightgrey", width=3)
arrLineId[2][3] = canvas1.create_line(660+20, 400+40, 700+20, 540, fill="lightgrey", width=3)
#-------------------------------------------------------------------
# Lines from Node F to L and M
#-------------------------------------------------------------------
arrLineId[2][4] = canvas1.create_line(820+20, 400+40, 780+20, 540, fill="lightgrey", width=3)
arrLineId[2][5] = canvas1.create_line(820+20, 400+40, 860+20, 540, fill="lightgrey", width=3)
#-------------------------------------------------------------------
# Lines from Node G to N and O
#-------------------------------------------------------------------
arrLineId[2][6] = canvas1.create_line(980+20, 400+40, 940+20, 540, fill="lightgrey", width=3)
arrLineId[2][7] = canvas1.create_line(980+20, 400+40, 1020+20,540, fill="lightgrey", width=3)

#-------------------------------------------------------------------
# Text labels for output hitmap "A B  D  E  ....
#-------------------------------------------------------------------
step = 25
canvas1.create_text(100,        680, anchor=SW, font=fontHitResult, text="Node Id")
canvas1.create_text(600+ 0*step,680, anchor=SW, font=fontHitResult, text="A")
canvas1.create_text(600+ 1*step,680, anchor=SW, font=fontHitResult, text="B")
canvas1.create_text(600+ 2*step,680, anchor=SW, font=fontHitResult, text="D")
canvas1.create_text(600+ 3*step,680, anchor=SW, font=fontHitResult, text="E")
canvas1.create_text(600+ 4*step,680, anchor=SW, font=fontHitResult, text="H")
canvas1.create_text(600+ 5*step,680, anchor=SW, font=fontHitResult, text="I")
canvas1.create_text(600+ 6*step,680, anchor=SW, font=fontHitResult, text="J")
canvas1.create_text(600+ 7*step,680, anchor=SW, font=fontHitResult, text="K")
canvas1.create_text(600+ 8*step,680, anchor=SW, font=fontHitResult, text="C")
canvas1.create_text(600+ 9*step,680, anchor=SW, font=fontHitResult, text="F")
canvas1.create_text(600+10*step,680, anchor=SW, font=fontHitResult, text="G")
canvas1.create_text(600+11*step,680, anchor=SW, font=fontHitResult, text="L")
canvas1.create_text(600+12*step,680, anchor=SW, font=fontHitResult, text="M")
canvas1.create_text(600+13*step,680, anchor=SW, font=fontHitResult, text="N")
canvas1.create_text(600+14*step,680, anchor=SW, font=fontHitResult, text="O")

# Should make arrNodeTest[][] into a single dimension array so a for loop can be used
#for i in range (0, 14) :
#    arrTextHitBits[i] = canvas1.create_text(600+ i*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[i][0],'text'))

# Print node text in this order = ["A",  "B",  "D","E", "H","I","J","K",  "C", "F","G",  "L","M","N","O"]
canvas1.create_text(100,700, anchor=SW, font=fontHitResult, text="Concatenate pairs of bits in the tree that are not both zero")
arrTextHitBits[0][0] = canvas1.create_text(600+ 0*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[0][0],'text'), fill="lightgrey") # "A"
arrTextHitBits[1][0] = canvas1.create_text(600+ 1*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[1][0],'text'), fill="lightgrey") # "B"
arrTextHitBits[2][0] = canvas1.create_text(600+ 2*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[2][0],'text'), fill="lightgrey") # "D"
arrTextHitBits[2][1] = canvas1.create_text(600+ 3*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[2][1],'text'), fill="lightgrey") # "E"
arrTextHitBits[3][0] = canvas1.create_text(600+ 4*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][0],'text'), fill="lightgrey") # "H"
arrTextHitBits[3][1] = canvas1.create_text(600+ 5*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][1],'text'), fill="lightgrey") # "I"
arrTextHitBits[3][2] = canvas1.create_text(600+ 6*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][2],'text'), fill="lightgrey") # "J"
arrTextHitBits[3][3] = canvas1.create_text(600+ 7*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][3],'text'), fill="lightgrey") # "K"
arrTextHitBits[1][1] = canvas1.create_text(600+ 8*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[1][1],'text'), fill="lightgrey") # "C"
arrTextHitBits[2][2] = canvas1.create_text(600+ 9*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[2][2],'text'), fill="lightgrey") # "F"
arrTextHitBits[2][3] = canvas1.create_text(600+10*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[2][3],'text'), fill="lightgrey") # "G"
arrTextHitBits[3][4] = canvas1.create_text(600+11*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][4],'text'), fill="lightgrey") # "L"
arrTextHitBits[3][5] = canvas1.create_text(600+12*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][5],'text'), fill="lightgrey") # "M"
arrTextHitBits[3][6] = canvas1.create_text(600+13*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][6],'text'), fill="lightgrey") # "N"
arrTextHitBits[3][7] = canvas1.create_text(600+14*step, 700, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][7],'text'), fill="lightgrey") # "O"
idNumBits1 = canvas1.create_text(600+ 15*step, 700, anchor=SW, font=fontHitResult, text=str(size_bit_text(canvas1, arrTextHitBits ))+" bits") 

canvas1.create_text(100,720, anchor=SW, font=fontHitResult, text="Bit code replacement of '01' with '0'")
arrTextHitBits2[0][0] = canvas1.create_text(600+ 0*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[0][0],'text'), fill="lightgrey") # "A"
arrTextHitBits2[1][0] = canvas1.create_text(600+ 1*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[1][0],'text'), fill="lightgrey") # "B"
arrTextHitBits2[2][0] = canvas1.create_text(600+ 2*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[2][0],'text'), fill="lightgrey") # "D"
arrTextHitBits2[2][1] = canvas1.create_text(600+ 3*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[2][1],'text'), fill="lightgrey") # "E"
arrTextHitBits2[3][0] = canvas1.create_text(600+ 4*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][0],'text'), fill="lightgrey") # "H"
arrTextHitBits2[3][1] = canvas1.create_text(600+ 5*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][1],'text'), fill="lightgrey") # "I"
arrTextHitBits2[3][2] = canvas1.create_text(600+ 6*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][2],'text'), fill="lightgrey") # "J"
arrTextHitBits2[3][3] = canvas1.create_text(600+ 7*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][3],'text'), fill="lightgrey") # "K"
arrTextHitBits2[1][1] = canvas1.create_text(600+ 8*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[1][1],'text'), fill="lightgrey") # "C"
arrTextHitBits2[2][2] = canvas1.create_text(600+ 9*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[1][1],'text'), fill="lightgrey") # "F"
arrTextHitBits2[2][3] = canvas1.create_text(600+10*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[2][3],'text'), fill="lightgrey") # "G"
arrTextHitBits2[3][4] = canvas1.create_text(600+11*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][4],'text'), fill="lightgrey") # "L"
arrTextHitBits2[3][5] = canvas1.create_text(600+12*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][5],'text'), fill="lightgrey") # "M"
arrTextHitBits2[3][6] = canvas1.create_text(600+13*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][6],'text'), fill="lightgrey") # "N"
arrTextHitBits2[3][7] = canvas1.create_text(600+14*step, 720, anchor=SW, font=fontHitResult, text=canvas1.itemcget(arrNodeText[3][7],'text'), fill="lightgrey") # "O"
idNumBits2 = canvas1.create_text(600+ 15*step, 720, anchor=SW, font=fontHitResult, text=str(size_bit_text(canvas1, arrTextHitBits2))+" bits") 

# Final bit pattern with no gaps
canvas1.create_text(100,760, anchor=SW, font=fontHitResult, text="Final bit pattern")
idFinalBits             = canvas1.create_text(600+ 0*step, 760, anchor=SW, font=fontHitResult, text=makeStringFinal(canvas1,arrTextHitBits2), fill="lightgrey") 
idNumBits3 = canvas1.create_text(600+ 15*step, 760, anchor=SW, font=fontHitResult, text=str(size_bit_text(canvas1, arrTextHitBits2))+" bits") 


#-------------------------------------------------------------------
# Boxes around bit string text 
#-------------------------------------------------------------------
canvas1.create_line(600-5, 660, 600-5+14*step+100, 660, fill="black", width=1)  # Horiz
canvas1.create_line(600-5, 680, 600-5+14*step+100, 680, fill="black", width=1)
canvas1.create_line(600-5, 700, 600-5+14*step+100, 700, fill="black", width=1)
canvas1.create_line(600-5, 720, 600-5+14*step+100, 720, fill="black", width=1)

for i in  range (0,16):
    canvas1.create_line(600-5+i*step, 660, 600-5+i*step, 720, fill="black", width=1)  # Vert

canvas1.create_line(600-5+14*step+100, 660, 600-5+14*step+100, 720, fill="black", width=1)  # Vert

#-------------------------------------------------------------------
# Set the function to call when a mouse click occurs in the Canvas
#-------------------------------------------------------------------
canvas1.bind('<Button-1>', OnCanvasClick)                  

#-----------------------------------------------------------------------------------------------------------------------------
# Start the event loop and run forever
#-----------------------------------------------------------------------------------------------------------------------------
mainloop()

