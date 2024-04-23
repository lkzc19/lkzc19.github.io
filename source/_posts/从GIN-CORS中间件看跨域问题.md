---
title: 从GIN-CORS中间件看跨域问题
date: 2024-04-23 19:18:57
tags: Golang
---

# 1. 跨域

最近在使用[Gin](https://gin-gonic.com/zh-cn/docs/)开发项目时遇到跨域问题，直接使用了Gin官方的一个中间件[cors](https://github.com/gin-contrib/cors)做了处理。
使用了其默认的配置，但还是有跨域的问题。最后在同事和前辈的帮助下解决了。

遇到此问题的根本原因还是对其跨域的原理不够了解，虽然有很多权威文档如MDN，但是内容过多。
所以根据Gin的跨域中间件来学习下跨域原理及解决方式。

# 2. 同host不同port会有跨域问题吗？

前后端一体开发自然就不用说，同host同port。

前后端分离开发，在服务还未部署到服务器上时，前后端是不同host不同port，肯定跨域。

那如果是前后端都部署到服务上后(同一台机器)，同host不同port会出现跨域吗？

对此写了一个demo测试了一下。

- [demo前端: cors-axios](https://github.com/lkzc19/demo/tree/main/test/cors/cors-axios)
- [demo后端: cors-gin](https://github.com/lkzc19/demo/tree/main/test/cors/cors-gin)
- [nginx配置](https://github.com/lkzc19/demo/blob/main/nginxz/conf.d/test_cors.conf)

基本的请求流程: 前端 -> nginx -> 后端

简单的API文档

```markdown
# normal
POST 127.0.0.1:3000/normal
参数 body {name: "胡桃"}
返回 "bar"

# cors-bug
POST 127.0.0.1:3000/cors-bug
参数 body {name: "纳西妲"}
返回 "cors-bug"
```

cors-gin项目中对`normal`接口用gin-cors做了默认的跨域处理，`cors-bug`没做处理。

项目部署访问后则是`normal`接口正常，`cors-bug`出现跨域问题。

由此得出同host不同port还是会出现跨域问题。

# 3. 从Gin-CORS中间件看跨域问题

在工作期间调这个跨域问题时，使用中间件的默认配置后，还是有出现跨域的问题。但是登入接口没有问题，其中的差别就是登入接口没有传一个请求头`Authorization`。

中间件的默认配置是L:

```go
// DefaultConfig returns a generic default configuration mapped to localhost.
func DefaultConfig() Config {
	return Config{
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Length", "Content-Type"},
		AllowCredentials: false,
		MaxAge:           12 * time.Hour,
	}
}

// Default returns the location middleware with default configuration.
func Default() gin.HandlerFunc {
	config := DefaultConfig()
	config.AllowAllOrigins = true
	return New(config)
}
```

这里可以看到默认配置其实是没有对`Authorization`做一个放行的。所以导致有传入该请求头的接口都是有跨域问题的。报错类似下图:

![](https://raw.githubusercontent.com/lkzc19/blasphemy.zimg/main/drinkice/2024-04-23-21-54-22.png)

处理方式一般都是直接全部放行，源码注释中有相关注释，使用`*`通配符就可以了。

其实在使用这个中间件时，我有看了一眼源码，包括像其他框架的跨域处理如kotlin的ktor。但是由于对原理的不了解导致，不知道原来跨域对请求头也有要求，导致出现上面的问题。

gin的官方cors中间件对跨域处理肯定是相对完善的，那么则可以看官方是如何处理跨域的来了解跨域。

# 4. Gin-CORS中间件

在gin-cors中的`Config`结构体中有以下这些字段:

```go
type Config struct {
	AllowOrigins []string
	AllowMethods []string
	AllowHeaders []string
}
```

> 还有其他的配置，如对Origins的自定义处理方法，对其他协议的扩展，因为暂时不需要，所以不看。

从上面可以看出，会出现跨域问题的是

- `origins`即host和port
- `methods`即http方法
- `headers`即http请求头

这三种都放行基本就解决跨域问题了。

cors中间件对此处理的逻辑并不是很复杂就不贴出来了。但是有一点值得注意，如下代码:

```go
if c.Request.Method == "OPTIONS" {
  cors.handlePreflight(c)
  defer c.AbortWithStatus(cors.optionsResponseStatusCode)
}
```

这段代码是跨域逻辑处理中一小段，`OPTIONS`方法有时可以看到有时看不到，这是只有发送复杂请求时才会先发送一个`OPTIONS`的预检请求，如自定义的HTTP请求头时。

这里通过打断点看到处理逻辑是将以上三个数据(还有其他数据，有一个方法`generatePreflightHeaders`生成的)塞到响应头中，后续前端根据此判断是否跨域。

# 0. 参考资料

- [MDN 跨域 相关文档](https://developer.mozilla.org/en-US/docs/Web/HTTP/CORS)。


