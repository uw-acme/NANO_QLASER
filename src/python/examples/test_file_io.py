#------------------------------------------------------
#
# Create a file name. Check if the file already exists.
# If it does, increment part of the file name and try
# again.
# Open file. Write into file. Close file
#------------------------------------------------------
import os.path
from pathlib import Path

nSerialNumberBoard  = 0
nCounterFileNum     = 0
nFileNameGood       = 0

strFileName = "Report_" + repr(nSerialNumberBoard) + "_" + repr(nCounterFileNum) + ".txt"
print (strFileName)
print ("End")

while (nFileNameGood == 0):

    my_file = Path(strFileName)

    if (my_file.is_file() == False):
        outputfile = open(my_file, 'w')
        nFileNameGood = 1
    else:
        nCounterFileNum = nCounterFileNum + 1
        strFileName = "Report_" + repr(nSerialNumberBoard) + "_" + repr(nCounterFileNum) + ".txt"
        print (strFileName)


outputfile.write(strFileName + "\n")
outputfile.write("a\n")
outputfile.write(strFileName + "\n")

outputfile.close()
