#!/bin/bash - 
#===============================================================================
#
#          FILE: data.manage.sh
# 
USAGE="./data.manage.sh  "
# 
#         NOTES: ---
#        AUTHOR: Tang (Tang), chao.tang.1@gmail.com
#  ORGANIZATION: le2p
#       CREATED: 03/10/17 21:52:54 RET
#      REVISION:  ---
#===============================================================================

#set -o nounset                             # Treat unset variables as an error
shopt -s extglob 							# "shopt -u extglob" to turn it off
source ~/Shell/functions.sh      			# TANG's shell functions.sh
#=================================================== 

#===================================================  for stations
function do_station()
{
# get station name and location
awk 'NR%2'  GEBAdata_2017-21-10_10-53-18_station.Africa.csv > sta.name
awk '!(NR%2)' GEBAdata_2017-21-10_10-53-18_station.Africa.csv >  sta.location

# sel southern stations
merge.sh sta.location sta.name | awk '$5 ~ /S/{print}' > station.south.temp

# change lonlat format
awk '{print $17,($2+$3/60)*(-1),$7+$8/60,$18,$19,$20,$21,$22,$23}' station.south.temp > station.south.africa

rm *temp sta.name sta.location
}

cp ../validation.cordex/station.south.africa.backup station.south.africa

#===================================================  for flags
function doflag()
{
awk 'NR%2' GEBAdata_2017-21-10_10-53-18.Africa.csv > flag
awk '!(NR%2)' GEBAdata_2017-21-10_10-53-18.Africa.csv > rsds

# seldata better than 55555 and not '6'
awk '{if(match($NF,'3')==0 && match($NF,'4')==0 && match($NF,'1')==0 &&  match($NF,'2')==0 && match($NF,'6')==0 && $NF>55555) print $0}' flag > flag.robust
}


doflag

#--------------------------------------------------- 
# get robust stations:  sattion.robust.1983-2005
awk '$3>1982&&$3<2006{print $0}' flag.robust > flag.robust.1983-2005

rm station.robust.1983-2005
awk '{print $1}' flag.robust.1983-2005 | sort | uniq > flag.robust.stationID.1983-2005.temp
#vim flag.robust.stationID.1983-2005.temp

# get robust stationID and name :25. in the south
for sta in $(cat flag.robust.stationID.1983-2005.temp)
do
    awk -F "," '$1=='$sta'{print $0}' station.south.africa >> station.robust.1983-2005
done

#--------------------------------------------------- ny count
function counter()
{
k=1
for sta in $(awk -F "," '{print $1}' station.robust.1983-2005) # in the south
do
    count=$(awk '$1=='$sta'' flag.robust.1983-2005 | wc -l)
    if [ $count -gt 4 ];
    then
        awk -F "," '$1=='$sta'{printf "%s,%s,%s,",$1,$2,$3}' station.robust.1983-2005
        echo -n $count,
        awk -F "," '$1=='$sta'{print $4}' station.robust.1983-2005
    fi
    ((k++))
done
}
#counter > station.robust.gt.5year.1983-2005.nyear
#vim station.robust.gt.5year.1983-2005.nyear

#=================================================== to plot the monthly flag in 1983-2005
# get the monthly flag for all the southern stations in 1983-2005.

function monthly()
{
i=1
for sta in $(awk -F "," '{print $1}' station.south.africa)
do

    location=$(awk -F "," '$1=='$sta'{print $NF}' station.south.africa)
    for y in {1983..2005}
    do
        
        # sel $sta in $y
        record=$(awk '$1=='$sta' && $3=='$y'' flag | wc -l )

        if [ $record -lt 1 ];
        then
            echo "$sta,1,$y,0,0,0,0,0,0,0,0,0,0,0,0,0,$location"
        else
            awk '$1=='$sta' && $3=='$y'{for(i=1;i<=NF;i++){printf "%s,",$i}}' flag
            #awk '$1=='$sta' && $3=='$y'{for(i=1;i<NF;i++){printf "%s,",$i};{print $NF}}' flag.reform.1983-2005
            echo $location
        fi
    done
    ((i++))
done
}
monthly > flag.rsds.monthly.1983-2005
sort -t "/" -k2 flag.rsds.monthly.1983-2005 > flag.rsds.monthly.1983-2005.csv
# the possible flags : 0, 8, 55528, 55288, 52888, 52828, 
#rm flag.rsds.monthly.1983-2005
exit

sort -t "/" -k2 station.south.africa > station.south.africa.sort.110

