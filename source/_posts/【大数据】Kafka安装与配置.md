---
title: 【大数据】Kafka安装与配置
date: 2025-05-22 21:38:28
tags: 
- Kafka
categories: 
- 大数据
---

大数据学习记录。

1. [【大数据】虚拟机Fusion初始化系统CentOS9](https://lkzc19.github.io/2025/03/06/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91%E8%99%9A%E6%8B%9F%E6%9C%BAFusion%E5%88%9D%E5%A7%8B%E5%8C%96%E7%B3%BB%E7%BB%9FCentOS9/)
2. [【大数据】Hadoop安装与配置](https://lkzc19.github.io/2025/05/10/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91Hadoop%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE/)
3. [【大数据】Flink安装与配置](https://lkzc19.github.io/2025/05/11/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91Flink%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE/)

# 1. 软件安装

官网下载 kafka 和 zookeeper。

- kafka_2.12-3.8.1.tgz
- apache-zookeeper-3.8.4-bin.tar.gz

将上面的包下载后传到 hadoop102 下的`/opt/software`下。解压到`/opt/module`下。

```bash
cd /opt/software/
tar -zxf kafka_2.12-3.8.1.tgz -C /opt/module/
tar -zxf apache-zookeeper-3.8.4-bin.tar.gz -C /opt/module/
```

软件分发到其他节点。

```bash
xsync /opt/module/kafka_2.12-3.8.1
xsync /opt/module/zookeeper-3.8.4
```

# 2. 配置

## 2.1 zookeeper 配置

配置服务器编号。

到zk的home目录下，创建`zkData`目录。

```bash
cd /opt/module/zookeeper-3.8.4
mkdir zkData
```

在该`zkData`目录下，创建`myid`文件，内容如下

```bash
1
```

修改zk的配置文件，到conf目录下，拷贝zoo_simple.cfg到当前目录，名为zoo.cfg。

```bash
cp zoo_simple.cfg zoo.cfg
```

编辑`zoo.cfg`文件，做如下修改。

```conf
# 修改
dataDir=/opt/module/zookeeper-3.8.4/zkData

# 追加
server.1=hadoop102:2888:3888
server.2=hadoop103:2888:3888
server.3=hadoop104:2888:3888

# server.A=B.C.D
# A 是一个数字 表示这是第号服务器 myid中的值
# B 是 A 服务器的主机名
# C 是 A 服务器与集群中的主服务器(Leader)交换信息的端口
# D 是 A 服务器用于主服务器(Leader)选举的端口
```

分发配置，后修改每台服务器的myid，我的三台机器对应关系如下。

```markdown
hadoop102 -> 1
hadoop103 -> 2
hadoop104 -> 3
```

## 2.2 zookeeper 起停

使用`bin/zkServer.sh`进行起停

```bash
bin/zkServer.sh start # 启动本机的zk
bin/zkServer.sh stop # 停止本机的zk
bin/zkServer.sh status # 查看本机的zk的状态
```

起停脚本。

```bash
#!/bin/bash

# 启停zk
# 参数:
#   - start 启动
#   - stop  停止
#   - status 查看状态

if [ $# -lt 1 ]
then
    echo "No Args Input"
    exit;
fi

case $1 in
"start") {
    for i in hadoop102 hadoop103 hadoop104
    do
        echo ---------------------- zk $i 启动 ---------------------------
        ssh $i "/opt/module/zookeeper-3.8.4/bin/zkServer.sh start"
    done
}
;;
"stop") {
    for i in hadoop102 hadoop103 hadoop104
    do
        echo ---------------------- zk $i 停止 ---------------------------
        ssh $i "/opt/module/zookeeper-3.8.4/bin/zkServer.sh stop"
    done
}
;;
"status") {
    for i in hadoop102 hadoop103 hadoop104
    do
        echo ---------------------- zk $i 状态 ---------------------------
        ssh $i "/opt/module/zookeeper-3.8.4/bin/zkServer.sh status"
    done
}
;;
*)
    echo "Input Args Error"
;;
esac
```

## 2.3 kafka 配置

到kafka的home目录下，修改`config/server.properties`文件。

```properties
broker.id=1
advertised.listeners=PLAINTEXT://hadoop102:9092
log.dirs=/opt/module/kafka_2.12-3.8.1/data
zookeeper.connect=hadoop102:2181,hadoop103:2181,hadoop104:2181/kafka
```

分发配置，到每个节点修改`config/server.properties`文件中的`broker.id`和`advertised.listeners`，对应关系如下。

```markdown
hadoop102
    - broker.id=1
    - advertised.listeners=PLAINTEXT://hadoop102:9092
hadoop103
    - broker.id=2
    - advertised.listeners=PLAINTEXT://hadoop103:9092
hadoop104
    - broker.id=3
    - advertised.listeners=PLAINTEXT://hadoop104:9092
```

## 2.4 kafka 起停

kafka要依赖zk，所以在在启动kafka之前要先启动zk。

kafka的起停命令。

```bash
# 启动本机的kafka
bin/kafka-server-start.sh -daemon /opt/module/kafka_2.12-3.8.1/config/server.properties
# 停止本机的kafka
bin/kafka-server-stop.sh
```

起停脚本。

```bash
#!/bin/bash

# 启停kafka
# 参数:
#   - start 启动
#   - stop  停止

if [ $# -lt 1 ]
then
    echo "No Args Input"
    exit;
fi

case $1 in
"start") {
    for i in hadoop102 hadoop103 hadoop104
    do
        echo ---------------------- kafka $i 启动 ---------------------------
        ssh $i "/opt/module/kafka_2.12-3.8.1/bin/kafka-server-start.sh -daemon /opt/module/kafka_2.12-3.8.1/config/server.properties"
    done
}
;;
"stop") {
    for i in hadoop102 hadoop103 hadoop104
    do
        echo ---------------------- kafka $i 停止 ---------------------------
        ssh $i "/opt/module/kafka_2.12-3.8.1/bin/kafka-server-stop.sh"
    done
}
;;
*)
    echo "Input Args Error"
;;
esac
```
