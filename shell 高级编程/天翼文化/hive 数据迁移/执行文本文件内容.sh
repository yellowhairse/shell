#!/usr/bin/env bash
    
# -*- coding: utf-8 -*-
# @Time    : 2020/6/23 20:32
# @Author  : Administrator
# @Site    : 
# @File    : ${PACKAGE_NAME} ${NAME} 
# @Software: IntelliJ IDEA


#拼接用于执行的hivesql
c
function get_hivesql()
{
    tablename=$1;
    	exec_sql="insert into table jyfx.all_tables select "\'$tablename\'",count(1) from jyfx."$tablename";"
    echo $exec_sql
}

filepath='/ZooLeader/JobFile/shell/all_tables/001.txt'

hivehint="set hive.exec.stagingdir=/tmp/hive-staging;"
echo '>>>>>>>>this is hivehint: '$hivehint

/software/hive/bin/hive -e "$hivehint"

for line in `cat $filepath`
do
    sql=`get_hivesql $line`
    echo '>>>>>>>>this is hivesql:'$sql
    /software/hive/bin/hive -e "$sql"
done



