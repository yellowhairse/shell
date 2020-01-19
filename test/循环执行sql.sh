#!/usr/bin/env bash

#!/usr/bin/env bash

##@resource_reference{"odps_config.txt"}
##@resource_reference{"odps_base_util.sh"}
##@resource_reference{"mx_zrryh_cxtj.sh"}

#. ./odps_base_util.sh


Rdscmd=`getDrdsConnnection "DPZS"`
Adscmd=`getDrdsConnnection "SCCX"`

function f_insert_rdsinfos()
{
  v_ads_exce_sql="/*+engine=MPP*/
                select A.rkje,a.rkrs,B.tkje,b.tkrs
                from
                (
                select coalesce(sum(mx.sjje),0) as rkje,count(distinct mx.nsrdah) as rkrs
                from f_rt_zs_sp_mx_qccx mx
                inner join f_rt_zs_sp_qccx sp on mx.spxh = sp.spxh and mx.nsrdah = sp.nsrdah
                left join f_rt_zs_bhz_spmx_qccx hz on mx.spmxxh = hz.yspmxxh and hz.yxbz = 'Y'
                        and sp.pzzl_dm in ('000001032','000001031') and sp.nsrdah = hz.ynsrdah
                left join f_rt_zs_sp_qccx sp_1 on hz.spxh = sp_1.spxh and sp_1.spzt_dm = '05'
                where mx.zspm_dm = '101061200'
                and mx.skzl_dm not in ('20','50')
                and mx.yzpzzl_dm = 'BDA0611136'
                and mx.skssqq >= '2019-01-01'
                and mx.skssqz <= '2019-12-31'
                and sp.pzzl_dm in ('000001032','000001031','000001011','000006010')
                and sp.hzjksbz = 'N'
                and ((sp.pzzl_dm in ('000001011','000006010') and sp.spzt_dm = '05' and sp.rkrq >= date(now()))
                        or (sp_1.spzt_dm = '05' and sp_1.rkrq >= date(now()))))  a
                join
                (
                SELECT coalesce(sum(mx.tkje),0) as tkje,count(distinct mx.nsrdah) as tkrs
                from f_rt_zs_srths_qccx srths
                inner join f_rt_zs_srths_mx_qccx mx on srths.srthsxh = mx.srthsxh and srths.nsrdah = mx.nsrdah
                where srths.pzzl_dm = '000007010'
                and srths.spzt_dm = '10'
                and mx.skzl_dm not in ('20','50')
                and mx.zspm_dm = '101061200'
                and mx.skssqq >= '2019-01-01'
                and mx.skssqz <= '2019-12-31'
                and srths.xhrq_1 >= date(now()))  b on 1 = 1;"

  v_sqlinfo=`${Adscmd} -e "${v_ads_exce_sql}"`

  v_list_column=(${v_sqlinfo// /})

  ${Rdscmd} -e "REPLACE INTO sm_ndhs_trkqk_rt (TJRQ, NDHSRKJE, NDHSRKRS, NDHSTSJE, NDHSTSRS, CQSJ) VALUES (""DATE_FORMAT(now(),'%Y%m%d'),${v_list_column[0]},${v_list_column[1]},${v_list_column[2]},${v_list_column[3]},CURRENT_TIMESTAMP);"


}

function f_loopexec()
{
    v_start=0
    v_end=1
    v_errcnt=0
    v_errmsg=10
    while [ $v_start -lt $v_end -a $v_errcnt -lt $v_errmsg ]
    do
    	v_nowtime=`date +"%Y-%m-%d %H:%M:%S"`
        f_insert_rdsinfos
        # 任务失败后，重启10次
        if [ $? -ne 0 ] ; then
            v_errcnt=`expr $v_errcnt + 1`
            echo "本次任务执行时分： "$v_nowtime
            echo "任务报错，循环10次后退出任务（当前为：$v_errcnt 次）"
            sleep 1m
            if [ $v_errcnt == $v_errmsg ]; then
            	echo "任务异常，本次任务同步结束"
         #任务跳出所有循环
                break 2
            fi

        else
            echo "===任务成功==="
            v_start=`expr $v_start + 1`
            echo "本次任务执行时分： "$v_nowtime
            sleep 1m
        fi
    done
}



function f_getflag()
{
#记录时间的起始标志位
v_flag=0
#当前时分
v_nowtime=`date +"%H%M"`
#定义时间区间标志位
v_defitime=(0,0000,0600 1,0600,1115 2,1115,1800 3,1800,2400)

for idx in ${v_defitime[@]};
do
    v_test=(${idx})
    v_range=(`echo $v_test | tr ',' ' '`)
    if [ ${v_nowtime} -ge ${v_range[1]} -a ${v_nowtime} -lt ${v_range[2]} ];
    then
    	v_flag=${v_range[0]}
    fi
done

echo $v_flag
}


v_startidx=`f_getflag`
v_endtidx=`f_getflag`

while [ $v_startidx == $v_endtidx ];
do
#执行循环插入sql
	f_loopexec
#获取最新的时间状态
	v_endtidx=`f_getflag`
done








