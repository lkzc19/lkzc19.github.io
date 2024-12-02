---
title: 【墙】Homebrew下载包失败解决方法
date: 2024-11-22 23:46:53
tags: Mac
categories: 墙
---

# 解决方案

在Homebrew下载失败后会输出包的下载地址，使用该地址下载包，将下载地址使用**sha256**加密获取到的字符串与下载的包的包名以如下格式

```makedown
xxx--yyy

xxx: 加密后的字符串
yyy: 下载的包名，包含拓展名
```

拼接作为新包名。将包放于`$(brew --cache)/downloads`目录下，再执行brew安装包的命令即可。

例如，我在下载ngrok时失败，我将其下载地址

`https://bin.equinox.io/a/eb5fgv4hujc/ngrok-v3-3.18.4-darwin-arm64.zip`

使用[sha256加密](https://www.jyshare.com/crypto/sha256/)(网上随便搜的一个工具)，加密得到

`1f26b4ccf5a09963b6ee0f93c1ecaea584288cf7f52673b22ddb7433a7619b93`

将其和下载到的包名拼接作为新包名

`1f26b4ccf5a09963b6ee0f93c1ecaea584288cf7f52673b22ddb7433a7619b93--ngrok-v3-3.18.4-darwin-arm64.zip`

将这个包放到`$(brew --cache)/downloads`目录下，再执行`brew install ngrok`，就会找到这个包进行安装。

