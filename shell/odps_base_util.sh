##@resource_reference{"odps_config.txt"}
#!/bin
##author:fanghl  
##describe:
##create time:2018-08-27 15:00:00
##last_update_time :2018-10-18
##updateor ： zxk


#------------------------------------------------------------------------------------------------------------#
#function_name:getProperty
#功能：从配置文件中获取属性
#参数：$1:属性名称
#返回值：属性值
#使用示例  	echo -n $(getProperty 'ODPSCMD_PATH')" -u "$(getProperty 'ACCESS_ID')" -p "${ACCESS_KEY#$SECRET_KEY}" --project="$(getProperty 'CURRENT_PROJECT_NAME')" --endpoint="$(getProperty 'ODPS_SERVER')
function getProperty()
{
flag="false"
for line in `cat odps_config.txt`
do
    if [ ${line%%=*} == $1 ]
    then
         echo ${line#*=}
         flag="true"
         break
    fi
done
if [ $flag == "false" ]
then
	echo "未找到属性值"
fi
}



#------------------------------------------------------------------------------------------------------------#
#function_name:getPassWDord
#功能：获取密码信息
#参数：属性名
#返回值：解密后的密码信息
#使用示例 echo $(getPassWDord "DRDS_PASSWORD_HS")
function getPassWDord()
{
    PASSWORD=`getProperty "$1"`
    PWD=`echo $PASSWORD | base64 -i -d`
    SECRET_KEY=$(getProperty 'SECRET_KEY')
    echo -n ${PWD#$SECRET_KEY}
}


#------------------------------------------------------------------------------------------------------------#
#function_name:getDrdsConnnection
#功能：获取DRDS库连接信息
#参数：连接的DRDS库后缀，如：征收中心 ZS；申报中心 SB
#返回值：DRDS核算库连接信息字符串
#使用示例 DRDS=`getDrdsConnnection "ZS"`
function getDrdsConnnection()
{
    echo -n "mysql -h"$(getProperty "DRDS_HOSTNAME_"${1})" -P"$(getProperty "DRDS_PORT_"${1})" -u"$(getProperty "DRDS_USERNAME_"${1})" -p"`getPassWDord "DRDS_PASSWORD"_${1}`" -D"$(getProperty "DRDS_DBNAME_"${1})" -A -c -s"
}

#------------------------------------------------------------------------------------------------------------#
#function_name:getAdsConnnection
#功能：获取ADS库连接信息
#参数：连接的ADS库后缀，如：SCCX
#返回值：DRDS核算库连接信息字符串
#使用示例 DRDS=`getAdsConnnection "SCCX"`
function getAdsConnnection()
{
    echo -n "mysql -h"$(getProperty "ADS_HOSTNAME_"${1})" -P"$(getProperty "ADS_PORT_"${1})" -u"$(getProperty "ADS_USERNAME_"${1})" -p"`getPassWDord "ADS_PASSWORD"_${1}`" -D"$(getProperty "ADS_DBNAME_"${1})" -A -c -s"
}



#------------------------------------------------------------------------------------------------------------#
#function_name:getRdsConnnection
#功能：获取RDS库连接信息
#参数：连接的DRDS库后缀，如：配置库 PZK；大屏 DPZS
#返回值：DRDS核算库连接信息字符串
#使用示例 DRDS=`getRdsConnnection "PZK"`
function getRdsConnnection()
{
    echo -n "mysql -h"$(getProperty "RDS_HOSTNAME_"${1})" -P"$(getProperty "RDS_PORT_"${1})" -u"$(getProperty "RDS_USERNAME_"${1})" -p"`getPassWDord "RDS_PASSWORD"_${1}`" -D"$(getProperty "RDS_DBNAME_"${1})" -A -c -s"
}

#------------------------------------------------------------------------------------------------------------#
#function_name: getLhcConfig
#功能：获取莲花池客户端变量
#返回值：
#示例：getLhcConfig 目录名
function getLhcConfig()
{
	if [ ! -f /tmp/odps/cp_conf ]
	then
		mkdir -p /tmp/odps/cp_conf
	else
		echo "目录已存在"
	fi

	#配置莲花池客户端文件
	echo "
	project_name=$(getProperty 'CURRENT_PROJECT_NAME')
	access_id=$(getProperty 'ACCESS_ID_LHC')
	access_key=$(getPassWDord 'ACCESS_KEY_LHC')
	end_point=`getProperty "end_point_LHC"`
	tunnel_endpoint=`getProperty "tunnel_endpoint_LHC"`
	log_view_host=`getProperty "log_view_host_LHC"`
	" > /tmp/odps/cp_conf/${1}_lhc.conf

    echo /tmp/odps/cp_conf/${1}_lhc.conf
}

#------------------------------------------------------------------------------------------------------------#
#function_name:getLhcOdpscmd
#功能：获取莲花池ODPSCMD
#参数：
#返回值：Odpscmd字符串
#使用示例 echo $(getLhcOdpscmd)
function getLhcOdpscmd()
{
	#下载odpscmd
	if [ ! -f /tmp/odps/bin/odpscmd ]
	then
	mkdir -p /tmp/odps/
	wget http://oss-cn-foshan-lhc-d01-a.ops.its.tax.cn/sharefile/deng/odps_clt_release_64.tar.gz -O /tmp/odps/odps_clt_release_64.tar.gz
	tar -zxvf /tmp/odps/odps_clt_release_64.tar.gz  -C /tmp/odps
	fi
    project_name=$(getProperty 'CURRENT_PROJECT_NAME')
    conf=$(getLhcConfig "${project_name}")
    odpscmd_path=`getProperty "ODPSCMD_PATH_LHC"`
	echo "${odpscmd_path} --config="${conf}""
 }



#------------------------------------------------------------------------------------------------------------#
#function_name:getShellDataxConfig
#功能：定义同步任务配置
#返回值： 任务配置信息路径
#示例：echo $(getShellDataxConfig 'insert_f_rt_kj_sj01_cxtj')
function getShellDataxConfig()
{
    shell_datax_home=$(getProperty 'SHELL_DATAX_HOME')
    mkdir -p ${shell_datax_home}
    #ALISA_TASK_ID=insert_f_rt_kj_sj01_cxtj;
    shell_datax_config=${shell_datax_home}/${1}
    echo $shell_datax_config
}

#------------------------------------------------------------------------------------------------------------#
#function_name:runSyncOdpsDrdsData
#功能: 同步Odps到Drds的datax
#参数：$1:中心名称 $2:json文件名 $3:源表名 $4:源表字段 $5:目标字段 $6:目标表表名
#返回值：属性值
#使用示例   runSyncOdpsDrdsData SJZT  mx_dj_nsrxx_mx mx_dj_nsrxx_mx ${column} ${column} dj_nsrxx
function runSyncOdpsDrdsData() {

username=`getProperty "DRDS_USERNAME_${1}"`
password=`getPassWDord "DRDS_PASSWORD_${1}"`
host=`getProperty "DRDS_HOSTNAME_${1}"`
db=`getProperty "DRDS_DBNAME_${1}"`
project=`getProperty 'CURRENT_PROJECT_NAME'`


#json名和路径
shell_datax_config=`getShellDataxConfig ${2}`



json="{
\"job\": {
	\"setting\":{
        \"speed\":{
      		\"channel\":32
    }
  },
  \"content\":[
    {
      \"reader\":{
        \"name\":\"odpsreader\",
        \"parameter\":{
           \"accessId\":\"VhxL6346jTLT4hfT\",
           \"accessKey\":\"MTmxFadIUmFr7cto6Ia4Zpo25za2hI\",
           \"project\":\"${project}\",
           \"table\":\"${3}\",
           \"column\":[${4}],
           \"splitMode\":\"record\",
           \"odpsServer\":\"http://service.cn-foshan-lhc-d01.odps.ops.its.tax.cn/api\"
           }
      },
       \"writer\":{
         \"name\":\"drdswriter\",
         \"parameter\":{
		   \"writeMode\": \"replace\",
           \"batchSize\": \"256\",
		   \"username\":\"${username}\",
           \"password\":\"${password}\",
           \"column\":[${5}],
		   \"preSql\":[\"\"],
		   \"connection\":[
           		{
                	 \"jdbcUrl\":\"jdbc:mysql://${host}:3306/${db}?readOnlyPropagatesToServer=false\",
                	 \"table\":[
                 		\"${6}\"
            		  ]
           		}
           ]
         }
       }
    }
  ]
 }
}
"
echo ${json} > ${shell_datax_config}


##执行同步
datax=`getProperty "DATAX_EXE"`
${datax} --jvm="-Xms4G -Xmx4G"  ${shell_datax_config}
##删除文件
rm ${shell_datax_config}
}

