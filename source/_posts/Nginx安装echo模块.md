---
title: Nginx安装echo模块
date: 2024-12-18 01:38:27
tags: Nginx
---

最近接到一个需求，要将到Nginx的请求体打印出来，做日志收集处理。`echo-nginx-module`模块可以满足需求。

# 1. 环境

- CentOS 9
- [nginx/1.24.0](http://nginx.org/download/nginx-1.26.2.tar.gz)
- [echo v0.61](https://github.com/openresty/echo-nginx-module/archive/refs/tags/v0.61.tar.gz)

# 2. 编译安装

获取包，相关包也可直接在浏览器下载。

```bash
wget http://nginx.org/download/nginx-1.24.0.tar.gz
tar -zxf nginx-1.24.0.tar.gz

wget https://github.com/openresty/echo-nginx-module/archive/refs/tags/v0.61.tar.gz
tar -zxf v0.61.tar.gz
```

编译，可能会缺少一些系统依赖，根据报错安装相关依赖。

进入Nginx目录进行编译前配置。

```bash
cd nginx-1.24.0

# prefix 要安装的目录
# with 启用自带模块
# add-module 添加第三方模块 即echo的目录
./configure \
--prefix=/opt/module/nginx \
--with-http_stub_status_module \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_sub_module \
--with-http_gzip_static_module \
--add-module=/opt/software/v0.61
```

进行`configure`时出现缺少依赖。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/371f915135fea893107789beb7629d44.png)
![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/b50c9fe4b10cfddc3ce2bd0566ec12f7.png)

```bash
sudo yum groupinstall "Development Tools" -y
sudo yum install pcre pcre-devel -y
```

安装好依赖后再进行上面的配置，成功如图。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/9fb517e19af60d93a0011c9476b65274.png)

> error 高亮只是软件的问题

编译安装，会安装到之前配置的目录。

```bash
make -j2
make install
```

在进行编译时(`make -j2`)，出现缺少系统文件。是因为一开始使用`1.12`版本的Nginx，但是系统是CentOS9，所以选了一个更新的Nginx进行编译，解决该问题。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/a9dcfae963ce2c96fc6a4f5c1e0a513b.png)

编译成功如图。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/4d454fb872826d8283361745aeb517b5.png)

# 3. 测试echo模块

nginx 添加如下配置。

```conf
location / {
    echo_read_request_body;
    echo "hello, nginx-echo!\n";
    echo "$request_body";
}
```

发送请求测试。

```bash
curl localhost:80 -d "foo"
```

可以看到echo的输出，请求体也成功输出。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/lkzc19.github.io/0edd50f8920ac73ecae2cb609cd3174c.png)
