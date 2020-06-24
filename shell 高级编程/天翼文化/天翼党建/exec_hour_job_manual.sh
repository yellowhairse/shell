#!/usr/bin/env bash

#!/usr/bin/env bash
# 该脚本主要用于手动重跑小时作业，起始时间要往前退2小时，如跑20191106号的小时作业：sh exec_hour_job_manual.sh 2019110602 2019110702
# date：2019-11-06

source /etc/profile

first=$1
second=$2
while [ "$first" != "$second" ]
do

let first=`date -d "1 hour ${first:0:8} ${first:8:2}" +%Y%m%d%H`
timeStr=`echo ${first:0:4}-${first:4:2}-${first:6:2} ${first:8:2}:00:00`

sh /gpfsetl/etldata/shell_file/exec_job.sh MID_ZQ4_NG_FLOW_GE_H "$timeStr" H2 1 crt

sh /gpfsetl/etldata/shell_file/exec_job.sh TR_ZQ4_NG_GE_H "$timeStr" H 1 crt

sh /gpfsetl/etldata/shell_file/exec_job.sh MID_ZQ4_NG_ORGN_GE_H "$timeStr" H2 1 crt

sh /gpfsetl/etldata/shell_file/exec_job.sh LOAD_TR_ZQ4_NG_GE_H.ktr "$timeStr" H 1 ktr

sh /gpfsetl/etldata/shell_file/exec_job.sh DEAL_MID_ZQ4_NG_ORGN_GE_H.ktr "$timeStr" H 1 ktr

sh /gpfsetl/etldata/shell_file/exec_job.sh DEAL_MID_ZQ4_NG_FLOW_GE_H.ktr "$timeStr" H 1 ktr

done


sh exec_hour_job_manual.sh 2020042914 2020042919 >exec_hour_job_manual.log  2>&1

