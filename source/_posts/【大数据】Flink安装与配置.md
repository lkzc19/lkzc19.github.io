---
title: 【大数据】Flink安装与配置
date: 2025-05-11 15:43:54
tags: 
- Flink
categories: 大数据
---

大数据学习记录。

1. [【大数据】虚拟机Fusion初始化系统CentOS9](https://lkzc19.github.io/2025/03/06/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91%E8%99%9A%E6%8B%9F%E6%9C%BAFusion%E5%88%9D%E5%A7%8B%E5%8C%96%E7%B3%BB%E7%BB%9FCentOS9/)
2. [【大数据】Hadoop安装与配置](https://lkzc19.github.io/2025/05/10/%E3%80%90%E5%A4%A7%E6%95%B0%E6%8D%AE%E3%80%91Hadoop%E5%AE%89%E8%A3%85%E4%B8%8E%E9%85%8D%E7%BD%AE/)

# 1. 软件安装

官网下载flink

- flink-1.20.0-bin-scala_2.12.tgz

将上面的包下载后传到 hadoop102 下的`/opt/software`下。解压到`/opt/module`下。

```bash
cd /opt/software/
tar -zxf flink-1.20.0-bin-scala_2.12.tgz -C /opt/module/
```

软件分发到其他节点。

```bash
xsync /opt/module/flink-1.20.0
```

# 2. 配置

## 2.1 集群规划

集群规划如下(在上篇的Hadoop基础上):

| | hadoop102 | hadoop103 | hadoop104 |
|---|---|---|---|
| HDFS | NameNode <br> DataNode | <br> DataNode | SecondaryNameNode <br> DataNode |
| YARN | <br> NodeManager | ResourceManager <br> NodeManager | <br> NodeManager |
| Flink | JobManager <br> TaskManager | <br> TaskManager | <br> TaskManager |

## 2.2 配置

在`FLINK_HOME/conf`目录下。

修改 config.yaml 内容。

```yaml
jobmanager:
    bind-host: 0.0.0.0
    rpc:
        address: hadoop102
taskmanager:
    bind-host: 0.0.0.0
    host: hadoop102 # 要对应各自节点的host
rest:
    address: hadoop102
    bind-address: 0.0.0.0
```

masters

```bash
hadoop102:8081
```

workers

```bash
hadoop102
hadoop103
hadoop104
```

将配置分发。

```bash
xsync /opt/module/flink-1.20.0
```

分发完后再去 hadoop103、hadoop104 上修改配置文件。

修改 config.yaml 内容。将`taskmanager.host`修改成对应的主机。

```yaml
taskmanager:
    host: hadoop103
```

## 2.3 起停

启动集群。

```bash
bin/start-cluster.sh 
```

通过地址 

关闭集群。

```bash
bin/stop-cluster.sh 
```
