# ev1_plot_utils.py:
# Utils for interactive ev1 plotting
#

pause_length=1

import matplotlib.pyplot as plt
fig, ax = plt.subplots(1,1)
plt.ion()
plt.show()

def plotFitnessFunc(fitnessFunc,minLimit,maxLimit,numPoints):
    step=(maxLimit-minLimit)/numPoints
    y=[]
    xr=[step*i+minLimit for i in range(numPoints)]
    for x in xr:
        y.append(fitnessFunc(x))
    plt.plot(xr,y,linestyle='solid')    
    return plt


def plotGeneration(pop):
    mpl_pts=[]
    for p in pop:
        mpl_pt=ax.scatter(p.x, p.fit)
        mpl_pts.append(mpl_pt)
    plt.pause(pause_length)
    return mpl_pts

def removePlotGeneration(mpl_pts):        
    for pt in mpl_pts:
        pt.remove()            


