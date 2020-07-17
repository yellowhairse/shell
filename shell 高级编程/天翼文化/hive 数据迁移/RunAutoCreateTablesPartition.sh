#!/usr/bin/env bash
    
# -*- coding: utf-8 -*-
# @Time    : 2020/7/17 10:35
# @Author  : Administrator
# @Site    : 运行建HIVE分区脚本
# @File    : ${PACKAGE_NAME} ${NAME} 
# @Software: IntelliJ IDEA

#定义路径和脚本
Scriptpath='/home/bigdata/hive/Script_shell/'
Script=${Scriptpath}'AutoCreateTablesPartition.sh'

#执行脚本
nohup sh ${Script} >/home/bigdata/hive/log/AutoCreateTablesPartition.log &

