#!/bin/sh

logFile="log.txt"

ftpServer='103.116.120.23 121'
ftpUser='ftpuser'
ftpPasswd='123456'
ftpDir='test'

ftp -n << END_SCRIPT
open $ftpServer
user $ftpUser $ftpPasswd
binary
cd $ftpDir
put $1
put $2
bye
END_SCRIPT

