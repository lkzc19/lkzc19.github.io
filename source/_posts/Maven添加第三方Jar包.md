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
<artifactId>mm</artifactId>
<version>1.0-SNAPSHOT</version>
```

如果需要补充依赖版本则猜测，或者看客户给的 libs 包中的其他 jar 包来补充。

将创建好的 pom 安装到本地仓库，安装方式与 jar 差不多，将 `-Dpackaging` 参数改为 `pom`。

```bash
mvn install:install-file -Dfile=/path/to/xx.pom -DgroupId=xyz.lkzc19 -DartifactId=mm -Dversion=1.0-SNAPSHOT -Dpackaging=pom
```

> 经过测试，依赖包的定位是靠安装指定的 GAV 定位，所以注意安装时的 GAV 与 pom 文件中**依赖(包含 parent)**的 GAV 要保持一致。而安装 jar 包时，可以不用管这个 jar 包定义**本身**的 GAV。

如果在使用 `java -jar` 时出现

- 没有主清单属性
- NoClassDefFoundError异常

需要如下配置，来添加主类且将依赖也打包进 jar 包，注意替换主类等参数。

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-shade-plugin</artifactId>
    <version>3.1.1</version>
    <configuration>
    </configuration>
    <executions>
        <execution>
            <phase>package</phase>
            <goals>
                <goal>shade</goal>
            </goals>
            <configuration>
                <transformers>
                    <transformer implementation="org.apache.maven.plugins.shade.resource.ManifestResourceTransformer">
                        <mainClass>org.example.Main</mainClass>
                    </transformer>
                </transformers>
            </configuration>
        </execution>
    </executions>
</plugin>
```

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

需要要指定类路径：

```bash
# 指定单个jar包
java -cp "target/pkg-1.0-SNAPSHOT.jar:target/libs/common-1.0-SNAPSHOT.jar" org.example.Main
# 指定一个目录
java -cp "target/pkg-1.0-SNAPSHOT.jar:target/libs/*" org.example.Main
```

> 注意加上引号，避免因为通配符出现问题。

有时候指定类路径不是很方便，这时候最好将依赖包也打进 jar 包。上面提到的 `shade` 插件不能满足需求，使用 `assembly` 插件来完成，注意修改主类等参数。

```xml
<plugin>
    <artifactId>maven-assembly-plugin</artifactId>
    <configuration>
        <archive>
            <manifest>
                <mainClass>org.example.Main</mainClass>
            </manifest>
            <manifestEntries>
                <Class-Path>.</Class-Path>
            </manifestEntries>
        </archive>
    </configuration>
    <executions>
        <execution>
            <id>make-assembly</id>
            <phase>package</phase>
            <goals>
                <goal>single</goal>
            </goals>
            <configuration>
                <descriptors>
                    <descriptor>src/assembly/assembly.xml</descriptor>
                </descriptors>
            </configuration>
        </execution>
    </executions>
</plugin>
```

在指定的位置添加配置文件 assembly.xml。

```xml
<assembly>
    <id>jar-with-dependencies</id>
    <formats>
        <format>jar</format>
    </formats>
    <includeBaseDirectory>false</includeBaseDirectory>
    <dependencySets>
        <!-- 默认的配置 -->
        <dependencySet>
            <outputDirectory>/</outputDirectory>
            <useProjectArtifact>true</useProjectArtifact>
            <unpack>true</unpack>
            <scope>runtime</scope>
        </dependencySet>
        <!-- 增加scope类型为system的配置 主要增加了scope类型为system的配置；这样在打包的时候，就会把本地jar也打包进去-->
        <dependencySet>
            <outputDirectory>/</outputDirectory>
            <useProjectArtifact>true</useProjectArtifact>
            <unpack>true</unpack>
            <scope>system</scope>
        </dependencySet>
    </dependencySets>
</assembly>
```

打出的带 `jar-with-dependencies` 后缀的 jar 包就可以直接运行。

---

参考：

1. [maven-assembly-plugin打包 scope system 级别文件](https://www.wxyaonline.top/article/7f3653b1-cd96-4ec3-acca-ed3aacf51efc)