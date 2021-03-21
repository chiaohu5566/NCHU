#
# example_main.py
#
import optparse
import sys
import yaml

        
        
#
# Main entry point
#
def main(argv=None):
	if argv is None:
		argv = sys.argv
        
	try:
        #
        # get command-line options
        #
		parser = optparse.OptionParser()
		parser.add_option("-i", "--inputfile", action="store", dest="inputFileName", help="input FileName", default=None)
		parser.add_option("-o", "--outputfile", action="store", dest="outputFileName", help="output FileName", default=None)
		parser.add_option("-q", "--quiet", action="store_true", dest="quietMode", help="quiet mode", default=False)
		(options, args) = parser.parse_args(argv)


        #do something here...        
		#---------------------------------
		#--------------class--------------
		#---------------------------------
		class Out():
			pass
		a=Out()
		a.missingParams=[]
		a.incorrectTypes=[]
		#---------------------------------
		#---------------------------------
		#
		#
		# read file
		i=open(options.inputFileName, 'r')
		yml=yaml.full_load(i)
		i.close()


		#check title
		#
		if 'EC_Engine' in yml:
			ec_cfg=yml['EC_Engine']
		else:
			raise Exception ('config file is error')
		

		#validation datatype & mandatory/optional (True/False)
		#

		val={'populationSize':(int,True,),
			 'generationCount':(int,True),
			 'randomSeed':(int,False),
			 'evaluatorType':(str,True),
			 'jobName':(str,False),
			 'scalingParam':(float,False)}


		#verify input config
		#
		for verify in val:
			if verify in ec_cfg:
				verify_t=ec_cfg[verify]
				if type(verify_t) != val[verify][0]:
					a.incorrectTypes.append(verify)
			else:			
				if val[verify][1]:
					a.missingParams.append(verify)

		#sorted
		a.incorrectTypes.sort()
		a.missingParams.sort()

		#------------write to outputfile (yaml)-------------
		yaml.dump(a.__dict__,open(options.outputFileName,'w'))
        #---------------------------------------------------            
		if not options.quietMode :                    
			print('Main Completed!')    
    		
	except Exception as info:
		if 'options' in vars() and not options.quietMode:
			raise   #re-raise Exception, interpreter shows stack trace
		else:
			print(info)   
    

if __name__ == '__main__':
    main()
    
