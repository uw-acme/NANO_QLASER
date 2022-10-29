from time import gmtime, strftime

strDateTime = strftime("%Y-%m-%d %H:%M:%S", gmtime())

print (strDateTime)

nProgramVersion   = 20

strTemp = "Program Version : " + repr(nProgramVersion) + "\n\n\n"
print (strTemp)
print ("End")

nHexValue = 32

print ("Hex value of %(1)05d is : 0x%(0)04X" %{'0':0xb3, '1':nHexValue})

