---
title: Windows Terminal 美化
date: 2023-10-03 12:14:18
tags: Windows
---

# Windows Terminal 下载

上 [github](https://github.com/microsoft/terminal/releases) 下载对应版本。

# 字体下载及安装

因为之后需要安装 oh-my-posh 美化终端，需要其能支持一些特殊字体，而系统自带字体是不支持的。

官方字体推荐 [Nerd Fonts](https://www.nerdfonts.com/font-downloads)

下载解压字体文件后，打开设置中的字体，直接拖入即可。
![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-10-06-22-06-04.png)

Windows Terminal 字体设置

![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-10-06-22-15-14.png)
![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-10-06-22-17-00.png)

# oh-my-posh(omp) 安装及配置

## scoop 包管理器安装配置

omp 建议直接使用 windows 的包管理器安装。或者直接上 [github](https://github.com/JanDeDobbeleer/oh-my-posh/releases) 上下载

我使用的是 [scoop](https://scoop.sh/) 包管理器，还有其他如 winget、choco。按照官网上的教程安装 scoop，直接在终端输入以下命令:

```bash
Set-ExecutionPolicy
irm get.scoop.sh | iex
```

## oh-my-zsh 安装

安装完 scoop 后，就可以安装 omp 了。

```bash
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
```

## 主题设置

上[官网](https://ohmyposh.dev/docs/themes)下载主题文件。位置推荐放到 omp 的 home 目录中的 themes 目录中（没有 themes 目录就创建一个）。

> 如果是按该文章来的话，omp 是使用 scoop 安装的，scoop 默认安装在用户的 home 目录下，则 omp 在 scoop 目录中的 apps 目录中。

![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-10-06-22-37-56.png)

在终端输入 $Profile 出现配置文件路径，如果则在此路径下创建文件:

```bash
# %HOME% 用户的home目录，注意替换
# Microsoft.PowerShell_profile.ps1 配置文件名

%HOME%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1
```

在配置文件中编写以下配置

```bash
oh-my-posh --init --shell pwsh --config <配置文件路径> | Invoke-Expression
```

保存后，Windows Terminal 重启即可生效。

我挑了比较简约的主题，效果如下:

![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-10-06-22-52-15.png)

美化之前

![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2023-10-06-22-49-07.png)

如果不满意现有主题配置，可以根据[官网文档](https://ohmyposh.dev/docs/configuration/general)自定义配置。还可以根据自己的需求配置如 Git 相关信息的显示，编程语言的相关显示。如果不想看那么多的文档，可以直接下载一个比较喜欢的主题，以其为基本，改成自己喜欢的。

---

参考文章：

- [Windows包管理器Scoop&Winget](https://blog.csdn.net/sorcererr/article/details/131147319)
- [Oh My Posh：全平台终端提示符个性化工具](https://sspai.com/post/69911)

