---
title: Go依赖注入工具wire使用小结
date: 2024-04-24 22:44:31
tags: Golang
---

# 1. 手动依赖注入 & [wire](https://github.com/google/wire)

因为公司的项目计划，最近接触了Go语言。项目在刚开始开发的阶段时，并不打算使用wire一类的依赖注入工具。

但是在开发的过程中，我与同事逐渐产生分歧。

同事开发时手动的一层一层注入依赖，导致代码跳转了一层又一层，再加上接口抽象，导致我看的眼花缭乱(也可能是刚开始写Go的原因)。所以我果断放弃那种写法，创建一个container包，用来统一放实例，初始化各种实例都往这里面放，用则直接取这里面的。但也只是放这些最基础，对于如repo、service没有处理。

```go
const (
  DB    *gorm.DB
  Mongo *mongo.Database 
)
```

但是这样有一个坏处，就是不如同事写的依赖关系那么明显，项目稍微大点，就会变的很难维护。

最后经过讨论还是选择使用使用`wire`作为依赖注入的工具。

# 2. wire使用注意

基本的使用在官网的使用指南中已经很详细了，这里列举出我在使用时遇到的问题。

[demo地址](https://github.com/lkzc19/demo/tree/main/goz/wirez)

## 1. inject BuildInjector: unused provider set "Set"

```go
func BuildInjector(ctx context.Context) (*Injector, func(), error) {
	// 就算有依赖关系也没有顺序要求
	wire.Build(
		repo.Set,
		provider.Pgsql,
		provider.DB,
		provider.Mongo,
		provider.Sussurro,
		service.Set,
		wire.NewSet(wire.Struct(new(S), "*")),
		wire.NewSet(wire.Struct(new(Injector), "*")),
	)
	return new(Injector), nil, nil
}
```

在此中注入的所有对象，都要被使用。在上述代码片段中，是将所有的都放在`Injector`中导出，也算做被使用。

## 2. inject BuildInjector: no provider found for wirez/repo.BarRepo ...

全部报错如下:

```bash
wire: /Users/lkzc19/Projects/self/demo/goz/wirez/wirex/wire.go:13:1: inject BuildInjector: no provider found for wirez/repo.BarRepo
        needed by wirez/service.HelloService in provider set "Set" (/Users/lkzc19/Projects/self/demo/goz/wirez/service/wire.go:5:11)
        needed by wirez/wirex.S in provider set (/Users/lkzc19/Projects/self/demo/goz/wirez/wirex/wire.go:21:3)
        needed by *wirez/wirex.Injector in provider set (/Users/lkzc19/Projects/self/demo/goz/wirez/wirex/wire.go:22:3)
wire: wirez/wirex: generate failed
wire: at least one generate failure
make: *** [wirex] Error 1
```

是因为`repo.BarRepo`使用`wire.Bind`interface绑定struct，但是`service.HelloService`使用的是struct。

```go
// repo.BarRepo的注入方式如下
var Set = wire.NewSet(
    ProvideBarRepo,
    wire.Bind(new(IBarRepo), new(*BarRepo)),
)

type HelloService struct {
	FooRepo repo.IFooRepo
	// 此处使用的是struct，但是应该使用的是repo.IBarRepo
	BarRepo repo.BarRepo
}
```

# 3. 最佳实践

[官方提供的最佳实践](https://github.com/google/wire/blob/main/docs/best-practices.md)

以下是个人开发时总结。

## 1. 创建一个struct保存所有依赖(对应2.1的问题)

如demo中的`Injector`

```go
type Injector struct {
	Pgsql    common.PgsqlStr
	Mongo    common.MongoStr
	DB       common.DBStr
	Sussurro common.Sussurro
	S        S
}
```

除可以避免**未使用依赖**问题，还方便编写测试类。

## 2. 注入方式

尽可能使用`provider`来提供实例，这样会有更好的封装性，即`struct`不需要将内部的属性暴露出去。

```go
func ProvideFooRepo(db common.PgsqlStr) *FooRepo {
	return &FooRepo{db: db}
}
```

但如果像是业务层，需要很多依赖的`struct`还是使用`wire.Struct`方法，通配符`*`注入所有依赖。因为随着业务的发展，或者是开发阶段就可能需要经常改动，就很麻烦。

```go
wire.Struct(new(HelloService), "*")
```

> 如果某个属性不需要注入，使用标签`wire:"-"`即可。

## 3. Binding Interfaces VS 其他方式

在demo中repo层使用的是`Binding Interfaces`方式注入，这个其实在开发时造成了`2.2`的问题。

> 由于报错信息没有指明什么问题，导致我解决这个问题花了好久时间。

按照官方的原话讲，`Binding Interfaces`方式貌似并不推荐:

```markdown
Frequently, dependency injection is used to bind a concrete implementation for an interface. Wire matches inputs to outputs via type identity, so the inclination might be to create a provider that returns an interface type. However, this would not be idiomatic, since the Go best practice is to return concrete types.

通常，依赖注入用于绑定接口的具体实现。Wire 通过类型标识将输入与输出匹配，因此可能倾向于创建返回接口类型的提供程序。但是，这并不是惯用的，因为 Go 的最佳做法是返回具体类型。
```

我在实际工作中有使用`Binding Interfaces`方式，感觉用起来很麻烦。
看到网上说的好处，如切换具体实现方便，我暂时且感觉未来也不会有这种场景需要用到；
测试mock时方便，但实际开发中一般没这个时间去做这个，最多写一个单元测试跑一下方法是否正确。

所以我认为没有什么必要使用`Binding Interfaces`，使用`wire`其他的注入方式比较好些。

# 0. 参考资料

- [wire 官方文档](https://github.com/google/wire)
