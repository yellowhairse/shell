#!/usr/bin/env bash

# -*- coding: utf-8 -*-
# @Time    : 2020/7/16 13:19
# @Author  : wangtong
# @Site    : 为hive 中表增加未来7天的分区
# @File    :
# @Software:

#定义参数值
#需要指定表名，分区路径的顺序对应关系；需要建分区的表的个数

tablename=('ods.ods_kafka_topic_log_file' 'ods_test.ods_kafka_topic_log_file')
hdfsurl='hdfs://tyvrdwcmnnprod01.189read.com:8020'
hdfspath=('/user/hive/warehouse/ods/vrlog/ods_vrlog_topic_log_file/' '/user/hive/warehouse/ods_test/vrlog/ods_vrlog_topic_log_file/')

#返回8天的数组 格式：yyyymmdd
function Getdatelist(){
    Datelist=()
    currDate=`date +%Y%m%d`
    for count in {0..7}
    do
    Datelist[$count]=`date +%Y%m%d -d "+${count} day"`
    done
    echo ${Datelist[@]}
}

#建HIVE分区语句封装
function CreateHivePar(){
    #`hive -e 'alter table '$1' add IF NOT EXISTS partition(dt='\'${2}\'') location '\'${hdfsurl}${3}dt=${2}/\'`
    echo 'alter table '$1' add IF NOT EXISTS partition(dt='\'${2}\'') location '\'${hdfsurl}${3}dt=${2}/\'
}

#根据数组中时间范围建HIVE分区
function CreatePartitionMore(){
for d in `Getdatelist`
do
    CreateHivePar ${tablename[$1]} ${d} ${hdfspath[$1]}
    if [ $? -eq 0 ];
    then echo  `date` '>>>>> TABLE [' ${tablename[$1]}  '] ADD PARTITION ['${d}'] SUCCUSS'
    elif [ $?-ne 0 ];
    then echo  `date` '>>>>> TABLE [' ${tablename[$1]}  '] ADD PARTITION ['${d}'] FAILD'
    fi
done
}

#0..1 代表2张表；添加表后要做调整
for i in {0..1}
do
    CreatePartitionMore ${i}
done


