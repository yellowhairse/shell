#!/usr/bin/env bash

# -*- coding: utf-8 -*-
# @Time    : 2020/2/27 16:16
# @Author  : wtong
# @Site    : ${SITE}
# @File    : ${NAME}.py
# @Software: IntelliJ IDEA


filename=/c/test/11/22.txt

echo hello; echo there

if [ -e "$filename" ]; then # 注意:"if"和"then"需要分隔
# 为啥?
echo "File $filename exists."; cp $filename $filename.bak
else
echo "File $filename not found."; touch $filename
fi; echo "File test complete."

