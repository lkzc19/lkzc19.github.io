---
title: VSCode 远程连接
date: 2023-10-23 22:39:46
tags: VSCode
---

# 免密登录

生成SSH密钥，直接一路回车即可。

```bash
ssh-keygen
```

在`~/.ssh`目录下会生成两个文件

- id_rsa 私钥
- id_rsa.pub 公钥

将公钥放到目标服务器中，位置和默认文件名是`~/.ssh/authorized_keys`。

也可以通过命令直接传过去，如我将我的电脑的公钥传到树莓派：

```bash
ssh-copy-id pi@192.168.10.31
```

修改树莓派的SSH配置文件：

```bash
sudo vim /etc/ssh/sshd_config
```

找到以下字段并修改：

```conf
PubkeyAuthentication yes
PasswordAuthentication no
```

重启SSH服务

```bash
sudo service ssh restart
```

如果想要修改authorized_keys文件名，再修改完文件名后，并且修改SSH配置文件，改成一样的文件名一样的名字即可。同样再重启SSH服务。

```bash
AuthorizedKeysFile      /home/pi/.ssh/macmini_authorized_keys
```

> 树莓派上可能没有自带vim, 使用nano
> - ctrl + o 保存 (是否确认 回车确认)
> - ctrl + x 退出
> - 如何操作直接看下面nano编辑器一排的命令提示即可

# VSCode 远程连接

TODO 树莓派的架构与Mac M1版架构不同，无法连接。
TODO 用windows 试一下 估计也不行。。。
