set "operator.kafka.brokers"="192.168.0.2:9092";
set "operator.kafka.zookeepers"="192.168.0.2:2181";
set "operator.kafka.zksessiontimeout"="20000";
set "operator.kafka.zksynctime"="20000";
set "operator.kafka.messageserializerclass"="kafka.serializer.StringEncoder";
set "serde.simpleserde.separator" = ",";

create input stream S 
(id int ,name String,type int)
	 SERDE SimpleSerDe
		 PROPERTIES ("serde.simpleserde.separator" = ",")
	 SOURCE 'com.huawei.streaming.operator.inputstream.KafkaSourceOp'
		 PROPERTIES ("operator.kafka.groupid" = "gidkpi_1_1","operator.kafka.topic"="agg_1_1");
							
	create output stream rs 
		(id string,name string,type int,cc int)
	 SERDE SimpleSerDe
	 SINK 'com.huawei.streaming.operator.outputstream.KafkaFunctionOp'
		 PROPERTIES ("operator.kafka.topic"="agg_1_2");
	--最一般的聚合查询。仅仅带了窗口							
	insert into stream rs select *,count(id) from S[range 200 milliseconds batch] where id > 5 group by type;
	submit application aggregate5;