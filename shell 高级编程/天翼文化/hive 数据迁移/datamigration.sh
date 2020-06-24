#!/usr/bin/env bash
    
# -*- coding: utf-8 -*-
# @Time    : 2020/2/27 16:16
# @Author  : wtong
# @Site    :
# @File    : HIVE 数据迁移脚本
# @Software:
#
#function f_exec_hivesql()
#{
#    hivesql=$1;
#    exec_sql=`hive -e '$hivesql'`
#    echo $exec_sql
#}
#
pwd

#f_exec_hivesql $1



#function f_exec_datamigration()
#{
#    exec_datamigration=`hive <<EOF
#    use jyfx;
#    $1;
#
#     `
#}