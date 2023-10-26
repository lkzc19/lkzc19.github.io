---
title: Mac环境配置 v0.2
date: 2023-10-25 20:14:56
tags: Mac
---

# 前言

与 [Mac环境配置 v0.1](https://lkzc19.github.io/2023/07/09/Mac%E7%8E%AF%E5%A2%83%E9%85%8D%E7%BD%AE-v0-1/) 差不多，再整理一下。现在将环境配置与脚本分成了两个仓库存放：

- [zmdot: Mac 环境配置](https://github.com/lkzc19/zmdot)
- [zbin: Mac Bash脚本](https://github.com/lkzc19/zbin)

zbin 仓库中还有Windows的脚本，计划后续将各个平台，各种用途的脚本都加入到这个仓库中，用不同的分支管理起来。

zmdot 仓库只有Mac的环境配置，计划之后把这个仓库重命名为 zdot 与 zbin 一样加入其他系统的配置，且把其他软件的配置也保存起来。

这样切换设备时，就可以快速的配置新的设备。最好写一个脚本，可以一键配置新设备。

# zmdot

## 目录结构

```bash
.
├── .zshrc
├── .vim
│   └── vimrc
└── profile.d
    ├── alias.d
    │   ├── custom.sh # 自己或者别人写的如 Jar包 启动别名
    │   └── third.sh  # 第三方软件 如redis启动 配置的别名
    ├── omz.sh # oh-my-zsh.sh 的配置
    ├── zalias.sh # 自定义别名主配置
    ├── zconf.sh # 一些配置 如history命令设置显示时间
    ├── zenv.sh  # 环境变量配置
    └── zfunc.sh # 一些常用的命令组合
```

## .zshrc & profile.d

模仿 CentOS 的配置，在 profile.d 目录下创建编写配置脚本，在 .zshrc 中遍历读取 profile.d 目录下的文件。

且读取的逻辑是直接从 CentOS 中拷贝过来的。

```bash
for i in ~/profile.d/*.sh ; do
  if [ -r "$i" ]; then
    if [ "${-#*i}" != "$-" ]; then
      . "$i"
    else
      . "$i" >/dev/null 2>&1
    fi
  fi
done
```

## zalias.sh & zfunc.sh

这两个文件参考 [dotfiles](https://github.com/paulirish/dotfiles/blob/main/.aliases) 。

别名配置还另外起了两个别名文件放在 alias.d 目录中，本来是使用与读 profile.d 一样的方式，但觉得就两个文件没有必要，直接使用 source 命令读数据，还更简短一些。

除了常用的别名，还有在终端使用 vscode 或者 sublime 打开文件，弄成了与 `open .` 一样的效果。打开文件，不用在目录里慢慢找了。

```bash
alias code='/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code'
alias text="/Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl"
```

Java的版本切换，也用到别名，但是我将这部分内容写在了 zenv.sh 中。

```bash
# JAVA
JAVA_HOME_8="/Library/Java/JavaVirtualMachines/jdk1.8.0_341.jdk/Contents/Home"
JAVA_HOME_11="/Library/Java/JavaVirtualMachines/jdk-11.0.14.jdk/Contents/Home"

JAVA_HOME=$JAVA_HOME_8
PATH=$PATH:$JAVA_HOME/bin
export JAVA_HOME
export PATH
# 用于切换JDK版本
alias jdk8="export JAVA_HOME=$JAVA_HOME_8"
alias jdk11="export JAVA_HOME=$JAVA_HOME_11"
```

我理解的写 function 和写别名的效果差不多，写多行或者是逻辑稍微复杂一点，用 function 就更合适，

```bash
# 查看进程时 过滤掉本条命令的进程
function pg() {
  ps -ef | grep -v "grep" | grep "$@"
}
# 这条直接使用 别名 的效果是一样的
```

## 杂项

其他的则是某些软件的配置文件，如omz.sh，也移动到 profile.d 目录中了.

还有一个文件没有写出来 ztoken.sh 存放各种 token 等敏感数据，配合脚本使用(因为这些放到了Git仓库上了)。

未来会将其他软件的配置文件倒出，也保存在这个仓库中。

# zbin

zbin 上有两条主要分支 Mac/Windows，脚本的主要逻辑还是用 python 写的，但为了调用方便，就用各个系统的脚本语言封装了一层方便调用。

## 客户端登录脚本(密码写死)

功能性的脚本直接上GitHub上看代码即可。这边记录一些对脚本不同角度的看法。

我在自己电脑上装了很多服务，比如 MySQL、PostgresSQL，除服务还有比如树莓派，这些都需要在终端登录，但是有时候好久登一次，会忘记密码(虽然可以记在一个地方)。而既然这样，就可以写一个脚本专门去登录用的，且都是本地，密码写在脚本上也没事，既可以用作登录，也可作为密码备忘录。

我的登录脚本：

```bash
#!/bin/bash

# 该脚本用于直接登录各种客户端，且作为密码备忘录(都是本地服务)

if [ $# -lt 1 ]
then
  echo Not Enough Argument!
  exit;
fi

help="1. pg -> PostgreSQL\n2. my -> MySQL"

if [ "$1" == "help" ]; then
  echo -e "$help"
elif [ "$1" == "my" ]; then
  mysql -u root -p'1111'
elif [ "$1" == "pg" ]; then
  PGPASSWORD="111111" psql -h 127.0.0.1 -p 5432 -U lkzc19 -d postgres
elif [ "$1" == "pi" ]; then
  # 配置了 SSH 免密登录
  ssh pi@192.168.31.10
else
  echo "参数错误 请参考如下: "
  echo -e "$help"
fi
```

## 敏感数据避免上传到仓库

有两种解决方式

1. 使用环境变量

2. 写配置文件，比如 zbin 就是用 zbin.conf 存放敏感数据，用git将这个文件忽略，上传了一个 zbin.example.conf，其他地方拉代码后，将 zbin 复制一个为 zbin.conf 即可。

(完)

