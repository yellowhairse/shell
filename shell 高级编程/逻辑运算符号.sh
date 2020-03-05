#!/usr/bin/env bash

# -*- coding: utf-8 -*-
# @Time    : 2020/2/27 16:01
# @Author  : wtong
# @Site    : ${SITE}
# @File    : ${NAME}.py
# @Software: IntelliJ IDEA


#转义符号
echo "The # here does not begin a comment."
echo 'The # here does not begin a comment.'
echo The \# here does not begin a comment.
echo The # 这里开始一个注释

#系统参数路径
echo ${JAVA_HOME#*:}  # 参数替换,不是一个注释
# 二进制转换
echo $(( 2#101011 )) # 数制转换,不是一个注释

-e filename 如果 filename存在，则为真
-d filename 如果 filename为目录，则为真
-f filename 如果 filename为常规文件，则为真
-L filename 如果 filename为符号链接，则为真
-r filename 如果 filename可读，则为真
-w filename 如果 filename可写，则为真
-x filename 如果 filename可执行，则为真
-s filename 如果文件长度不为0，则为真
-h filename 如果文件是软链接，则为真
filename1 -nt filename2 如果 filename1比 filename2新，则为真。
filename1 -ot filename2 如果 filename1比 filename2旧，则为真。
-eq 等于
-ne 不等于
-gt 大于
-ge 大于等于
-lt 小于
-le 小于等于

# 逻辑运算

while [ 1 = 1 ];do
    echo "Is it morning? Please answer yes or no."
    read YES_OR_NO
    case "$YES_OR_NO" in
    yes|y|Yes|YES)
      echo "Good Morning!";;
    [nN]*)
      echo "Good Afternoon!";;
    *)
      echo "Sorry, $YES_OR_NO not recognized. Enter yes or no."
      exit 2;;
    esac
    #exit 0
done

echo $?

# exit 跳出
#0表示成功（Zero - Success）
#
#非0表示失败（Non-Zero  - Failure）
#
#2表示用法不当（Incorrect Usage）
#
#127表示命令没有找到（Command Not Found）
#
#126表示不是可执行的（Not an executable）
#
#>=128 信号产生