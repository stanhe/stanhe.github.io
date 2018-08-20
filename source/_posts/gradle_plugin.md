---
title: Create your gradle plugin
date: 2017-3-19 21:25:01
tags: gradle
---
![Gradle](http://oanvj2lsv.bkt.clouddn.com/gradle/icon_gradle_plugin.png)
<center> reuse your gradle plugin </center >
<!---more--->
### 什么是 gradle plugin
gradle 插件指我们的build.gradle文件中的： apply plugin: 'your_plugin'，自定义的plugin能够完成我们想要的功能，在不同的project中进行快捷的引用。

### 编写一个gradle plugin。
作为示例，这里编写一个Android中 常用的versionCode自增插件，目的在于我们打包的时候版本自增。
#### 新建插件包目录结构及文件
![目录](http://oanvj2lsv.bkt.clouddn.com/gradle/structure.png)
Android工程主目录下新建插件包，即 Project的 build.gradle同级目录下新建 autoaddversioncode包.
settings.gradle中增加依赖Module。
```
include ':app','autoaddversioncode'
```
上面的方法和 new Module是一个性质，区别在于上面的方法可以创建空目录，不会生成多余的结构,如果new Module需要删除多余的目录结构。

最终结构图如下：
```
autoaddversioncode
            |
            +------ src
            |         |
            |         +-----main
            |                 |
            |                 +------ groovy
            |                 |          |
            |                 |          +---- com.stan.addversioncode
            |                 |                                 |
            |                 |                                 +------ AddGradle.groovy
            |                 |                                 |
            |                 |                                 +------ AddManifest.groovy
            |                 |                                 |
            |                 |                                 +------ AddVersionCode.groovy
            |                 |                                 |
            |                 |                                 +------ VersionFile.groovy
            |                 |
            |                 +--------- resources
            |                                |
            |                                +------ META-INF.gradle-plugins
            |                                                 |
            |                                                 +----- addversioncode.properties
            +-------- build.gradle
```
#### groovy and properties
com.stan.addversioncode内是插件的实现代码，properties是插件入口定义。

VersionFile类，用于在app；build.gradle目录下定义extention 类，获取外部参数
```
package com.stan.addversioncode;

public class VersionFile {
    def desFile = "gradle";
}
```

AddGradle类，实现build.gradle内的versionCode自增逻辑
```
package com.stan.addversioncode

import org.gradle.api.DefaultTask
import org.gradle.api.tasks.TaskAction
import java.util.regex.Pattern


public class AddGradle extends DefaultTask{
    @TaskAction
    addGradleFile () {
        try {
            def buildFile = project.file("build.gradle")
            def buildText = buildFile.getText()
            println("project buildText : ${buildText}")
            def matcher = Pattern.compile("versionCode (\\d+)").matcher(buildText)
            matcher.find()
            def versionCode = Integer.parseInt(matcher.group(1))
            def newBuildText = matcher.replaceAll("versionCode " + ++versionCode)
            buildFile.write(newBuildText)
        }catch (Exception e){
            e.printStackTrace()
            println("<----- exception ----->")
        }
    }
}
```

AddVersionCode 插件入口
```
package com.stan.addversioncode

import org.gradle.api.Plugin
import org.gradle.api.Project

public class AddVersionCode implements Plugin<Project> {
    @Override
    void apply(Project project) {
        project.extensions.create("versionFile",VersionFile)
        project.task("startAddGradle",type:AddGradle)
        //使用 hello task 测试。
        project.task("hello",dependsOn: 'startAddGradle')<<{ task ->
            if (task.name == "hello") {
                if (project.versionFile.desFile == "gradle") {
                    println("this is gradle")
                }else if (project.versionFile.desFile == "manifest"){
                    println("this is manifest")
                }else if (project.versionFile.desFile == "all"){
                    println("this is all")
                }
            }
        }
        //正常情况下应该是
        project.tasks.whenTaskAdded{task->
             if (task.name == "generateReleaseBuildConfig") {
                            if (project.versionFile.desFile == "gradle") {
                                task.dependsOn 'startAddGradle'//需要依赖实例
                            }else if (project.versionFile.desFile == "manifest"){
                                task.dependsOn AddManifest
                            }else if (project.versionFile.desFile == "all"){
                                task.dependsOn AddGradle,AddManifest
                            }
        }

    }
}
```

然后 在addversioncode.properties 中定义插件入口类
```
implementation-class = com.stan.addversioncode.AddVersionCode
```

#### 最后 插件目录下的 build.gradle 文件内部定义插件信息

```
apply plugin: 'groovy'
apply plugin: 'maven'

dependencies {
    compile gradleApi()
    compile localGroovy()
}

repositories {
    mavenCentral()
}

group = 'com.stan.auto.plugin'
version='1.0.13'
uploadArchives{
    repositories{
        mavenDeployer{
            repository(url:uri('../repo')) //本地仓库
        }
    }
}
```

至此插件就已经完成了，现在rebuild工程右边就会出现如下结构图点击upload uploadArchives上传版本到本地仓库
![](http://oanvj2lsv.bkt.clouddn.com/gradle/app_gradle.png)

### Test gradle plugin

最后当然是测试了。app:build.gradle中引用插件
```
apply plugin: 'com.android.application'
apply plugin: 'addversioncode'

buildscript{
    repositories{
        maven{
            url uri('../repo')
        }
    }
    dependencies{
        classpath 'com.stan.auto.plugin:autoaddversioncode:1.0.13'
    }
}

versionFile{
   desFile  = 'gradle'
}

android {
    ......
}
```
以上示例会在Gradle projects 包目录下的和 upload 同级的 Other下生成 hello task，点击hello运行，会自增 :app 下的 build.gralde中的versionCode，插件功能完成。

至此插件编辑完成，现在只需要上传到binary仓库就可以分享该插件了。上传参考下面的文章。

### 参考文章
[如何使用Android Studio开发Gradle插件](http://blog.csdn.net/sbsujjbcy/article/details/50782830)
[自定义Gradle插件](http://blog.csdn.net/liuhongwei123888/article/details/50541759)

### 源码
[源码地址](https://github.com/stanhe/GradlePlugin)
