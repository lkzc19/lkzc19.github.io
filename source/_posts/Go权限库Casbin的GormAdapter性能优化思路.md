---
title: Go权限库Casbin的GormAdapter性能优化思路
date: 2024-05-01 14:38:42
tags: Golang
---

# 1. 背景

前段时间接到一个需求是关于权限的。组内讨论使用Casbin这个权限库来做。

Casbin的权限校验是通过`model`和`policy`来判断的。设置`model`和`policy`后，某条`policy`能通过`model`，`policy`中的权限就是可以使用的。

现在我使用官网上提供的[GormAdapter](https://github.com/casbin/gorm-adapter)用于`policy`的持久化。持久化保存的数据是用户与他能访问的接口，大致如下:

| v0 | v1 | v2 |
| - | - | - |
| nahida | /v1/foo | allow |
| nahida | /v1/bar | deny |
| hutao | /v1/bar | allow |
| hutao | /v1/bar | allow |

需求中的有几个功能是涉及到大量修改(包括新增或删除)这张表(`casbin_rule`)的，导致接口很慢。

# 2. 遇到的问题

[demo地址](https://github.com/lkzc19/demo/tree/main/goz/casbinz)

> 以下测试数据量都是在20万条左右。

```go
// 加载Policy
err := e.LoadPolicy()
checkErr(err)

for i := 0; i < 200000; i++ {
  _, err := e.AddPolicy("million"+strconv.Itoa(i), "data1", "read")
  checkErr(err)
}

// 保存policy更改
err = e.SavePolicy()
checkErr(err)
```

在如上的代码中，看到SQL日志时，发现在新增`policy`时，持久化到数据库中是一条条插入的，在大量插入数据的情况下导致速度变的非常慢。除此之外我还看到了批量插入。

在官网对GormAdapter的README中的**Simple Example**是这样的:

```go
func main() {
  // 初始化 省略

	// Load the policy from DB.
	e.LoadPolicy()
	
	// Check the permission.
	e.Enforce("alice", "data1", "read")
	
	// Modify the policy.
	// e.AddPolicy(...)
	// e.RemovePolicy(...)
	
	// Save the policy back to DB.
	e.SavePolicy()
}
```

这里的**Modify the policy.**和**Save the policy back to DB.**两句注释让我以为，所有的操作都是修改内存中的数据，要在最后使用`SavePolicy`方法才能保存到数据库中。

然而在看`AddPolicy`方法源码时才知道该方法会同时修改内存和数据库，所以才会看到一条条插入的SQL。

所以GormAdapter的所有操作时同时修改数据库的，在做大批量操作时不要使用如`AddPolicy`等单条数据操作的方法。

# 3. 解决方式

## 1. `AddPolicy`->`AddPolicies`

点到源码中看到了一个批量添加的方法`AddPolicies`。

只要讲上面的代码需改为如下:

```go
pSet := make([][][]string, 0)

p := make([][]string, 0)
for i := 0; i < 200000; i++ {
  if len(p) == 1000 {
    pSet = append(pSet, p)
    p = make([][]string, 0)
  }
  p = append(p, []string{"millionx" + strconv.Itoa(i), "data1", "read"})
}
if len(p) > 0 {
  pSet = append(pSet, p)
}

for _, it := range pSet {
  _, err := e.AddPolicies(it)
  checkErr(err)
}
```

这样在看日志时发现，插入方式已经改为了批量插入了。

## 2. `LoadPolicy` & `SavePolicy`

在加载规则时发现了慢SQL，大概需要700s左右。后来在测试`LoadPolicy`和`SavePolicy`方法时这两个方法加起来的耗时时间大概在10s左右。

既然GormAdapter所有操作都是修改数据，那么这两个方法分别在项目启动前和项目停止前执行一次即可，不需要每个接口都执行。

## 3. 除insert之外的操作优化方式

修改和删除的操作并没有批量的操作。如要将一批用户的某几个接口访问规则删除或者更改，这样在实际上的修改删除SQL是一条条执行的。导致速度很慢。

这个是我在实际工作中遇到的，当我把新增的改为批量后，接口速度已经由原来的1分钟左右降至2秒左右(大概是1万左右的数据量)。但是如果涉及修改删除的操作，速度就和原来差不多。

既然这样就全部改成新增操作，原先的删除修改后的结果都算好，将相关原先数据全都删除(这样就是批量了)，再将算好数据批量插入。

> 这部分并不在demo中。

# 4. demo的测试结果

只是自己写的demo测试，且没有测试多次，所以并不是很严谨。

| 用例 | 说明 | 耗时 |
| - | - | - |
| AddPolicy | 单条插入 | 4m48s |
| AddPolicies | 批量插入(1000条) | 5s |
| AddPolicy + LoadPolicy + SavePolicy | - | 5m |
| AddPolicies + LoadPolicy + SavePolicy | - | 15s |
