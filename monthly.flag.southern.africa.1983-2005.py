#!/usr/bin/env python
"""
========
ctang, a map of geba stations in southern africa
========
"""
import math
import datetime
import pandas as pd
import numpy as np
import matplotlib as mpl
from textwrap import wrap
import matplotlib.pyplot as plt
from mpl_toolkits.basemap import Basemap , addcyclic
from matplotlib.dates import YearLocator,MonthLocator,DateFormatter,drange
import sys 
sys.path.append('/Users/ctang/Code/Python/')
import ctang


DIR='/Users/ctang/climate/GLOBALDATA/OBSDATA/GEBAdata/validation.cm_saf/'

 
#=================================================== titles
title='GEBA monthly RSDS obs in southern Africa 1983-2005'

#=================================================== plot

STATION_idfile = 'station.south.africa.sort.110'
station_id = np.array(pd.read_csv(DIR+STATION_idfile,header=None))[:,0]
station_name = np.array(pd.read_csv(DIR+STATION_idfile,header=None))[:,3]
lats = np.array(pd.read_csv(DIR+STATION_idfile,header=None))[:,1]
lons = np.array(pd.read_csv(DIR+STATION_idfile,header=None))[:,2]

STATION_5year = 'flag.rsds.monthly.1983-2005.csv'
station_5year = np.array(pd.read_csv(DIR+STATION_5year,header=None))

records=np.zeros((len(station_id),23*12))
records_tag = records+999         # restore the quality index (-1,0,1) for records
TAG = np.zeros((len(station_id))) # num of records for each station

for sta in range(len(station_id)):
    records[sta]=np.array(station_5year[station_5year[:,0]==station_id[sta]])[:,3:15].reshape(23*12)

#--------------------------------------------------- function for quality control of GEBA
def justice(flag):
    jjj=999
    s=list(str(int(flag)))
    if len(s) > 1:
        print 'testing'
        if s[4] == '8':
            if s[3] == '7' or s[3] == '8' :
                if s[2] == '5' or s[2] == '7' or s[2] == '8':
                    if s[1] == '5':
                        if s[0] == '5':
                            jjj = 1
                        else:
                            jjj = -1
                    else:
                        jjj = -1
                else:
                    jjj = -1
            else:
                jjj = -1
        else:
            jjj = -1
    else:
        jjj = 0
    return jjj 
#--------------------------------------------------- 

for sta in range(len(station_id)):
    for i in range(23*12):
        if justice(records[sta,i]) == 1:
            records_tag[sta,i]=1
        else:
            records_tag[sta,i]=-1

# all 100 southern.africa are considered here, so some station has no record under 1983-2005.
for sta in range(len(station_id)):
    TAG[sta] = np.array(np.where(records_tag[sta,:] > 0)).shape[1]
    print station_id[sta],station_name[sta],TAG[sta]

#=================================================== plotting
fig, axes = plt.subplots(nrows=1, ncols=1, figsize=(10,8),\
        facecolor='w', edgecolor='k') # figsize=(w,h)
#fig.subplots_adjust(left=0.04,bottom=0.15,right=0.98,hspace=0.15,top=0.8,wspace=0.43)

plt.sca(axes) # active shis subplot 
axx=axes

vmin = 10
vmax = 250
cmap = plt.cm.YlOrRd
cmaplist = [cmap(i) for i in range(cmap.N)]
bounds = np.linspace(vmin,vmax,13)
norm = mpl.colors.BoundaryNorm(bounds, cmap.N)

map=Basemap(projection='cyl',llcrnrlat=-45,urcrnrlat=1,llcrnrlon=0,urcrnrlon=60,resolution='h')
ctang.setMap(map)


for sta in range(len(station_id)):
    if TAG[sta] > 0:
        sc=plt.scatter(\
            lons[sta], lats[sta], c=TAG[sta],edgecolor='black',\
            zorder=2,norm=norm,vmin=vmin,vmax=vmax,s=35, cmap=cmap)

cb=plt.colorbar(sc,orientation='horizontal',shrink=0.6)
cb.ax.tick_params(labelsize=9) 
cb.ax.set_title("number of monthly records")
axx.set_title("\n".join(wrap(title)))


#for sta in range(len(station_id)):
    #if TAG[sta] > 0:
        #plt.annotate( int(TAG[sta]),xy=(lons[sta], lats[sta]), xytext=(-15, 15),\
            #textcoords='offset points', ha='right', va='bottom',\
            #bbox=dict(boxstyle='round,pad=0.5', fc='yellow', alpha=0.5),\
            #arrowprops=dict(arrowstyle = '->', connectionstyle='arc3,rad=0'))

#plt.savefig('monthly.rsds.flag.southern.africa.1983-2005.png')
plt.savefig('monthly.station.southern.africa.1983-2005.eps',format='eps')

#===================================================  end of subplot 3
print "done"
# plt.show()

quit()

