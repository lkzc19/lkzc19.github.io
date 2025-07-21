---
title: 【大数据】Spark安装与配置
date: 2025-07-21 22:03:28
tags: 
- Spark
categories: 
- 大数据
---

1. [【大数据】虚拟机Fusion初始化系统CentOS9](https://lkzc19.github.io/2025/03/06/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91%E8%99%9A%E6%8B%9F%E6%9C%BAFusion%E5%88%9D%E5%A7%8B%E5%8C%96%E7%B3%BB%E7%BB%9FCentOS9/)
2. [【大数据】Hadoop安装与配置](https://lkzc19.github.io/2025/05/10/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91Hadoop%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE/)
3. [【大数据】Flink安装与配置](https://lkzc19.github.io/2025/05/11/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91Flink%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE/)
4. [【大数据】Kafka安装与配置](https://lkzc19.github.io/2025/05/22/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91Kafka%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE/)


# 1. 软件安装

官网下载 Spark。

- [spark-4.0.0-bin-hadoop3.tgz](https://dlcdn.apache.org/spark/spark-4.0.0/spark-4.0.0-bin-hadoop3.tgz)

将上面的包下载后传到 hadoop102 下的`/opt/software`下。解压到`/opt/module`下。

```bash
cd /opt/software/
tar -xzf spark-3.4.4-bin-hadoop3.tgz -C /opt/module/
cd /opt/module
mv spark-3.4.4-bin-hadoop3 spark-3.4.4
```

# 2. 提交任务到Yarn上

## 2.1 配置Yarn

到Spark的home目录下，修改conf目录下的配置文件`spark-env.sh`。

```bash
cp spark-env.sh.template spark-env.sh

vim spark-env.sh
# 添加如下内容
# yarn的配置文件所在目录
YARN_CONF_DIR=/opt/module/hadoop-3.4.0/etc/hadoop
```

## 2.2 提交任务

使用Spark自带的一个计算圆周率的例子。

```bash
bin/spark-submit \
--class org.apache.spark.examples.SparkPi \
--master yarn \
./examples/jars/spark-examples_2.12-3.4.4.jar \
10
```

执行结果。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/default/f72386f2343da476fb3394c3fba013e8.png)

# 3. 配置历史服务器

到Spark的home目录下，修改conf目录下的配置文件`spark-defaults.conf`。

```bash
cp spark-defaults.conf.template spark-defaults.conf

vim spark-defaults.conf
# 添加如下内容
spark.eventLog.enabled           true
spark.eventLog.dir               hdfs://hadoop102:8020/directory
spark.yarn.historyServer.address=hadoop102:18080
spark.history.ui.port=18080
```

修改conf目录下的配置文件`spark-env.sh`，追加如下内容。

```bash
export SPARK_HISTORY_OPTS="
-Dspark.history.ui.port=18080
-Dspark.history.fs.logDirectory=hdfs://hadoop102:8020/directory
-Dspark.history.retainedApplications=30
"
```

在hdfs上添加目录directory。
> http://hadoop102:9870/

![](https://raw.githubusercontent.com/lkzc19/nimg/main/default/240b1a7a417c74cc5defe5e680c1d671.png)

启停历史服务器命令

```bash
bin/start-history-server.sh
bin/stop-history-server.sh
```

启动历史服务器后，并且跑完任务后可以在`http://hadoop103:8088/`上看到任务，点击`history`可以看到详情。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/default/cf1f38d594354629464acdc150045efb.png)
![](https://raw.githubusercontent.com/lkzc19/nimg/main/default/f98a6a490f2afb8114ed2b1999d569a8.png)
