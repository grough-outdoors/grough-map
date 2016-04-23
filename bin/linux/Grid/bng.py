#!/usr/bin/python

import sys, getopt

def getOSGridReference(e, n, decimals=3, quarter=False):
    import math
    
    gridChars = "ABCDEFGHJKLMNOPQRSTUVWXYZ"      
    
    e100k = math.floor(e/100000)
    n100k = math.floor(n/100000)
    
    if e100k > 6 or n100k > 12:
        return ''
    
    l1 = (19-n100k)-(19-n100k)%5+math.floor((e100k+10)/5)
    l2 = (19-n100k)*5%25 + e100k%5
    
    letPair = gridChars[int(l1)] + gridChars[int(l2)]
    
    e100m = math.trunc(math.floor(float(e)/math.pow(10,5-decimals)))
    egr = str(e100m).rjust(decimals + 1, "0")[1:] 
    if n >= 1000000:
        n = n - 1000000 # Fix Shetland northings
    n100m = math.trunc(math.floor(float(n)/math.pow(10,5-decimals)))
    ngr = str(n100m).rjust(decimals + 1, "0")[1:]
    
    gridQuarter = ""
    if quarter:
        e100m = math.trunc(math.floor(float(e)/math.pow(10,5-decimals-1)))
        n100m = math.trunc(math.floor(float(n)/math.pow(10,5-decimals-1)))
        if int(str(n100m)[-1:]) >= 5:
            gridQuarter += 'N'
        else:
            gridQuarter += 'S'
        if int(str(e100m)[-1:]) >= 5:
            gridQuarter += 'E'
        else:
            gridQuarter += 'W'
    
    return letPair + egr + ngr + gridQuarter

def help():
	print 'bng.py -e <easting> -n <northing>'
	
def main(argv):
	easting = None
	northing = None

	try:
		opts, args = getopt.getopt(argv, "he:n:", ["easting=", "northing="])
	except getopt.GetoptError:
		help()
		sys.exit(2)
	for opt, arg in opts:
		if opt == '-h':
			help()
			sys.exit()
		elif opt in ("-e", "--easting"):
			easting = arg
		elif opt in ("-n", "--northing"):
			northing = arg
			
	if easting == None or northing == None:
		help()
		sys.exit(2)
			
	print getOSGridReference(int(easting), int(northing), 1)
	
if __name__ == "__main__":
	main(sys.argv[1:])
