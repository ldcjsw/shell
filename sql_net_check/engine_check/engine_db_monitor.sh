#!/bin/sh
DIR_LOCAL=$(cd `dirname $0`; pwd)
export LD_LIBRARY_PATH=${DIR_LOCAL}/lib:$LD_LIBRARY_PATH

db_check_range=3600000					#数据库中需要检测最近的时间段 单位 （秒）
db_check_interval=6					#查询数据库间隔（秒）
server_check_interval=3					#查询服务器间隔（秒）
rcvMobiles='"15101010101","15101010102"'		#手机号码
msg_url=http://172.18.84.125:18080/ccs/sendmsg		#短信接口地址

ip_port_file=./cfg/ip_port.txt
db_file=./cfg/db.txt
db_err_file=./cfg/db_error.txt
tmp_file=.result.tmp

function send_msg()
{
	data='{"rcvMobiles":['${rcvMobiles}'],"content":"'$*'"}'
	timeout --signal=9 1 ./bin/curl -H "Content-Type: application/json" -X POST -d $data ${msg_url}
	date=`date +%Y-%m-%d/%H:%M:%S`
	echo ${date} $data
}

function check_ip_port() 
{
	ip=$1
	port=$2
	echo "" | timeout --signal=9 1 telnet ${ip} ${port} > ${tmp_file}
	connect_status=`cat ${tmp_file} | sed -n '2p'|awk '{print $1}'`
	if [ -z ${connect_status} ]
	then
		send_msg "服务器进程"$ip":"$port"未启动" 
	fi
}

function monitor_server()
{
	line_num=`cat ${ip_port_file}|wc -l`
	for (( i=1; i<=${line_num}; i++ ))
	do
		ip=`sed -n ${i}p ${ip_port_file}|awk '{print $1}'`
		port=`sed -n ${i}p ${ip_port_file}|awk '{print $2}'`
		check_ip_port $ip $port
	done
}

function check_db()
{
	line_num=`cat ${db_err_file}|wc -l`
        for (( i=1; i<=${line_num}; i++ ))
        do
                err_msg=`sed -n ${i}p ${db_err_file}|cut -d ' ' -f 1`
                err_limit=`sed -n ${i}p ${db_err_file}|cut -d ' ' -f 2`
                err_info=`sed -n ${i}p ${db_err_file}|cut -d ' ' -f 3-`

		sql_cmd="select id from task_info where unix_timestamp(endTime) >= unix_timestamp(NOW()) - ${db_check_range} ORDER BY id ASC LIMIT 1"
		id=$(./bin/mysql $1 "${sql_cmd}")
		if [ -z $id ]
		then
			continue
		fi
		sql_cmd="select processorId, '-', COUNT(*),'|' from task_info where id >= ${id} and failCause = '${err_info}' GROUP BY processorId"
		results=$(./bin/mysql $1 "${sql_cmd}")
		lines=`echo $results | awk -F"|" '{printf NF}'`
		for(( j=1; j<$lines; j++ ))
		do
        		result=`echo $results|cut -d'|' -f $j`
        		processorId=`echo $result|cut -d'-' -f 1`
        		errorNums=`echo $result|cut -d'-' -f 2`

			if [ $errorNums -gt $err_limit ]
			then
                		send_msg "处理引擎"$processorId"："$err_msg"已有"$errorNums"次"
			fi
		done

        done
}

function monitor_db()
{
	line_num=`cat ${db_file}|wc -l`
        for (( i=1; i<=${line_num}; i++ ))
        do
                ip=`sed -n ${i}p ${db_file}|awk '{print $1}'`
                port=`sed -n ${i}p ${db_file}|awk '{print $2}'`
                db=`sed -n ${i}p ${db_file}|awk '{print $3}'`
                user=`sed -n ${i}p ${db_file}|awk '{print $4}'`
                passwd=`sed -n ${i}p ${db_file}|awk '{print $5}'`
		
		sql="-h${ip} -P${port} -D${db} -u${user} -p${passwd} -N -e"		
                check_db "$sql"
        done
}

function main()
{
	time_count=0
	while [ 1 ]
	do
		if [ ${time_count} -eq ${db_check_interval} ]
		then
			monitor_db
		fi

		if [ ${time_count} -eq ${server_check_interval} ]
		then
			monitor_server
		fi
		
		if [ ${time_count} -ge ${db_check_interval} -a ${time_count} -ge ${server_check_interval} ]
		then
			let "time_count=0"
		else
			let "time_count+=1"
		fi

		sleep 1
	done
}

main
