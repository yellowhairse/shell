#!/usr/bin/env bash


date_str=20200531
date_all="'$date_str'000000'"

echo $date_all


#exec_procName="PROC_MID_PF_SPOA_RESTITUTE"

#call PROC_MID_PF_SPOA_RESTITUTE('2020053l000000');

#echo "call ${exec_procName}('${date_all}');"


#result=`sqlplus -s jyfx/'Jyfx$67yyd' <<eof
#set heading off
#set heads on
#set echo on
#set wrap on
#set timing on
#-- allow blank line
#SET SQLBLANKLINES ON
#-- excute result
#set feed on
#
#call PROC_MID_PF_SPOA_RESTITUTE('20200531000000');
#
#exit;
#eof
#`
#echo $result
