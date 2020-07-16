#!/usr/bin/env bash
    
# -*- coding: utf-8 -*-
# @Time    : 2020/6/30 9:51
# @Author  : Administrator
# @Site    : 
# @File    : ${PACKAGE_NAME} ${NAME} 
# @Software: IntelliJ IDEA

scheduleDay=$1

#To get day
day=`date +%d`

#To get last day
lastdate=`echo $scheduleDay | cut -c 1-8`

newDate=`date -d "${lastdate} +1 days" +"%Y%m%d"`
currDate=`echo $newDate | cut -c 1-8`
#uploadPeriod="D"

fileName1="I_YD_5GAPPDEVE_PROVINCE_${lastdate}_${currDate}_001.CSV"
fileName2="I_YD_5GAPPDEVE_CITY_${lastdate}_${currDate}_001.CSV"
fileName3="I_YD_5GAPPDEVE_DAY_${lastdate}_${currDate}_001.CSV"
fileName4="I_YD_5GAPPDEVE_24HOUR_${lastdate}_${currDate}_001.CSV"
#fileName5="I_YD_5GAPPDEVE_930_${lastdate}_${currDate}_001.CSV"
#prefixName=`echo ${fileName1} | awk -F '.' '{print $1}'`

cd /dwdata002/ExpDir/OUT_VR/OUT_VR_REPORT_D

if [[ -f ${fileName1} ]] && [[ -f ${fileName2} ]] && [[ -f ${fileName3} ]] && [[ -f ${fileName4} ]] ;
then
		ftp -niv <<- EOF
		open 132.129.32.11 11082
        user hb_yuedu X8sT9IzmoPzMaT
		bin
		prompt off

		cd /5GREPORT

		put ${fileName1}
	 	put ${fileName2}
        put ${fileName3}
        put ${fileName4}
		bye
		EOF
fi

returnStatus=`echo $?`

if [ $returnStatus -ne 0 ];then
        echo "PTP files accur errors, pls check"
        exit 1
fi

if [[ -f ${fileName1} ]] && [[ -f ${fileName2} ]] && [[ -f ${fileName3} ]] && [[ -f ${fileName4} ]]  ;
then
		ftp -niv <<- EOF
		open 132.129.32.11 11082
        user hb_yuedu X8sT9IzmoPzMaT
		bin
		prompt off

		cd /5GREPORT

		put ${fileName1}
	 	put ${fileName2}
        put ${fileName3}
        put ${fileName4}
		bye
		EOF
fi

returnStatus=`echo $?`

if [ $returnStatus -ne 0 ];then
        echo "PTP files accur errors, pls check"
        exit 1
fi
