---
title: Maven添加第三方Jar包
date: 2025-01-04 23:30:33
tags: Maven
---

最近接到一个需求，其中一个步骤是解密客户数据，给了一个 jar 包，所以需要将 jar 包打到项目依赖中。

有两种方法：

- 将 jar 包添加到本地 Maven 仓库，再进行引入。
- 将 jar 放入项目中，再进行引入。

# 1. 本地 Maven 仓库

使用命令将 jar 包安装到本地仓库。

```bash
mvn install:install-file -Dfile=/path/to/xx.jar -DgroupId=xyz.lkzc19 -DartifactId=mm-common -Dversion=1.0.0 -Dpackaging=jar
```

groupId、artifactId、version(后续都写为GAV) 即是后续在在pom文件中引用的坐标，不需要和这个 jar 包实际的 GAV 对应上。

在项目中引用。

```xml
<dependency>
    <groupId>xyz.lkzc19</groupId>
    <artifactId>mm-common</artifactId>
    <version>1.0.0</version>
</dependency>
```

这样一般来说就可以使用这个包了，但是如果这个包是一个子模块，就会报错缺少父 pom 文件。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/default/5322205ba0ab38a491dc8715be3d63f7.png)

解决方法是根据这个 jar 包的 pom 文件来写一个 父 pom 文件。

子 pom 文件如下：

```xml
<parent>
    <groupId>org.example</groupId>
    <artifactId>mm</artifactId>
    <version>1.0-SNAPSHOT</version>
</parent>
<artifactId>common</artifactId>
```

则父 pom 文件就如下：

```xml
<groupId>org.example</groupId>
<artifactId>pkg</artifactId>
<version>1.0-SNAPSHOT</version>
```

如果需要补充依赖版本则猜测，或者看客户给的 libs 包中的其他 jar 包来补充。

# 2. 项目中添加 libs 目录

在 pom 文件所在的目录下创建 libs 目录来存放 jar 包。在 pom 中引入。

```xml
<dependency>
    <groupId>xyz.mm-common</groupId>
    <artifactId>common</artifactId>
    <version>1.0.0</version>
    <scope>system</scope>
    <systemPath>${project.basedir}/libs/common-1.0-SNAPSHOT.jar</systemPath>
</dependency>
```

> 不确定 `project.basedir` 在哪边可以按住 `ctrl` + 左键跳转看下，IDEA是可以的。

刷新 pom 文件后，jar 包就可以展开查看了。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/default/a460a1a09a0f498af34b536c69111c3d.png)

添加插件，打包的时候将 libs 目录也输出到 target 中。

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-resources-plugin</artifactId>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>copy-resources</goal>
            </goals>
            <configuration>
                <outputDirectory>${project.build.directory}/libs</outputDirectory>
                <resources>
                    <resource>
                        <directory>${project.basedir}/libs</directory>
                        <includes>
                            <include>*.jar</include>
                        </includes>
                    </resource>
                </resources>
            </configuration>
        </execution>
    </executions>
</plugin>
```

可以看到输出目录如下：

![](https://raw.githubusercontent.com/lkzc19/nimg/main/default/9eeefbc80164033e66c68af4d55b5180.png)

直接运行运行 `java -jar` 会报错找不到类。

![](https://raw.githubusercontent.com/lkzc19/nimg/main/default/6437cf4774618b6cded5ee267737cf19.png)

> 如果是报找不到主类，需要配置插件 `maven-jar-plugin`。

需要要指定类路径：

```bash
# 指定单个jar包
java -cp "target/pkg-1.0-SNAPSHOT.jar:target/libs/common-1.0-SNAPSHOT.jar" org.example.Main
# 指定一个目录
java -cp "target/pkg-1.0-SNAPSHOT.jar:target/libs/*" org.example.Main
```

> 注意加上引号，避免因为通配符出现问题。
