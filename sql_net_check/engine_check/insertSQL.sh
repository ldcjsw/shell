#!/bin/sh
for((i=0;i<6;i++))
do
	./mysql -h192.168.0.50 -P3306 -Doffline_system_d -uroot -pThinkit@2018 -N -e "insert into task_info (sid, audioName, audioUrl, XMLfilePath, processorId, voiceStatus, creatTime, beginTime) values ('1', '2', '3', '4', '5', 1, 0, 0)"
	echo $i
done