#vim flag.rsds.monthly.1983-2005.csv
exit
#=================================================== 
#--------------------------------------------------- 
# get the no of year in each station.1970-1999: station.robust.gt.5year.1970-1999.nyear
echo "StaID,lat,lon,nyear,staid,obsid,year,Jan,Feb,Mar,Api,May,Jun,July,Aug,Sep,Oct,Nov,Dec" > output.temp

function counter()
{
k=1
for sta in $(awk -F "," '{print $1}' station.robust.gt.5year.1970-1999)
do
    count=$(awk -F "," '$1=='$sta'' flag.robust.gt.5year.1970-1999 | wc -l)
    if [ $count -gt 4 ];
    then
        awk -F "," '$1=='$sta'{printf "%s,%s,%s,",$1,$2,$3}' station.robust.1970-1999
        echo -n $count,
        awk -F "," '$1=='$sta'{print $4}' station.robust.1970-1999
    fi
done
}
counter > station.robust.gt.5year.1970-1999.nyear
#vim station.robust.gt.5year.1970-1999.nyear

exit

#--------------------------------------------------- 
# get robust station -gt 5years
function robust.5year()
{
rm station.robust.gt.5year.1970-1999.temp
for sta in $(cat flag.robust.stationID.1970-1999.temp)
do
    awk '$1=='$sta'' flag.robust.1970-1999 > $sta.temp
    line=$(wc -l $sta.temp | awk '{print $1}') 

    if [ $line -gt 4 ];
    then
        echo $line
        awk -F "," '$1=='$sta'' station.robust.1970-1999 >> station.robust.gt.5year.1970-1999.temp
    fi
done
sort -t "/" -k2 station.robust.gt.5year.1970-1999.temp > station.robust.gt.5year.1970-1999

rm *temp
}

#vim station.robust.gt.5year.1970-1999
#--------------------------------------------------- 
# output station_name_32
awk -F "," '{print $1","$NF}' station.robust.gt.5year.1970-1999 > station_name_32

#=================================================== to plot the monthly flag in 1970-1999

# get the monthly flag for all the southern stations, at least 5 years*12 month records in 1970-1999.

function monthly()
{
i=1
for sta in $(awk -F "," '{print $1}' station.robust.gt.5year.1970-1999)
do

    location=$(awk -F "," '$1=='$sta'{print $NF}' station.south.africa)
    for y in {1970..1999}
    do
        
        # sel $sta in $y
        record=$(awk '$1=='$sta' && $3=='$y'' flag.1970-1999 | wc -l )

        if [ $record -lt 1 ];
        then
            echo "$sta,1,$y,0,0,0,0,0,0,0,0,0,0,0,0,0,$location"
        else
            #awk '$1=='$sta' && $3=='$y'{for(i=1;i<NF;i++){printf "%s,",$i};{print $NF}}' flag.reform.1970-1999
            awk '$1=='$sta' && $3=='$y'{for(i=1;i<=NF;i++){printf "%s,",$i}}' flag.1970-1999
            echo $location

        fi
    done
    ((i++))
done
}
monthly > flag.rsds.monthly.1970-1999
sort -t "/" -k2 flag.rsds.monthly.1970-1999 > flag.rsds.monthly.1970-1999.csv
rm flag.rsds.monthly.1970-1999

#vim flag.rsds.monthly.1970-1999.csv
#=================================================== 





exit
awk '{if (NR%2) {printf "%s ", $2} else {print $2+$3/60,$7+$8/60}}' \
    GEBAdata_2017-21-10_10-53-18_station.Africa.csv > station 

#awk 'NR==FNR {k[i++]=$1;q[j++]=$0} NR>FNR {if(k[$1]==$1) print $1,$2,$NF,k[$1],q[$1]}' station rsds.flag

# rmove 99999 and space > rsds.remove.flag

# selyear,1970-1999
awk -F "," '$3>1969&&$3<2000{print $0}' rsds.remove.flag  > rsds.remove.flag.1970-1999
#=================================================== end of initial process




#=================================================== for validation

station=station_name_26
awk -F "," '$3>1969&&$3<2000{print $0}' rsds.remove.flag  > rsds.remove.flag.1970-1999

