#
# ev1_w_metric_plots.py:
#    EV1 with metrics accumulation and plotting (using matplotlib)
#    Also, uses Rastrigrin fitness function as example
#
# To run: python ev1_w_metric_plots.py --input ev1_example.cfg
#         python ev1_w_metric_plots.py --input my_params.cfg
#
# Note: EV1 is fairly naive and has many fundamental limitations,
#           however, even though it's simple, it works!
#

import optparse
import sys
import yaml
import math
from random import Random
from statistics import mean,stdev
import matplotlib.pyplot as plt


#EV1 Config class 
class EV1_Config:
    """
    EV1 configuration class
    """
    # class variables
    sectionName='EV1'
    options={'populationSize': (int,True),
             'generationCount': (int,True),
             'randomSeed': (int,True),
             'minLimit': (float,True),
             'maxLimit': (float,True),
             'mutationProb': (float,True),
             'mutationStddev': (float,True)}
     
    #constructor
    def __init__(self, inFileName):
        #read YAML config and get EC_Engine section
        infile=open(inFileName,'r')
        ymlcfg=yaml.safe_load(infile)
        infile.close()
        eccfg=ymlcfg.get(self.sectionName,None)
        if eccfg is None: raise Exception('Missing EV1 section in cfg file')
         
        #iterate over options
        for opt in self.options:
            if opt in eccfg:
                optval=eccfg[opt]
 
                #verify parameter type
                if type(optval) != self.options[opt][0]:
                    raise Exception('Parameter "{}" has wrong type'.format(opt))
                 
                #create attributes on the fly
                setattr(self,opt,optval)
            else:
                if self.options[opt][1]:
                    raise Exception('Missing mandatory parameter "{}"'.format(opt))
                else:
                    setattr(self,opt,None)
     
    #string representation for class data    
    def __str__(self):
        return str(yaml.dump(self.__dict__,default_flow_style=False))


#Basic class for computing, managing, plotting EV1 run stats
#
class EV_Stats:
    def __init__(self):
        self.bestState=[]
        self.bestFit=[]
        self.meanFit=[]
        self.stddevFit=[]
    
    def accumulate(self,pop):
        #find state with max fitness
        # max_fit=pop[0].fit
        # max_fit_state=pop[0].x
        # for p in pop:
        #     if p.fit > max_fit: 
        #         max_fit=p.fit
        #         max_fit_state=p.x
        avgval=0
        max_fit=pop[0].fit 
        sigma=pop[0].sigma
        for ind in pop:
            avgval+=ind.fit
            if ind.fit > max_fit:
                max_fit=ind.fit
                sigma=ind.sigma

       
        self.bestState.append(sigma)
        self.bestFit.append(max_fit)
        
        #compute mean and stddev
        fits=[p.fit for p in pop]
        self.meanFit.append(mean(fits))
        self.stddevFit.append(stdev(fits))

    
    def print(self, gen=None):
        #if gen not specified, print latest
        if gen is None: gen=len(self.bestState)-1
        print('Generation:',gen)
        print('Best fitness  : ',self.bestFit[gen])
        print('Best state    : ',self.bestState[gen])
        print('Mean fitness  : ',self.meanFit[gen])
        print('Stddev fitness: ',self.stddevFit[gen])
        print('')
    
    def plot(self):
        #plot stats to screen & file using matplotlib
        gens=range(len(self.bestState))
        
        #create stacked plots (4x1)
        plt.subplots_adjust(hspace=0.5)
        plt.subplot(411)
        plt.plot(gens,self.bestFit)
        plt.ylabel('Max Fit')
        plt.title('EV1 Run Statistics')
        plt.subplot(412)
        plt.plot(gens,self.bestState)
        plt.ylabel('x @ max fit')
        plt.subplot(413)
        plt.plot(gens,self.meanFit)
        plt.ylabel('Mean Fit')
        plt.subplot(414)
        plt.plot(gens,self.stddevFit)
        plt.ylabel('Stddev Fit')
        
        #write plots to .png file, then display to screen
        plt.savefig('7109064382.png')
        plt.show()
    
    def __str__(self):
        s=''
        s+='bestFits  : ' + str(self.bestFit) + '\n'
        s+='bestStates: ' + str(self.bestState) + '\n'
        s+='meanFits  : ' + str(self.meanFit) + '\n'
        s+='stddevFits: ' + str(self.stddevFit)
        return s
             

#1-D Rastrigrin fitness function example
#        
def fitnessFunc(x):
    return -10.0-(0.04*x)**2+10.0*math.cos(0.04*math.pi*x)


