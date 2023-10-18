---
title: Node.js版本管理工具 NVM
date: 2023-10-17 23:19:40
tags: Node.js
---

# 0 前言

在使用 node 开发时，发现有些包要特定的版本才可以配合使用。我使用 brew 安装的，虽然也可以做一些简单的版本管理，但是 brew 中的 node 版本还是太少了。所以还是需要一个正经的 node 版本管理工具 —— nvm。

```bash
# 查看有哪些版本的node
brew search node
# 安装指定版本的node
brew install node@<version>
# 列出已安装的node
brew list --versions node
# 切换node版本
brew switch node <version>
```

# 1 正文 (MacOS)

## 安装配置

上 [官网](https://github.com/nvm-sh/nvm/releases) 下载 nvm。

我将其解压后放到了 `~/Applications` 目录中(官方推荐放在 `~/.nvm`下)。配置环境变量，在 .zshrc 中添加如下内容：

```bash
# nvm的home目录
export NVM_HOME="$HOME/Applications/nvm-0.39.5"
# 检查是否有这文件，如果有就执行
[ -s "$NVM_HOME/nvm.sh" ] && \. "$NVM_HOME/nvm.sh"
[ -s "$NVM_HOME/bash_completion" ] && \. "$NVM_HOME/bash_completion"
# 设置nvm镜像(淘宝)，没有配置下载很慢 io.js就不配置了
export NVM_NODEJS_ORG_MIRROR=https://npm.taobao.org/mirrors/node/
```

然后刷新 `source ~/.zshrc` 即可。

## 使用

```bash
# 查看当前使用版本
nvm current
# 查看安装的node
nvm ls
# 查看可安装的node版本
nvm ls-remote
# 查看可安装的长期支持版的node版本
nvm ls-remote --lts
# 安装node 只写大版本号是安装该版本号的长期支持版本
nvm install <version>
# 切换node版本 直接大版本号就可以切换
nvm use <version>
```



---
参考&拓展资料



拓展资料

- [管理 node 版本，选择 nvm 还是 n？](https://fed.taobao.org/blog/taofed/do71ct/nvm-or-n/?spm=taofed.homepage.header.7.7eab5ac8dDRkRS) (2015)
- [何为 Io.js](https://zhuanlan.zhihu.com/p/19914290) (2014)