#!/usr/bin/env bash

#!/usr/bin/env bash
# 该脚本主要用于处理重复作业执行以及作业重试
# date：2019-08-09

arr=(${1//:/ })
jobName=${arr[0]}
flowName=${arr[1]}
execId=${arr[2]}
projectId=${arr[3]}
dt=${2%.*}
freq=$3
retry=$4
jobType=$5

execTime=`date +"%Y-%m-%d %H:%M:%S" -d "${dt//T/ }"`
jobTime=`date +"%Y%m%d%H%M%S" -d "${execTime}"`
mod=""
dayOrHour=""
scriptName=""

# 参数检查
usage="Usage: sh exec_*.sh job_name dt freq retry"
if [ $# -ne 5 ]; then
  echo ======== $usage ========
  exit 1
fi

# 根据作业类型初始化指定执行的脚本
case $jobType in
  "crt")
  scriptName="crt_partition_job.sh"
  ;;
  "proc")
  scriptName="proc_job.sh"
  ;;
  "ktr")
  scriptName="ktr_job.sh"
  ;;
  "kjb")
  scriptName="kjb_job.sh"
  ;;
  "flg")
  scriptName="check_flag_file.sh"
  ;;
  "check")
  scriptName="check_hour_job.sh"
  ;;
  "ftp")
  scriptName="get_FTP_shixun.sh"
  ;;
esac

# 根据作业类型（天、小时）初始化参数
case $freq in
  "H")
  jobTime=`date +"%Y%m%d%H%M%S" -d "${execTime} 2 hour ago"`
  mod="%Y-%m-%d %H"
  dayOrHour="hour"
  ;;
  "H2")
  jobTime=`date +"%Y%m%d%H%M%S" -d "${execTime} 2 hour ago"`
  mod="%Y-%m-%d %H"
  dayOrHour="hour"
  ;;
  "D")
  jobTime=`date +"%Y%m%d%H%M%S" -d "${execTime} 1 day ago"`
  mod="%Y-%m-%d"
  dayOrHour="day"
  ;;
esac

echo ======== jobName: $jobName jobTime: $jobTime jobType: $jobType ========
# 判断是否为重新执行
if [ "$retry" -eq 1 ];then
  sh /gpfsetl/etldata/shell_file/$scriptName $jobName $jobTime $freq
  result=$?
  if [ $result -eq 0 ];then
    echo "======== sh /gpfsetl/etldata/shell_file/$scriptName $jobName $jobTime $freq Success! ========"
  	exit $result
  else
	echo "======== sh /gpfsetl/etldata/shell_file/$scriptName $jobName $jobTime $freq Failed! ========"
	exit $result
  fi

fi

# 执行作业
function execjob(){

mysql -uazkaban -h10.140.23.170 -pAzkaban@123 -e "update azkaban.job_exec_status set flow_name='$flowName',exec_id='$execId',project_id='$projectId',job_time='$jobTime',exec_time='$execTi
me',running=1 where job_name='$jobName';"
sh /gpfsetl/etldata/shell_file/$scriptName $jobName $jobTime $freq
if [ $? -eq 0 ]; then
  mysql -uazkaban -h10.140.23.170 -pAzkaban@123 -e "update azkaban.job_exec_status set exec_status=1,running=0 where job_name='$jobName';"
  echo ======== 作业已被成功执行 ========
else
  mysql -uazkaban -h10.140.23.170 -pAzkaban@123 -e "update azkaban.job_exec_status set exec_status=0,running=0 where job_name='$jobName';"
  echo ======== 作业执行失败 =========
  exit 1
fi
}

#获取上次job执行状态
last_status=`mysql -uazkaban -h10.140.23.170 -pAzkaban@123 -e "select job_time,exec_status,running from azkaban.job_exec_status where job_name='$jobName'";`
if [ -n "$last_status" ]; then
  args=($last_status)
  job_time=${args[3]}
  exec_status=${args[4]}
  running=${args[5]}
  echo ========last_job_time: $job_time exec_status: $exec_status running: $running ========
  #判断是否正在执行
  if [ "$running" -eq 1 ]; then
    echo ========= running: $running ========
    exit 1
  else
    lastTime=`date +"$mod" -d "${job_time:0:8} ${job_time:8:2}:${job_time:10:2}:${job_time:12:2}"`
    currentTime=`date +"$mod" -d "${jobTime:0:8} ${jobTime:8:2}:${jobTime:10:2}:${jobTime:12:2}"`
    newTime=`date +"$mod" -d "$currentTime 1 $dayOrHour ago"`

    #判断作业是否被成功执行
    if [ "$exec_status" -eq 1 ];then
      if [ "$currentTime" = "$lastTime" ]; then
        echo ========= 单位时间内该作业已经被执行过 ========
      elif [ "$newTime" = "$lastTime" ]; then
        execjob
      else
        echo ======== 两次作业执行相隔时间错误 =========
        exit 1
      fi
    else
      if [ "$currentTime" = "$lastTime" ];then
        execjob
      else
        echo ========= 上次作业执行失败 =========
        exit 1
      fi
    fi
  fi
else
  #执行插入将运行状态改为正在运行
  echo ======== 首次执行该作业 ========
  mysql -uazkaban -h10.140.23.170 -pAzkaban@123 -e "insert into azkaban.job_exec_status (job_name,flow_name,exec_id,project_id,exec_time,job_time,running) values ('$jobName','$flowName','
$execId','$projectId','$execTime','$jobTime',1);"
  #执行job任务
  sh /gpfsetl/etldata/shell_file/$scriptName $jobName $jobTime $freq
  if [ $? -eq 0 ]; then
    echo ======== 首次执行成功: $? ========
    mysql -uazkaban -h10.140.23.170 -pAzkaban@123 -e "update azkaban.job_exec_status set exec_status=1,running=0 where job_name='$jobName';"
  else
    echo ======== 首次执行失败: $? ========
    mysql -uazkaban -h10.140.23.170 -pAzkaban@123 -e "update azkaban.job_exec_status set exec_status=0,running=0 where job_name='$jobName';"
    exit 1
  fi
fi