#Small helper function for plotting fitness function to screen
#
def plotFitnessFunc(fitnessFunc,minLimit,maxLimit,numPoints):
    step=(maxLimit-minLimit)/numPoints
    y=[]
    xr=[step*i+minLimit for i in range(numPoints)]
    for x in xr:
        y.append(fitnessFunc(x))
    plt.plot(xr,y,linestyle='solid')  
    plt.title('Fitness Function')  
    plt.xlabel('x')
    plt.ylabel('fitness')
    plt.show()


#Find index of worst individual in population
def findWorstIndex(l):
    minval=l[0].fit
    imin=0
    for i in range(len(l)):
        if l[i].fit < minval:
            minval=l[i].fit
            imin=i
    return imin


#A trivial Individual class
class Individual:
    
    minSigma=1e-100
    maxSigma=1
    learningRate=1
    minLimit=None
    maxLimit=None
    cfg=None
    prng=None
    fitFunc=None

        
    def __init__(self,randomInit=True,x=0,fit=0):
        if randomInit:
            self.x=self.prng.uniform(self.minLimit,self.maxLimit)
            self.fit=self.__class__.fitFunc(self.x)
            self.sigma=self.prng.uniform(0.9,0.1) 
        else:
            self.x=0
            self.fit=0
            self.sigma=self.minSigma

    def crossover(self, other):
        child=Individual(randomInit=False)
        alpha=self.prng.random()
        child.x=self.x*alpha+other.x*(1-alpha)
        child.sigma=self.sigma*alpha+other.sigma*(1-alpha)
        child.fit=None
        
        return child
    
    def mutate(self):
        self.sigma=self.sigma*math.exp(self.learningRate*self.prng.normalvariate(0,1))
        if self.sigma < self.minSigma: self.sigma=self.minSigma
        if self.sigma > self.maxSigma: self.sigma=self.maxSigma

        self.x=self.x+(self.maxLimit-self.minLimit)*self.sigma*self.prng.normalvariate(0,1)
    
    def evaluateFitness(self):
        self.fit=self.__class__.fitFunc(self.x)


#EV1: The simplest EA ever!
#            
def ev1(cfg):
    # start random number generator
    prng=Random()
    prng.seed(cfg.randomSeed)
    
    Individual.minLimit=cfg.minLimit
    Individual.maxLimit=cfg.maxLimit
    Individual.fitFunc=fitnessFunc
    Individual.prng=prng

    #random initialization of population
    population=[]
    for i in range(cfg.populationSize):
        x=prng.uniform(cfg.minLimit,cfg.maxLimit)
        ind=Individual(x,fitnessFunc(x))
        population.append(ind)
        
    #accumulate & print stats
    stats=EV_Stats()
    stats.accumulate(population)
    stats.print()

    #evolution main loop
    for i in range(cfg.generationCount):
        #randomly select two parents
        parents=prng.sample(population,2)

        # #recombine using simple average
        # childx=(parents[0].x+parents[1].x)/2
        
        # #random mutation using normal distribution
        # if prng.random() <= cfg.mutationProb:
        #     childx=prng.normalvariate(childx,cfg.mutationStddev)
            
        # #survivor selection: replace worst
        # child=Individual(childx,fitnessFunc(childx))

        child=parents[0].crossover(parents[1])
        
        child.mutate()
        
        child.evaluateFitness()


        iworst=findWorstIndex(population)
        if child.fit > population[iworst].fit:
            population[iworst]=child
        
        #accumulate & print stats    
        stats.accumulate(population)
        stats.print()
        
    #plot accumulated stats to file/screen using matplotlib
    stats.plot()
        
        
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
        parser.add_option("-i", "--input", action="store", dest="inputFileName", help="input filename", default=None)
        parser.add_option("-q", "--quiet", action="store_true", dest="quietMode", help="quiet mode", default=False)
        parser.add_option("-d", "--debug", action="store_true", dest="debugMode", help="debug mode", default=False)
        (options, args) = parser.parse_args(argv)
        
        #validate options
        if options.inputFileName is None:
            raise Exception("Must specify input file name using -i or --input option.")
        
        #Get EV1 config params
        cfg=EV1_Config(options.inputFileName)
        
        #print config params
        print(cfg)
        
        #before we run, let's plot fitness function to screen
        # to see what we're optimizing
        plotFitnessFunc(fitnessFunc,cfg.minLimit,cfg.maxLimit,100)
                    
        #run EV1
        ev1(cfg)
        
        if not options.quietMode:                    
            print('EV1 Completed!')    
    
    except Exception as info:
        if 'options' in vars() and options.debugMode:
            from traceback import print_exc
            print_exc()
        else:
            print(info)
    

if __name__ == '__main__':
    main()
    
