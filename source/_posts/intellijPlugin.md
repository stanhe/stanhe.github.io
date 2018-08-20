---
title: Create Intellij Plugin
date: 2017-3-13 12:10:13
tags: Intellij
---
![Intellij](http://oanvj2lsv.bkt.clouddn.com//intellJintellij_pic.png)
<center> Creating Your First Plugin </center >
<!---more--->
### [Download  IntelliJ IDEA Community Edition](https://www.jetbrains.com/idea/download/#section=mac) ![IDEA](http://oanvj2lsv.bkt.clouddn.com//intellJdownload.png)
### [编写插件](http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started.html)
#### 安装并打开IntelliJ IDEA新建工程
![](http://oanvj2lsv.bkt.clouddn.com//intellJstart.png)
#### 创建intelliJ platform plugin
如果没有Project SDK 点击new
![](http://oanvj2lsv.bkt.clouddn.com//intellJcreate.png)
#### 创建AnAction派生类
进入空工程项目Project下只有Src空文件夹，新建包com.stan.test.然后新建 AnAction的派生类action可以继承至 Anaction或者new -> Action效果是一样的。
![](http://oanvj2lsv.bkt.clouddn.com//intellJcode0.png)
下面是一个空组件,没有功能,最后test会呈灰色.
![](http://oanvj2lsv.bkt.clouddn.com//intellJcode1.png)
使用new->Action的时候会先定义一些属性
![](http://oanvj2lsv.bkt.clouddn.com//intellJcreate_action.png)
#### 配置插件信息
Project下 resources文件夹下的plugin.xml是配置插件信息的地方，上面创建的acion派生类都要在此处配置到*actions*标签中
![](http://oanvj2lsv.bkt.clouddn.com//intellJcode2.png)
#### 测试插件效果
右上角Run，默认会打开一个新界面，直接new一个新的工程，就能看的自己写的插件被加载到了上面。
![](http://oanvj2lsv.bkt.clouddn.com//intellJstartTest.gif)
### 发布插件
Build -> Prepare "test" Plugin Modules For Deployment 生成jar文件，就可以通过PreferenPreferences->Plugins->install plugin for disk.. 导入，或者[发布](http://www.jetbrains.org/intellij/sdk/docs/basics/getting_started/publishing_plugin.html)到 IntelliJ Plugin Repository