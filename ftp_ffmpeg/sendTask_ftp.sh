#!/bin/sh
if [ $# -ne 4 ]
then
	echo "input invalid parameter"
	echo "example: ./sendTask.sh leftAudio.wav rightAudio.wav mixAudio.wav mixAudio.txt"
	exit
fi

leftAudio=$1
rightAudio=$2
mixAudio=$3
mixTxt=$4

logFile="log.txt"

ftpServer='103.116.120.23 121'
ftpUser='ftpuser'
ftpPasswd='123456'
ftpDir='test'

if [ ! -f $leftAudio ]
then
	echo "${rightAudio} not exits" >> $logFile
	exit
fi

if [ ! -f $rightAudio ]
then
	echo "${rightAudio} not exits" >> $logFile
	exit
fi

if [ ! -f $mixTxt ]
then
	echo "${mixTxt} not exits" >> $logFile
	exit
fi

if [ -f $mixAudio ]
then
	rm -f $mixAudio
fi

ffmpeg  -i $leftAudio  -i $rightAudio -filter_complex "[0:a][1:a]amerge=inputs=2[aout]" -map "[aout]" $mixAudio >>log.txt 2>/dev/null
if [ ! -f $mixAudio ]
then
	echo "create $mixAudio failed" >> $logFile
	exit
fi

nohup sh ./ftp.sh $mixAudio $leftAudio >>log.txt 2>/dev/null &
