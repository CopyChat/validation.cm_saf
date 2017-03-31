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
title='GEBA monthly RSDS obs in southern Africa 1983-2005 (110 stations)'

#=================================================== plot
STATION_5year = 'flag.rsds.monthly.1983-2005.csv'
STATION_idfile = 'station.south.africa.sort.110'

station_5year = np.array(pd.read_csv(DIR+STATION_5year,header=None))
station_id = np.array(pd.read_csv(DIR+STATION_idfile,header=None))[:,0]
station_name = np.array(pd.read_csv(DIR+STATION_idfile,header=None))[:,3]

#--------------------------------------------------- 
def justice(flag):
    jjj=999
    s=list(str(int(flag)))
    if len(s) > 1:
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

# get no of monthly records:index 3 : 15
NO_month=np.zeros((12))
MonthData=station_5year[:,3:15]

# print running log to stdout
for month in range(12):
    for sta in range((station_5year).shape[0]):
        print "month:",month,"station:",sta,"flag:",\
                MonthData[sta,month],"justice",justice(MonthData[sta,month])
        if justice(MonthData[sta,month]) == 1 :
            NO_month[month]+=1

#=================================================== 
fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(12,7),\
        facecolor='w', edgecolor='k') # figsize=(w,h)
fig.subplots_adjust(left=0.2)

ax.set_ylabel('NO. of monthly record',fontsize=14)
ax.set_xlabel('Month',fontsize=14)


month12=['Jan','Feb','Mar','Api','May','Jun',\
        'Jul','Aug','Sep','Oct','Nov','Dec']
dates=np.arange(len(month12))
plt.xticks(dates, month12, rotation=0)

ax.set_title(title,fontsize=14)

plt.bar(dates, NO_month, align='center', alpha=0.5)

plt.savefig('mon.statis.SA.8305.eps',format='eps')

#===================================================  end of subplot 3
print "done"
plt.show()

quit()

