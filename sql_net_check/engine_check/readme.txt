1、配置文件
	cfg
		db_error.txt
		db.txt
		ip_port.txt
		
	db_error.txt中 第一列是短信内容，第二列是一段时间内错误限制次数，第三列是数据库中的错误 超过限制次数就会发送短信
		异常语音不能处理 3 Can not handle the abnormal audio!
		识别模块处理失败 3 task failed where server=offline_customer_server_test_dnnvad
		角色分割模块处理失败 3 task failed where server=ClusterAndSceneServer
		叠音模块处理失败 3 task failed where server=DetectOverlapPro
		情绪模块处理失败 3 task failed where server=DetectEmotionPro
		xml模块处理失败 3 task failed where server=XMLServer
		语音不存在 3 voice not exits
		语音转码失败 3 voice transcode failed
		语音过短 3 voice is too short
		语音处理期间系统有重启 3 SysRestart
		不能打开xml文件路径 3 can't open xmlfilepath
		不能打开文件 3 open xmlfile failed
		超时两次 3 Timeout twice!


	db.txt 中配置数据库的ip port 数据库名 用户 密码，可配置多个
		192.168.96.89 3306 offline_system_d root Thinkit@2018
		192.168.96.89 3306 offline_system_d root Thinkit@2018

	ip_port.txt 中是需要监控的服务器id 端口，访问不通就会发短信
		39.156.66.18 80
		39.156.66.18 127
		39.156.66.18 443
		192.168.96.87 2245
2、配置脚本 engine_db_monitor.sh
	db_check_range=3600000 							#数据库中需要检测最近的时间段 单位（秒）
	db_check_interval=6							#数据库检测间隔 单位（秒）
	server_check_interval=3							#服务器检测间隔 单位（秒）
	rcvMobiles='"15101010101","15101010102"'				#接收短信的手机号
	msg_url=http://172.18.84.125:18080/ccs/sendmsg				#接收消息的服务器
3、启动
	./start.sh
4、关闭
	./stop.sh
5、发送的短信同时会保留到log.txt文件
