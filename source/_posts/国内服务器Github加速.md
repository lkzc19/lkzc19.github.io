---
title: 国内服务器Github加速
date: 2024-01-21 14:17:14
tags: Github
---

在阿里云上拉取 Github 上的代码，拉取失败。以及拉取 Github(ghcr.io) 中的 docker 镜像速度很慢。

**Github代码拉取失败解决方案**

在`/etc/hosts`文件中添加以下内容

```
140.82.112.3 github.com 
185.199.108.133 raw.githubusercontent.com
```

可通过 [ipaddress.com](https://www.ipaddress.com/ip-lookup) 网站查询 域名的ip。

**Github的Docker镜像仓库加速**

如果是 docker 官方的镜像仓库，在docker配置文件配置上国内的 docker 镜像源就好。

`/etc/docker/daemon.json`

```json
{
  "registry-mirrors": [
    "https://registry.docker-cn.com" // Docker 官方中国区
  ]
}
```

如果是 Github 的镜像仓库(ghrc.io)，则可以使用 [DaoCloud](https://github.com/DaoCloud/public-image-mirror) 镜像站。

按官方文档 先跑起服务

```bash
docker run -d -P m.daocloud.io/docker.io/library/nginx
```

将镜像地址替换，以我要部署的docker-compose.yml为例:

```yml
version: '3'
services:
  n-gateway:
    image: ghcr.io/nahidalibrary/galaxy/n-gateway:latest
    container_name: n-gateway
    restart: always
    ports:
      - "9100:9100"
    networks:
      - nahida-networks
networks:
  nahida-networks:
```

只需要在镜像地址前加一个前缀 `m.daocloud.io` 即可。

```markdown
ghcr.io/nahidalibrary/galaxy/n-gateway:latest => m.daocloud.io/ghcr.io/nahidalibrary/galaxy/n-gateway:latest
```
