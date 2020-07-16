#!/usr/bin/env bash

# -*- coding: utf-8 -*-
# @Time    : 2020/7/16 13:19
# @Author  : Administrator
# @Site    : 为hive 中表增加未来7天的分区
# @File    : ${PACKAGE_NAME} ${NAME}
# @Software: IntelliJ IDEA


#定义最近8天 格式：yyyymmdd
currDate=`date +%Y%m%d`
currDate1=`date +%Y%m%d -d "+1 day"`
currDate2=`date +%Y%m%d -d "+2 day"`
currDate3=`date +%Y%m%d -d "+3 day"`
currDate4=`date +%Y%m%d -d "+4 day"`
currDate5=`date +%Y%m%d -d "+5 day"`
currDate6=`date +%Y%m%d -d "+6 day"`
currDate7=`date +%Y%m%d -d "+7 day"`
Datelist=($currDate $currDate1 $currDate2 $currDate3 $currDate4 $currDate5 $currDate6 $currDate7 )

#定义需要建分区的表
#需要指定表名；和分区路径
tablename=('ods.ods_kafka_topic_log_file' 'ods_test.ods_kafka_topic_log_file')
hdfsurl='hdfs://tyvrdwcmnnprod01.189read.com:8020'
hdfspath=('/user/hive/warehouse/ods/vrlog/ods_vrlog_topic_log_file/' '/user/hive/warehouse/ods_test/vrlog/ods_vrlog_topic_log_file/')
count=0
#echo ${tablename[0]}

function CreateHivePar(){
    `hive -e 'alter table '$1' add IF NOT EXISTS partition(dt='\'${2}\'') location '\'${hdfsurl}${3}dt=${2}/\'`
}

for d in ${Datelist[@]}
do
    CreateHivePar ${tablename[0]} ${d} ${hdfspath[0]}
    if [ $? -eq 0 ];
    then echo  `date` '>>>>> TABLE [' ${tablename[0]}  '] ADD PARTITION ['${d}'] SUCCUSS'
    elif [ $?-ne 0 ];
    then echo  `date` '>>>>> TABLE [' ${tablename[0]}  '] ADD PARTITION ['${d}'] FAILD'
    fi

    CreateHivePar ${tablename[1]} ${d} ${hdfspath[1]}
    if [ $? -eq 0 ];
    then echo  `date` '>>>>> TABLE [' ${tablename[1]}  '] ADD PARTITION ['${d}'] SUCCUSS'
    elif [ $?-ne 0 ];
    then echo  `date` '>>>>> TABLE [' ${tablename[1]}  '] ADD PARTITION ['${d}'] FAILD'
    fi

done


