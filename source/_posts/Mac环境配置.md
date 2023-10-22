---
title: Mac环境配置
date: 2023-07-09 20:18:24
tags: Mac
---

# 0 前言

Mac默认使用的shell是zsh，一般环境变量是直接在`.zshrc`文件中配置的。但是如果所有的环境变量、别名，或者是自己写的一些脚本都在这个文件中配置，会显得有点乱。在CentOS中，系统级别的环境配置会有一个总的配置文件去读一个目录下所有的配置文件。我也按照这种方式简单的组织了我的环境配置。

# 1 正文

目录结构大致如下

```markdown
~
├──.zshrc
├── profile.d
│   ├── alias.d
│   │   ├── custom.sh
│   │   └── third.sh
│   ├── oh_my_zsh.sh
│   ├── zalias.sh
│   ├── zenv.sh
│   └── ztokens.sh
└── bin
	└── zmdot-sync.sh
```

>tree目录使用homebrew安装的tree生成的

模仿CentOS，在`.zshrc`中遍历`profile.d`中所有的配置文件

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

其中在`~/profile.d/zenv.sh`配置了平时开发会用到的环境变量，比如Java的环境变量等，平时可能需要多种版本的Java，所以配置了多版本Java，根据需求使用别名`jdk8/jdk11`做切换。

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

在`~/profile.d/zalias.sh`中配置别名，比较通用的命令别名在这个文件中直接配置，且在该文件中使用与`.zshrc`文件一样的方法读取其他的文件，做一个别名分组。比如我再分了两个别名文件。

在`third.sh`中，设置了第三方软件命令的别名，比如Redis根据配置文件启动。

```bash
# 存放第三方软件，通常是「学习」用的，平时不会使用的命令的别名


# ElasticSearch
alias es='elasticsearch'
alias esp='elasticsearch-plugin'

# Redis
# redis-server conf
alias redis-server.conf='redis-server /opt/homebrew/etc/redis.conf --color=auto'
```

在`custom.sh`中，我放了一些大佬写的项目，或者自己写的demo的启动命令别名。

```bash
# 存放平时自己开发，或者是大佬开发的软件的启动命令的别名

# gitee上大佬做的仿git项目
alias zit='java -jar $HOME/bin/lib/zit-1.0-SNAPSHOT-shaded.jar'
```

`ztokens.sh`文件中，存放了一些token凭证，提供给一些软件使用，比如Github API Token

```bash
# 用于存放一些token，如Github API Token，如：
export HOMEBREW_GITHUB_API_TOKEN=xxx
```

像是`oh_my_zsh.sh`这些文件，就是专门的配置文件了。

`~/bin`目录下放了一些执行脚本，在`zenv.sh`中设置好环境变量就可以直接调用了。

配置文件以上传至[github](https://github.com/lkzc19/zmdot)

---
关于别名参考[dotfiles](https://github.com/paulirish/dotfiles/blob/main/.aliases)，该仓库还包含了其他许多配置。



