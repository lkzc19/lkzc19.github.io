---
title: 【Github Actions】Maven打包&Docker镜像制作推送
date: 2024-01-20 15:23:02
tags: Github Actions
---

# 目标

git 提交后或者打标签后，自动打包并推送镜像到 Dockerhub (或者是 Github Container Registry)。

Kotlin + SpringCloud 微服务项目，需要制作多个镜像并推送，使用Maven做构建工具。

# workflows 配置

```yml
name: Docker Image

on:
  push:
    tags:
      - "v*"

env:
  DOCKER_REPO_N_GATEWAY: ghcr.io/nahidalibrary/galaxy/n-gateway
  DOCKER_REPO_N_SVC_CORE: ghcr.io/nahidalibrary/galaxy/n-svc-core

jobs:
  build:

    runs-on: ubuntu-latest

    steps:
      # 获取tag标签
      - name: Get version
        id: get_version
        # 提取标签 如 v1.0.0 并设置 VERSION=v1.0.0, 在后续step中使用
        run: echo ::set-output name=VERSION::${GITHUB_REF/refs\/tags\//} 
    
      - uses: actions/checkout@v3

      # 设置JDK版本
      - name: Set up JDK 11
        uses: actions/setup-java@v3
        with:
          java-version: '11'
          distribution: 'temurin'
          cache: 'maven'

      # 进行Maven打包且跳过测试
      - name: Build with Maven
        run: mvn -DskipTests=true package

      # 构建多种系统的镜像
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      # 登录 docker 镜像仓库
      - name: Login to GitHub Container Registry'
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      # 制作并推送镜像
      - name: Build and push n-gateway
        uses: docker/build-push-action@v5
        with:
          context: ./n-gateway
          file: ./n-gateway/Dockerfile
          platforms: |
            linux/amd64
            linux/arm64
          push: true
          tags: |
            ${{ env.DOCKER_REPO_N_GATEWAY }}:latest
            ${{ env.DOCKER_REPO_N_GATEWAY }}:${{ steps.get_version.outputs.VERSION }}

      - name: Build and push n-svc-core
        uses: docker/build-push-action@v5
        with:
          context: ./n-svc-core
          file: ./n-svc-core/Dockerfile
          platforms: |
            linux/amd64
            linux/arm64
          push: true
          tags: |
            ${{ env.DOCKER_REPO_N_SVC_CORE }}:latest
            ${{ env.DOCKER_REPO_N_SVC_CORE }}:${{ steps.get_version.outputs.VERSION }}
```

> 使用 Github Actions 前先在本地成功构建过镜像，保证 Maven 及 Dockerfile 配置正确。

大部分用官方 Actions 市场的组件就可以实现。

## 登录 docker 镜像仓库

`docker/login-action@v3` 组件用于登录 docker 仓库，默认登录到 DockerHub。配置如下：

```yml
- name: Log in to Docker Hub
  uses: docker/login-action@v3
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}
```

账密敏感信息配置在 `Settings -> Secrets and variables -> Actions` 的 Repository secrets 中。按以上方式使用。

如果需要登录到其他镜像仓库，需要修改 `registry` 值。这里是登录到 Github Container Registry。

```yml
- name: Login to GitHub Container Registry'
  uses: docker/login-action@v3
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

账密使用 `github.actor` 与 `secrets.GITHUB_TOKEN` 内置变量即可，无需配置。

## 构建及推送镜像

`docker/build-push-action@v3` 组件用于构建镜像并推送到仓库。

```yml
- name: Build and push n-gateway
  uses: docker/build-push-action@v5
  with:
    context: ./n-gateway
    file: ./n-gateway/Dockerfile
    platforms: |
      linux/amd64
      linux/arm64
    push: true
    tags: |
      ${{ env.DOCKER_REPO_N_GATEWAY }}:latest
      ${{ env.DOCKER_REPO_N_GATEWAY }}:${{ steps.get_version.outputs.VERSION }}
```

项目结构如下

```Markdown
.
├── n-gateway
│   └─ Dockerfile
└── n-svc-core
    └─ Dockerfile
```

主要看的还是 `context` 与 `file` 两个参数。这两个参数都需要从项目根目录开始写。

微服务中有多个服务，则多写几个这样的步骤。

每次推送镜像都打两个tag，latest 指向最新的镜像，方便更新。还有一个则取git tag作为镜像版本。

取 git tag

```yml
# 获取tag标签
- name: Get version
  id: get_version
  # 提取标签 如 v1.0.0 并设置 VERSION=v1.0.0, 在后续step中使用
  run: echo ::set-output name=VERSION::${GITHUB_REF/refs\/tags\//}

# 在后续的步骤 
${{ steps.get_version.outputs.VERSION }}
```
