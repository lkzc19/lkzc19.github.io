---
title: 常见Git工作流
date: 2024-01-10 21:39:24
tags: Git
---

# Git Flow

![Git Flow](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2024-01-10-21-42-29.png)

基本流程：

- 开发: main -> develop，开发基于 develop 分支创建临时的 future 分支进行新功能开发，最后合并到 develop 分支。
- 测试: develop -> release，测试基于 develop 分支创建临时的 release 分支进行测试，在补充文档和测试时的bug修复(基于release创建临时分支进行修复，修复完成后合并到 release 分支)后，合并到 main 分支进行发版。且在 release 分支上的修改也会合并到 develop 分支。
- 紧急bug修复: main -> hotfix，紧急bug修复基于 main 分支创建临时的 hotfix 分支进行修复，修复完成后合并到 main 分支进行发版。且将修改也合并到 develop 分支。

# Github Flow

![Github Flow](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2024-01-10-21-43-20.png)

基本流程(简化GitFlow)：

- 开发: main -> feature，feature分支长期存在，用于新功能开发，开发完后提PR到mian分支，审核通过后合并。
- 测试: 看样子是哪个 feature 分支出的问题就在哪个 feature 分支上修复，与开发是同一个流程。

# Gitlab Flow

![Gitlab Flow](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2024-01-10-21-43-41.png)

基本流程(中庸之道)：

main分支还是作为生产分支，如production、production是其他环境使用的分支，或者是在main分支的基础上做其他版本的开发

# 其他 Git 工作流

**Trunk-Based Development** 敏捷开发，比Github Flow还简单，需要较好的CI/CD基建，适合一天多个commit。

[OneFlow](https://www.endoflineblog.com/oneflow-a-git-branching-model-and-workflow)

# 关于自己使用 Git 工作流的思考

## 工作中

没有使用某个具体的工作流，而是在团队工作中根据需求逐渐的行成了一种工作流。

![mine](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2024-01-10-22-38-53.png)

一开始并没有明确的工作流，因为还没到测试和发版。我们从 main 分支中拉出 develop 作为长期开发的分支，开发都是基于该分支拉出临时分钟进行开发的。开发或者修复bug后合并到 develop 分支再合并到main分支。后来开始测试，索性将main分支作为测试分支且长期存在。与前端配合将 develop 部署到开发环境供其使用，将 main 分支部署到测试环境供测试使用。到需要发版时基于main分支拉出release分支，进行发版。

总体流程是 feature(代码开发) -> develop(前端使用) -> main(测试使用) -> release(发版)。

CI/CD 情况

- develop 只要有合并就会 自动打包且部署 到开发环境。
- main 打上测试tag后 自动打包且部署 到测试环境。
- release 打上发版tag后，自动打包，手动部署到生产。

main和release区别是生产环境得有权限的人来弄。

这里有一个问题是 如果测试有bug，需要先合并到develop再合并到main中，有写麻烦。按照 Git Flow来弄应该更合理。但考虑到我们是做业务开发，与其他团队要配合，main分支的bug可能也会影响到使用develop分支环境的前端开发。所以暂时没有找到更优的工作流。

但是 hotfix 应该还是可以加入的，在生产环境修复紧急bug，发一个补丁包。

## 个人

在个人写一些小玩意时，总会去模仿那些工作流(Git Flow)，但仔细看下来，感觉没有必要了，在工作中自然就会形成与工作相吻合的工作流。

适合当前开发的才是最好的，这也是写这篇文章的目的，找一个时候项目的工作流。所以以目前情况来看，我的个人项目(最多也就两三个人)开发工作流应该与 Github Flow 和 Trunk-Based Development 相似，利用 GitHub Actions，快速迭代。

---

画图工具: https://excalidraw.com/
参考视频: https://www.bilibili.com/video/BV1nC4y1B7W9