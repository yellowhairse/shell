#!/usr/bin/env bash

#********************************************************************#
##author:yinyl
##describe:
##create time:2019-11-17 10:00:00
#********************************************************************#
##@resource_reference{"odps_config.txt"}
##@resource_reference{"odps_base_util.sh"}

mysql -hdrdshbga8qzszt6opublic.drds.aliyuncs.com -P3306 -uits_kf01_workflow -pServyouITS -Dkf01_workflow -A -c -s -e "select 1"

#!/bin/bash
. ./odps_base_util.sh
odpscmd=`getLhcOdpscmd`
rdscmd=`getRdsConnnection 'PZK'`
adscmd=`getAdsConnnection 'SCCX'`

echo ${rdscmd}

#入参 target_tab_name source_tab_name source_tab_number error_number runCount
function qccx_kbsql_zl()
{
    #读取上次执行最大修改日期及允许最大错误次数
	v_result=`$rdscmd -e "SELECT concat('\'',data_start_time,'\'|',max_err_number,'|',coalesce(err_msg,'')) from cs_qckb_pzb where target_tab_name = '$1' and source_tab_name = '$2' and source_tab_number = $3 and active_flag = 1;"`
    if [ $? -ne 0 ] ; then
    	echo "rds读取报错，运行结束"
    	exit -1
    fi
	d_dataStartTime=`echo $v_result |awk -F "|" '{print $1}'`
    v_maxErrorNumber=`echo $v_result |awk -F "|" '{print $2}'`
    if [ $v_runCount -eq 1 ] ; then
		v_errMsg=''
    else
    	v_errMsg=`echo $v_result |awk -F "|" '{print $3}'`
    fi

    #插入数据
	v_sql=`$rdscmd -e "SELECT concat('/*+queryMaxRunTime=100s*/insert into ',target_tab_name,' ',sql_string) from cs_qckb_pzb where target_tab_name = '$1' and source_tab_name = '$2' and source_tab_number = $3 and active_flag = 1;"`
    v_sql=`eval echo $v_sql`
    #echo $v_sql
    echo "${v_sql}"| ${adscmd}

    if [ $? -ne 0 ] ; then
      	#执行错误，错误次数+1
      	v_errorNumber=`expr ${4} + 1`
        v_errMsg=$v_errMsg' 插入目标表报错'
        $rdscmd -e "update cs_qckb_pzb set err_msg = '$v_errMsg' where target_tab_name = '$1' and source_tab_name = '$2' and source_tab_number = $3 and active_flag = 1;"
    else
      	v_errorNumber=${4}
        v_sql=`$rdscmd -e "SELECT SQL2_STRING FROM cs_qckb_pzb where target_tab_name = '$1' and source_tab_name = '$2' and source_tab_number = $3 and active_flag = 1;"`
        v_sql=`eval echo $v_sql`
        #获取本次执行最大修改日期
    	d_dataStartTimeNew=`echo "${v_sql}"| ${adscmd}`
        d_runStartTime_1=`date +"%Y-%m-%d %H:%M:%S"`
      	#执行正确，记录日志
        $rdscmd -e "update cs_qckb_pzb set previous_data_start_time=data_start_time,previous_data_end_time=data_end_time,previous_run_start_time=run_start_time,previous_run_end_time=run_end_time,
        data_start_time = '$d_dataStartTimeNew',data_end_time = now(),run_start_time = '$d_runStartTime_1',run_end_time = now(),err_msg = '$v_errMsg'
        where target_tab_name = '$1' and source_tab_name = '$2' and source_tab_number = $3 and active_flag = 1;"
    fi
	#echo $v_errorNumber
}

#定义错误次数
v_errorNum1=0;
v_maxErrorNumber1=0;
v_errorNum2=0;
v_maxErrorNumber2=0;
#v_errorNum3=0;
#v_errorNum4=0;
#v_errorNum5=0;
#v_errorNum6=0;
#v_errorNum7=0;
#v_errorNum8=0;
#v_errorNum9=0;
#v_errorNum10=0;

#运行次数
v_runCount=1;

v_runTime=`date +%H%M`
#判断任务开始执行时间 00：00-08：00 8：00跳出 08：00-16：00 16：00跳出 16：00-23：00 23：00跳出
if [ $v_runTime -lt 0800 ] ; then
	v_breakTime=0751
elif [ $v_runTime -lt 1600 ] ; then
	v_breakTime=1551
elif [ $v_runTime -lt 2300 ] ; then
	v_breakTime=2300
else
	echo "时间超过23：00，不予执行"
	exit 0
fi
#echo $v_breakTime

#循环执行
while [ $v_runTime -lt $v_breakTime ]; do
	d_runStartTime=`date +%Y%m%d%H%M%S`
    #串行开始
	#报错超过最大可失败次数,跳过该表，允许最大错误次数当是-1时不限制错误次数
  	if [ $v_maxErrorNumber1 -eq -1 -o $v_errorNum1 -le $v_maxErrorNumber1 ] ; then
  		qccx_kbsql_zl 'f_rt_zs_sp_mx' 'f_rt_zs_sp_qccx' 1 $v_errorNum1 $v_runCount
  		v_errorNum1=$v_errorNumber
        v_maxErrorNumber1=$v_maxErrorNumber
  	fi
  	if [ $v_maxErrorNumber2 -eq -1 -o $v_errorNum2 -le $v_maxErrorNumber2 ] ; then
  		qccx_kbsql_zl 'f_rt_zs_sp_mx' 'f_rt_zs_sp_mx_qccx' 1 $v_errorNum2 $v_runCount
  		v_errorNum2=$v_errorNumber
        v_maxErrorNumber2=$v_maxErrorNumber
  	fi
    #串行结束
	d_runEndTime=`date +%Y%m%d%H%M%S`

	#间间隔为10min,如果执行时间为8min,则休眠时间为2min,如执行时间超过10min,则直接执行下一步
    d_runInterval=`expr $(( $d_runEndTime - $d_runStartTime ))`
    #echo $d_runInterval
    #d_sleepTime=`echo "scale=2;600-$d_runInterval" | bc | awk '{printf "%.2f",$0}'`
    d_sleepTime=`expr 600 - $d_runInterval`
    echo "执行第${v_runCount}次,执行时间:$d_runInterval秒,休眠时间：${d_sleepTime}秒 "
    if [ $d_sleepTime -gt 0 ] ; then
   	 	sleep ${d_sleepTime}
    fi

	v_runCount=$(($v_runCount + 1))
    v_runTime=`date +%H%M`

done

echo "运行结束，结束时间："$v_runTime