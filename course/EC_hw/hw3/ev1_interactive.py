# ev1.py: The simplest EA ever!
#
import math
from random import Random
from ev1_plot_utils import *

#configuration parameters
populationSize=10
generationCount=50
randomSeed=1234
minLimit=-100.0
maxLimit=100.0
mutationProb=0.25
mutationStddev=1.0
evaluatorType='parabola' # or parabola
        
def fitnessFunc(x):
    if evaluatorType == 'parabola':
        return  50-x*x
    elif evaluatorType == 'rastrigrin':
        return -10.0-(0.04*x)**2+10.0*math.cos(0.04*math.pi*x)
    else:
        raise Exception('Unknown evaluator type: {}'.format(evaluatorType))

def findWorstIndex(l):
    minval=l[0].fit
    imin=0
    for i in range(len(l)):
        if l[i].fit < minval:
            minval=l[i].fit
            imin=i
    return imin

mpl_pts=[]
def printStats(pop,gen):
    global mpl_pts
    removePlotGeneration(mpl_pts)
    print('Generation:',gen)
    avgval=0
    maxval=pop[0].fit
    for p in pop:
        avgval+=p.fit
        if p.fit > maxval: maxval=p.fit
        print(str(p.x)+'\t'+str(p.fit))
    
    print('Max fitness',maxval)
    print('Avg fitness',avgval/len(pop))
    print('')
    mpl_pts=plotGeneration(pop)

class Individual:
    def __init__(self,x=0,fit=0):
        self.x=x
        self.fit=fit
            
def ev1():
    # start random number generator
    prng=Random()
    prng.seed(randomSeed)
    
    #random initialization of population
    population=[]
    for i in range(populationSize):
        x=prng.uniform(minLimit,maxLimit)
        ind=Individual(x,fitnessFunc(x))
        population.append(ind)
        
    #print stats    
    printStats(population,0)
    input('Press key to continue')

    #evolution main loop
    for i in range(generationCount):
        #randomly select two parents
        parents=prng.sample(population,2)

        #recombine using simple average
        childx=(parents[0].x+parents[1].x)/2
        
        #random mutation using normal distribution
        if prng.random() <= mutationProb:
            childx=prng.normalvariate(childx,mutationStddev)
            
        #survivor selection: replace worst
        child=Individual(childx,fitnessFunc(childx))
        iworst=findWorstIndex(population)
        if child.fit > population[iworst].fit:
            population[iworst]=child
        
        #print stats    
        printStats(population,i+1)
        

#run ev1!
plt=plotFitnessFunc(fitnessFunc,minLimit,maxLimit,200)
ev1()
plt.pause(10)
