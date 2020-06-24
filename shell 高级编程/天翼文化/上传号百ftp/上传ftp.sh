#!/usr/bin/env bash


#To get YYYY-MM
yearMon=`date -d "yesterday" +%Y-%m`

#To get day
day=`date +%d`

#To get last day
lastday=`date -d "yesterday" +%d`

#get the system Date YYYYMMDD
        currDate=`date +%Y%m%d`

#To get last day YYYYMMDD
        lastDate=`date -d "yesterday" +%Y-%m-%d`

cd /dwdata001/DataFiles/workdir/everyday/visitHis
returnStatus=`echo $?`

if [ $returnStatus -ne 0 ];then
        echo "The /dwdata001/DataFiles/workdir/everyday/visitHis doesn't exist, pls check the folder"
        exit 1
fi

ftp -niv <<- EOF
open 101.89.132.222 10081
user hb_yuedu Th3wr&Awv!
bin
put tyyd_userIdlogreceiver.2020-04-29.txtpw
bye
EOF
