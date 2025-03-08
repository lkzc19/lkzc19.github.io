---
title: 【大数据】虚拟机Fusion初始化系统CentOS9
date: 2025-03-06 23:42:15
tags: 
- Mac
- Fusion
- CentOS
categories: 墙
---

大数据学习记录。

由于使用的Mac电脑，在虚拟中安装比较常用的CentOS7.x(目前公司用的系统也是这个)，始终安装不上，再尝试使用CentOS9，可以安装上，且使用上与之前的大版本差别也不大。

> Fusion & CentOS 均可在官方页面下载到，注意要下载相关芯片架构的版本。

# 1. 安装系统

创建虚拟机，将选择好镜像。选择如下操作系统(这一步应该没什么影响，因为已经有实际的镜像了)。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/f1d8eb202aad7c47faa914964dd8c3b2.png)

下一步，给了默认的配置，可能会不够用，所以加点配置。这里按自己电脑配置来。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/445a14496be51d920c17d83ada2a0c5e.png)
![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/c1dca2e76c880a67da8fe8e0a4b2031b.png)
![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/8f0354900332d40868aaa14ecfd600e8.png)

然后启动虚拟机，选择默认项。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/cb7195cd19d5a5c2252c1d1126409828.png)

刚进入系统，选择语言。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/6a8c261f025bb20fa97bf02d97fabd59.png)

再进行如下系统配置。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/2ad07ece41bb88b782754d019916bc0d.png)

配置root用户，自己使用所以允许ssh直连。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/074e9ca5466ee6d53afa1fc23712fef7.png)

配置普通用户，之后大部分操作都是在普通用户上执行的。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/975a3f5b377d6714774c07253a643f47.png)

选择Server。不需要UI，最小安装则很多软件会缺。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/17527333c880cf6c503480acbfb0e416.png)

安装目标位置，点进去后直接完成，用默认的就好。然后开始安装。安装完成后，点击重启系统，就安装完成了。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/5383d700389e9046f374693ae0a63c06.png)

# 2. 系统配置

先创建一个快照保存一下，如果之后配置错了或者其他原因，可以回滚到这个快照。

![image.png](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/ac8e3c864f51659565126ac95fdfa84b.png)

接下来操作都是用root用户。

## 2.1 配置静态IP

### 2.1.1 Fusion & Mac 的配置

打开VM配置，到网络配置中。解锁后添加一个配置，默认配置名应该是vmnet2，或者其他的也没有关系，如下图。注意不要点上DHCP(动态配置)。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/090d8f5b6fca4a04bc0deff126b518d6.png)

然后进入到`/Library/Preferences/VMware\ Fusion/`目录中。中间的 \ 是空格转义，不加的话找不到目录。

```bash
cd /Library/Preferences/VMware\ Fusion/
```

查看该目录下的`networking`文件。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/4cf6e42ecebdf9cca079464ff19f60ba.png)

VNET_2就是刚创建的，其中`255.255.255.0`是子网掩码，`172.16.167.0`是子网地址。

再进入当前目录下的`vmnet2`目录下，这个目录也是刚创建配置后才生成的。修改文件`nat.conf`。在修改可以前先做一个备份。

```bash
sudo cp nat.conf nat.conf.bak
sudo vim nat.conf
```

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/68731000bd3b9377f80e7aa4087986d0.png)

`172.16.x.x`到`172.31.x.x`是私网地址(最经常见到应该是`192.168`开头的)，第二个`x`使用`2-254`，其他地址默认作为一些设备的ip，或者是广播地址，会有冲突。

如上面的配置`172.16.167.2`。而子网掩码就依然如上。这里默认生成的其实就是可以使用的，不用修改。

### 2.1.2 CentOS的配置

在CentOS9中配置静态IP的位置在`/etc/NetworkManager/system-connections/ens160.nmconnection`

```bash
sudo vim /etc/NetworkManager/system-connections/ens160.nmconnection
```

在`[ipv4]`下

- 修改`method`的值`auto`为`manual`
- 添加`address1=172.16.167.100/24,172.16.167.2`
- 添加`dns=8.8.8.8;8.8.4.4;`

`address1`是静态IP地址(和宿主机是同一个网段机`172.16.167`)和网关(刚设置宿主机的IP)的组合，以逗号分隔。`dns`是DNS服务器的地址，以分号分隔。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/8df5c9eb3e42277d5ceeb0912430d902.png)

重启使配置生效。

```bash
reboot
```

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/14955896186be5ad193bf005ab7f5dac.png)

具体虚拟机上修改配置，选择网络，选择刚创建的配置。

然后虚拟就可以通过配置的静态IP连上了。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/090326d2e7b8c1cc15154ae2e5392345.png)

## 2.2 修改主机名称

现在名称上上面一个图可以看到是localhost。

修改`/etc/hostname`文件，文件内容就是主机名，然后重启。

```bash
vim /etc/hostname
# ...
reboot
```


## 2.3 配置普通用户sudo免密

以上系统配置需要用`root`用户操作，其他的操作一般使用普通用户，但是用普通用户时也会经常需要`sudo`，为了方便则给该用户配置免密。

在`/etc/sudoers`添加如下格式配置。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/b6137c862c0669e0a85f23c92d8e2c7b.png)

保存后，配置的用户就可以免密的使用`sudo`

## 2.3 配置ssh免密登入

之后搭建集群，需要同步集群文件或者其他操作，需要机器之间互相登入，每次输入密码太麻烦，所以配置免密登入。先克隆1台虚拟机。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/4b6364c4268197f02178d7056f8d75e3.png)

按照之前的步骤修改静态IP以及主机名，重启后生效。

使用普通用户配置免密登入。

生成`ssh key`，一路回车即可。

```bash
ssh-keygen -t rsa 
```

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/491d0107ae0d613cf5e1fcf0566f309c.png)

将key发送到目标服务器。

```bash
ssh-copy-id lkzc19@172.16.167.42
```

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/810c7b327b2557cd0bd3ee63fd1498c8.png)

除了其他机器配置免密登入，本级也要配置，因为之后执行脚本是全部机器都会执行，本机也会使用ssh执行脚本。

# 0. 参考文档

- [VMware Fusion配置NAT静态IP](https://www.cnblogs.com/S1mpleBug/p/16684747.html)
- [解决linux NetworkManager配置静态IP的具体操作步骤](https://blog.51cto.com/u_16175477/6653184)