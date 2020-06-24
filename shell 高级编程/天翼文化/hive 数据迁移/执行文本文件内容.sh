#!/usr/bin/env bash
    
# -*- coding: utf-8 -*-
# @Time    : 2020/6/23 20:32
# @Author  : Administrator
# @Site    : 
# @File    : ${PACKAGE_NAME} ${NAME} 
# @Software: IntelliJ IDEA


#拼接用于执行的hivesql

function get_hivesql()
{
    tablename=$1;
    exec_sql="hive -e ""\"set hive.exec.stagingdir=/tmp/hive-staging;select "\'$tablename\'",count(1) from jyfx."$tablename";\""">>/ZooLeader/JobFile/shell/jyfxalltables.log"
    echo $exec_sql
}


filepath='/ZooLeader/JobFile/shell/all_tables/001.txt'

for line in `cat  $filepath`
do
    get_hivesql $line
done


