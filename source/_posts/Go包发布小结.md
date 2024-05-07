---
title: Go包发布小结
date: 2024-05-07 22:04:24
tags: Golang
---

> 建议直接看这篇[如何优雅地发布 go module 模块到 pkg.go.dev](https://blog.golang.im/how-to-release-go-module/)，此篇不过是自己尝试后的一个记录。

# 1. 发布Go包到`pkg.go.dev`

[nlu 发布Go包的示例项目](https://github.com/lkzc19/nlu)

创建一个go项目，`go.mod`内容如下:

```mod
module github.com/lkzc19/nlu

go 1.21
```

模块名即github仓库地址。

需要git仓库是公开的。在推送代码到远程仓库，直接在github上用[模版](https://docs.github.com/zh/communities/setting-up-your-project-for-healthy-contributions/adding-a-license-to-a-repository)给项目添加一个`LICENSE`。

> 不添加LICENSE，`pkg.go.dev`上会显示相关问题。[支持证书查看](https://pkg.go.dev/license-policy)。

打一个tag v0.0.1后就可以拉取依赖。

```bash
go get -u github.com/lkzc19/nlu
```

> 在官方文档中中说是如果没有打tag，即拉取到的依赖就是最新的代码。但是未尝试。

在第一次拉取依赖后几分钟，就会在`pkg.go.dev`上搜索到。如果从未拉取过则不会出现。

![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2024-05-07-22-57-57.png)

并且在[demo](https://github.com/lkzc19/demo/blob/main/goz/langz/internal/pkg_test.go)中使用该依赖。

# 2. 思考

1. 为什么推到github上，使用`go get`就可以出现在`pkg.go.dev`？那gitee可以吗？。
2. 自建git仓库如何发包及引包？

# 0. 参考资料

- [如何"优雅"地发布自己的 go module 模块到 pkg.go.dev](https://www.bilibili.com/read/cv21221484/)
- [pkg.go.dev about](https://pkg.go.dev/about)
- [proxy.golang.org](https://proxy.golang.org/)
- [Github添加许可证到仓库](https://docs.github.com/zh/communities/setting-up-your-project-for-healthy-contributions/adding-a-license-to-a-repository)