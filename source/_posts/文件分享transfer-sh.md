---
title: 文件分享transfer.sh
date: 2023-09-14 00:15:26
tags:
---

# 0 前言

最近工作需要将需要测试的App发到真机上测试，但是不想在公司的设备上登录私人QQ或者微信来传文件，公司也没有刻意用于分享文件的工具。这让我想起了上家公司，运维有提供一个脚本，只要执行这个脚本就可以把文件上传，返回一个链接，使用 wget 或者浏览器就可以下载下来，很方便好用。可惜当时没有去看脚本写的是啥，不然没准知道是怎么实现的。

虽然可以自己写一个简单的服务，但是...

这两天在查相关的东西时，发现一个好玩的东西 [transfer.sh](https://github.com/dutchcoders/transfer.sh) ，这个可以满足上述的需求。

# 1 正文

[transfer.sh](https://github.com/dutchcoders/transfer.sh) 是用Go写的一个文件服务，支持多种平台。存储源支持本地和部分云。

下载解压后就可以直接运行。但是官方并没有直接给运行的示例，参数都列了出来。我使用以下参数运行(封装成了启动脚本)。

```bash
#!/bin/bash

# transfer 解压后重命名了
# 存储放在本地
# 端口 设置为 4993
# 服务内路径
# 本地存放文件的路径
./transfer \
--provider=local \
--listener :4993 \
--temp-path=/data/ \
--basedir=~/TestEnv/transfersh/data/
```

通过以上参数就可以启动服务。

![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-09-14-21-46-43.png)

作为分享文件用的服务，它其实只是起一个中转站的作用。应该要有定时清除文件的功能。这个可以通过两个参数指定。

- purge-days 自动清除上传N天后的文件
- purge-interval 清除的时间间隔

具体参考[官方文档](https://github.com/dutchcoders/transfer.sh)。

启动成功之后可以在浏览器上打开 localhost:4993

![transfer.sh web](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-09-14-00-55-48.png)

按照页面上的提示上传文件，可以使用 curl ，或者直接在web页面上上传文件。官方也封装了 curl 的一个脚本 transfer，但是我复制下来换来自己的IP后不能用的。所以自己写了一个简单的。

```bash
#!/bin/bash

if [ $# -eq 0 ]; then
    echo "缺少参数 文件路径 如 transfer foo.txt | transfer ../bar.txt"
    return 1
fi

server="192.168.31.120:4993"

file="$1"
file_name=$(basename "$file")

if [ ! -e "$file" ]; then
    echo "$file: No such file or directory" >&2
    return 1
fi

result=$(curl --upload-file $file "$server/$file_name")

if [ $? -eq 0 ]; then
    echo -e "\n下载链接: $result"
fi
```

将脚本添加到环境变量中。

![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-09-14-21-51-57.png)

# TODO

- [ ] 官方文档其他操作封装
- [ ] 身份认证
- [ ] 二维码
