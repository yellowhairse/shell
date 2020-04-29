#!/bin/bash


#logdir=${SRC_PATH}${V_GLOBAL_DATE_STR}
logdir="/c/Users/Administrator/Desktop/22/1"
maxnum=36
nownum=0
execmsg=0
nowday=$(date +%Y-%m-%d-%H:%M:%S)

function f_touchflag()
{
    if [ -d "$logdir" ]; then
        echo "dir $logdir exists.";
        touch $logdir/ALL_COMPLETE.FLG
        echo "ALL_COMPLETE.FLG create success."
        execmsg=0
    else
        execmsg=1
    fi;
}


while [ $nownum -le $maxnum ];do
    f_touchflag
    if [ $execmsg -eq 1 ];then
        echo $nowday 'Directory not created,Sleep 10m'
        sleep 10m
        nownum=$(($nownum+1))

    elif [ $execmsg -eq 0 ];then
        break
    fi;done


