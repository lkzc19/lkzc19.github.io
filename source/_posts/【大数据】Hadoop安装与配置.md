---
title: 【大数据】Hadoop安装与配置
date: 2025-05-10 17:55:56
tags: 
- Hadoop
categories: 
- 大数据
---

大数据学习记录。

1. [【大数据】虚拟机Fusion初始化系统CentOS9](https://lkzc19.github.io/2025/03/06/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91%E8%99%9A%E6%8B%9F%E6%9C%BAFusion%E5%88%9D%E5%A7%8B%E5%8C%96%E7%B3%BB%E7%BB%9FCentOS9/)

# 1. 软件安装

## 1.1 下载安装

在 Java 和 Hadoop 官网分别下载软件。

- jdk-8u202-linux-arm64-vfp-hflt.tar.gz
- hadoop-3.4.0-aarch64.tar.gz

虚拟机中克隆出三台机器，hadoop102、hadoop103、hadoop104。

hosts 配置如下：

```bash
172.16.6.102 hadoop102
172.16.6.103 hadoop103
172.16.6.104 hadoop104
```

> 配置好静态ip、hosts、以及免密登入(使用hosts中的内网域名)。

使用 lkzc19 (非root账户) 操作。

将上面的包下载后传到 hadoop102 下的`/opt/software`下。解压到`/opt/module`下。

```bash
cd /opt/software/
tar -zxf jdk-8u202-linux-arm64-vfp-hflt.tar.gz -C /opt/module/
tar -zxf hadoop-3.4.0-aarch64.tar.gz -C /opt/module/
```

## 1.2 分发脚本

解压之后，使用脚本将软件分发到另外两台服务器。

xsync
```bash
#!/bin/bash

# 1. 判断参数个数
if [ $# -lt 1 ]
then
  echo Not Enough Argument!
  exit;
fi

# 2.遍历集群所有的机器
for host in hadoop102 hadoop103 hadoop104
do
  echo ========= $host ===========
  # 3. 遍历所有目录，挨个发送
  for file in $@
  do
    # 4. 判断文件是否存在
    if [ -e $file ]
    then
      # 5. 获取父目录
      pdir=$(cd -P $(dirname $file); pwd)

      # 6. 获取当前文件的名称
      fname=$(basename $file)
      ssh $host "mkdir -p $pdir"
      rsync -av $pdir/$fname $host:$pdir
    else
      echo $file does not exit
    fi
  done
done
```

将该脚本放入`~/bin`目录下，添加执行权限后，调用脚本分发软件。

```bash
sudo chmod +x ~/bin/xsync
xsync /opt/module/
```

## 1.3 环境变量配置

配置 Java 和 Hadoop 的环境变量。

```bash
vim /etc/profile.d/env.sh
```

添加如下内容。

```bash
# alias
alias ff="source /etc/profile"
alias ve="sudo vim /etc/profile.d/env.sh"

# JAVA
export JAVA_HOME=/opt/module/jdk1.8.0_202
export PATH=$PATH:$JAVA_HOME/bin

# HADOOP
export HADOOP_HOME=/opt/module/hadoop-3.4.0
export PATH=$PATH:$HADOOP_HOME/bin
export PATH=$PATH:$HADOOP_HOME/sbin
```

刷新环境变量。

```bash
source /etc/profile
```

由于环境变量是配置了全局的，分发脚本是在非root账户下，所以此处只能各个机器进行配置。

# 2. 配置

## 2.1 集群规划

集群规划如下:

| | hadoop102 | hadoop103 | hadoop104 |
|---|---|---|---|
| HDFS | NameNode <br> DataNode | <br> DataNode | SecondaryNameNode <br> DataNode |
| YARN | <br> NodeManager | ResourceManager <br> NodeManager | <br> NodeManager |

> 注意: NameNode、SecondaryNameNode、ResourceManager 不要在同一台机器

## 2.2 配置

配置文件位置`$HADOOP_HOME/etc/hadoop`

core-site.xml

```xml
<configuration>
  <!-- 指定NameNode的地址 -->
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://hadoop102:8020</value>
  </property>
  <!-- 指定hadoop数据存储目录 -->
  <property>
    <name>hadoop.tmp.dir</name>
    <value>/opt/module/hadoop-3.4.0/data</value>
  </property>
  <!-- 配置HDFS网页登入使用的静态用户为lkzc19 -->
  <property>
    <name>hadoop.http.staticuser.user</name>
    <value>lkzc19</value>
  </property>
</configuration>
```

hdfs-site.xml

```xml
<configuration>
  <!-- nn web端访问地址 -->
  <property>
    <name>dfs.namenode.http-address</name>
    <value>hadoop102:9870</value>
  </property>
  <!-- 2nn web端访问地址 -->
  <property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>hadoop104:9868</value>
  </property>
</configuration>
```

yarn-site.xml

```xml
<configuration>
  <!-- 指定MR走shuffle -->
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <!-- 指定ResourceManager的地址 -->
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>hadoop103</value>
  </property>
  <!-- 环境变量继承 -->
  <property>
    <name>yarn.nodemanager.env-whitelist</name>
    <value>JAVA_HOME,HADOOP_HOMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_MAPRED_HOME</value>
  </property>
  <!-- 开启日志聚集功能 -->
  <property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
  </property>
  <!-- 设置日志聚集服务器地址 -->
  <property>
    <name>yarn.log.serrver.url</name>
    <value>http://hadoop102:19888/jobhistory/logs</value>
  </property>
  <!-- 设置日志保留时间为7天 -->
  <property>
    <name>yarn.log-aggregation.retain-seconds</name>
    <value>604800</value>
  </property>
</configuration>
```

mapred-site.xml

```xml
<configuration>
  <!-- 指定MapReduce程序运行在Yarn上 -->
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>
  <!-- 历史服务器端地址 -->
  <property>
    <name>mapreduce.jobhistory.address</name>
    <value>hadoop102:10020</value>
  </property>
  <!-- 历史服务器web端地址 -->
  <property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>hadoop102:19888</value>
  </property>
</configuration>
```

workers

```bash
hadoop102
hadoop103
hadoop104
```

配置完之后将配置目录进行分发。

```bash
xsync /opt/module/hadoop-3.4.0/etc/hadoop/
```

## 2.3 启停

在启动之前得先初始化。

在hadoop102节点执行下面命令，只需要执行一次，此命令会清楚数据！

```bash
hdfs namenode -format
```

然后在`HADOOP_HOME`目录下执行

```bash
sbin/start-dfs.sh
sbin/start-yarn.sh
bin/mapred --daemon start historyserver
```

在宿主机上也配置hosts。

```bash
172.16.6.102 hadoop102
172.16.6.103 hadoop103
172.16.6.104 hadoop104
```

可以通过地址访问到相关组件的web页面

- HDFS 的 NameNode http://hadoop102:9870/
- YARN 的 ResourceManager http://hadoop103:8088/
- 历史任务服务查看 http://hadoop102:19888/jobhistory

关闭使用下面命令。

```bash
bin/mapred --daemon stop historyserver
sbin/stop-yarn.sh
sbin/stop-dfs.sh
```

## 2.4 hadoop集群起停脚本

myhadoop

```bash
#!/bin/bash

# 启停hadoop
# 参数:
#   - start 启动
#   - stop  停止

if [ $# -lt 1 ]
then
    echo "No Args Input"
    exit;
fi

case $1 in
"start")
    echo "========== 启动 hadoop 集群 =========="

    echo "---------- 启动 hdfs ----------"
    ssh hadoop102 "/opt/module/hadoop-3.4.0/sbin/start-dfs.sh"
    echo "---------- 启动 yarn ----------"
    ssh hadoop103 "/opt/module/hadoop-3.4.0/sbin/start-yarn.sh"
    echo "---------- 启动 historyserver ----------"
    ssh hadoop102 "/opt/module/hadoop-3.4.0/bin/mapred --daemon start historyserver"
;;
"stop")
    echo "========== 关闭 hadoop 集群 =========="

    echo "---------- 关闭 historyserver ----------"
    ssh hadoop102 "/opt/module/hadoop-3.4.0/bin/mapred --daemon stop historyserver"
    echo "---------- 关闭 yarn ----------"
    ssh hadoop103 "/opt/module/hadoop-3.4.0/sbin/stop-yarn.sh"
    echo "---------- 关闭 hdfs ----------"
    ssh hadoop102 "/opt/module/hadoop-3.4.0/sbin/stop-dfs.sh"
;;
*)
    echo "Input Args Error"
;;
esac
```