echo "#StaID1,lat,lon,StaID2,obsID,year,Jan,Feb,Mar,Api,May,Jun,July,Aug,Sep,Oct,Nov,Dec,yearmean,StaName" > rsds.southern.africa.gt.5year.1970-1999.csv
for i in {1..26}
do
    sta=$(awk -F "," 'NR=='$i'{print $1}' $station)
    staname=$(awk -F "," 'NR=='$i'{print $2}' $station)
    # lat ,lon
    location=$(awk -F "," '$1=='$sta'{printf ",%s,%s,",$2,$3}' station.south.africa.backup)

    awk -F "," '$1=='$sta'{print "'$sta'""'$location'"$0",""'$staname'"}' rsds.remove.flag.1970-1999 >> rsds.southern.africa.gt.5year.1970-1999.csv

done

#=================================================== end of validatiaon data praparation

#=================================================== end of station initial process
function countyear()
{
    line=$(wc -l station.south.africa | awk '{print $1}') # for 110 stations

    awk -F "," '$3>1969&&$3<2000{print $0}' rsds.remove.flag  > rsds.remove.flag.1970-1999

    # for all the stations in southern Africa
    for i in $(seq -s " " 1 $line)
    do
        sta=$(awk -F "," 'NR=='$i'{print $1}' station.south.africa)
        awk -F "," '$1=='$sta'' rsds.remove.flag.1970-1999 > $sta.temp
        count=$(cat $sta.temp | wc -l )
        #echo no. $i, station: $sta, count: $count

        # output
        if [ $count -gt 4 ];
        then
            awk -F "," 'NR=='$i'{printf "%s,%s,%s,",$1,$2,$3}' station.south.africa
        echo $count
        fi
done
}
countyear > station.southern.africa.year.1970-1999
echo $(wc -l station.southern.africa.year.1970-1999)
#===================================================  get counts of yearmean records

#=================================================== monthly
# get the station monthly statistic in 1970-1999
function monthly()
{

#--------------------------------------------------- important: which years to consider
awk -F "," '$3>1969&&$3<2000{print $0}' rsds.remove.flag  > rsds.remove.flag.1970-1999
#--------------------------------------------------- important: which years to consider


#=================================================== get flag for final "255" line plot data
line2=$(wc -l rsds.southern.africa.gt.5year.1970-1999.csv| awk '{print $1}') # for 255 lines

k=0
for l in {1..$line2}
do
    echo ======== $k =============
    sta=$(awk -F "," 'NR=='$l'{print $1}' rsds.southern.africa.gt.5year.1970-1999.csv)
    year=$(awk -F "," 'NR=='$l'{print $6}' rsds.southern.africa.gt.5year.1970-1999.csv)
    echo $k,$sta,$year
    #awk -F "," 'if($1=='$sta' && $3=='$year') {print $0}' flag.rsds.monthly.1970-1999
    ((k++))
done

#=================================================== end : get flag

exit
#5year_year > station.5year.jj
#vim station.5year.jj  # mannual change the str of station location
#sort -t"/" -k2 station.5year # sort by the contry name
#=================================================== 
function 5year()
{
rm -rf Fiveyear.rsds 2>&1-
for sta in $(awk -F "," '{print $1}' station)
do
    #echo $sta
    awk -F "," '$1=='$sta'' rsds.remove.flag.1970-1999 > $sta.temp
    #cat $sta.temp

    line=$(cat $sta.temp | wc -l )
    

    if [ $line -gt 4 ];
    then
        awk -F "," '{for(i=4;i<16;i++) {printf "%s\n",$i}}'\
            $sta.temp > $sta.monthly.temp
        mon_std=$(statistic.sh -s $sta.monthly.temp)

        awk -F "," '{printf "%s\n",$16}' $sta.temp > $sta.year.temp
        year_std=$(statistic.sh -s $sta.year.temp)

    year1=$(awk -F "," 'NR==1{print $3}' $sta.temp)
    year2=$(tail -n 1 $sta.temp | awk -F "," '{print $3}')

        mean=$(awk -F "," '{ sum+=$NF} END {print sum/NR}' $sta.temp)
        echo  $sta,$mean,$year1-$year2,$mon_std,$year_std >> Fiveyear.rsds
    fi
done

}
# sel obs more than 10 years
#5year

#cat Fiveyear.rsds

function merge_yearmean_sta()
{
line2=$(cat Fiveyear.rsds | wc -l)

for i in $(seq -s ' ' 1 $line2)
do
    station=$(awk -F "," 'NR=='$i'{print $1}' Fiveyear.rsds)
    #echo $station
    awk -F "," 'NR=='$i'{printf "%s,",$0}' Fiveyear.rsds
    awk '$1=='$station'' station.south.africa
    echo ""
done
}

#merge_yearmean_sta
merge_yearmean_sta > GEBA_5year_Southern_Africa.temp
#
rsds.southern.africa.gt.5year.1970-1999.csv
