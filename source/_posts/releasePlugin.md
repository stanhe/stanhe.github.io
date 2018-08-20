---
title: publish plugin
date: 2017-3-22 11:25:01
tags: gradle
---
![Gradle](http://oanvj2lsv.bkt.clouddn.com/jitpack/jfrog.png)
写好了gradle插件,如果只能本地使用就太low了,怎么滴也要放到远程仓库,下次项目直接引用.然而上传过程中也是踩坑...
这里记录一下过程.
<!---more--->
### github 直接发布到 jitpack
#### release
github项目下 ---> releases ---> Draft a new release.填写发布信息.
![](http://oanvj2lsv.bkt.clouddn.com/jitpack/jitpack01.png)

#### 发布到jitpack仓库
git账号登陆,然后 输入 user/repository Look up,选择发布版本并 Get it.这时候前面有个Log,点进去 最下面往上看,BUILD SUCCESSFUL 表示成功提取并发布 Files:下面是发布的包中的文件
![](http://oanvj2lsv.bkt.clouddn.com/jitpack/jitpack02.png)

#### 使用
从上面发布图最后来看使用就和我们平时使用compile添加依赖一样.实际上至此一个正常的库就可以应用上面的方法来使用了.
然而,这里发布的是一个gradle插件,按如上方法添加依赖并不能让gradle认识它.所以添加方法不同
```
apply plugin: 'com.android.application'
apply plugin: 'addversioncode'

buildscript{
    repositories{
        jcenter()
        maven { url 'https://jitpack.io' }
    }
    dependencies{
        classpath 'com.github.stanhe:AutoAddVersionCode:1.0.2'
    }
}

versionFile{
    desFile = 'manifest'
}
```
如上使用了 classpath添加依赖.这特喵就可以了.为啥,引用stackoverflow 的[解答](http://stackoverflow.com/questions/34286407/gradle-what-is-the-difference-between-classpath-and-compile-dependencies)就是:
The compile configuration is created by the Java plugin. The classpath configuration is commonly seen in the buildSrc {} block where one needs to declare dependencies for the build.gradle, itself (for plugins, perhaps).

### 发布到jcenter
#### 添加发布的插件
项目根目录的build.gradle下添加
```
// Top-level build file where you can add configuration options common to all sub-projects/modules.

buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:2.1.3'

        classpath 'com.jfrog.bintray.gradle:gradle-bintray-plugin:1.0'
        classpath 'com.github.dcendents:android-maven-plugin:1.2'
        // NOTE: Do not place your application dependencies here; they belong
        // in the individual module build.gradle files
    }
}
```
#### 待发布的build.gradle下添加
```
apply from: '../bintray.gradle'
```
没错,只是把本来该写在这里的文件提出来单独写而已,毕竟发布的逻辑没必要写到插件本身里面

#### bintray.gradle
```
// 应用插件
apply plugin: 'com.jfrog.bintray'
apply plugin: 'maven-publish'

def baseUrl = 'https://github.com/stanhe'
def siteUrl = baseUrl
def gitUrl = "${baseUrl}/AutoAddVersionCode"
def issueUrl = "${baseUrl}/AutoAddVersionCode/issues"

install {
    repositories {
        mavenInstaller {
            // This generates POM.xml with proper paramters
            pom.project {

                //添加项目描述
                name 'Gradle Plugin for Android'
                url siteUrl

                //设置开源证书信息
                licenses {
                    license {
                        name 'The Apache Software License, Version 2.0'
                        url 'http://www.apache.org/licenses/LICENSE-2.0.txt'
                    }
                }
                //添加开发者信息
                developers {
                    developer {
                        name 'stanhe'
                        email 'hshl4314@gmail.com'
                    }
                }

                scm {
                    connection gitUrl
                    developerConnection baseUrl
                    url siteUrl
                }
            }
        }

    }
}

task sourcesJar(type: Jar) {
    from 'src/main/groovy'
    exclude 'META-INF'
    classifier = 'sources'
}

groovydoc {
    includePrivate = true
    source = 'src/main/groovy'
}

task groovydocJar(type: Jar, dependsOn: groovydoc) {
    classifier = 'javadoc'
    from groovydoc.destinationDir
}

artifacts {
    archives groovydocJar
    archives sourcesJar
}

Properties properties = new Properties()
properties.load(project.rootProject.file('local.properties').newDataInputStream())

//配置上传Bintray相关信息
bintray {
    user = properties.getProperty("bintray.user")
    key = properties.getProperty("bintray.apikey")

    configurations = ['archives']
    pkg {
        repo = 'maven' // 上传到中央仓库的名称
        name = 'AutoAddVerionCode' // 上传到jcenter 的项目名称
        desc = 'Auto add gradle versionCode when release' // 项目描述
        websiteUrl = siteUrl
        issueTrackerUrl = issueUrl
        vcsUrl = gitUrl
        labels = ['gradle', 'plugin']
        licenses = ['Apache-2.0']
        publish = true
        publicDownloadNumbers = true
    }
}

```
user和key被单独提出来放到local.properties下.
refresh gradle右边会出现一个 publishing文件 点击下面的 bintrayUpload上传到jcenter并add to Jcenter.


### 参考链接
[ Gradle插件开发](http://blog.csdn.net/wwj_748/article/details/52077118)
[上传Library到JCenter](http://blog.csdn.net/lisdye2/article/details/52292896)
[Writing Custom Plugins](https://docs.gradle.org/current/userguide/custom_plugins.html#sec:packaging_a_plugin)
[maven_publishing](https://docs.gradle.org/current/userguide/publishing_maven.html)