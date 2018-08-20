---
title: Dagger2_相关知识点整理
date: 2017-3-13 17:00:59
tags: dagger2
---
![Dagger2](http://oanvj2lsv.bkt.clouddn.com/google/dagger.png)
<center>  </center>
<!---more--->
## dagger2中的注解
### 常用注解
* @Inject
@Inject在需要依赖的地方使用，也可以在默认构造器前使用，表示依赖可以通过该默认构造器来获取。

* @Module
Module类中的方法专门提供依赖，dagger构造实例的时候会优先在这里查找。

* @Provide
注解Module中提供实例的方法。

* @Component
注入器，将@Inject注解的需求实例和@Provides方法提供的实例联系起来，@Component{dependencies={},modules={}}其中dependencies是提供依赖类，可以是@Inject注解了默认构造器的类，也可以是其他component类，modules则是集中提供依赖的Module.class类。

* @Scope
作用域注解，@Singleton是其一种。

* @Qualifier
鉴别依赖时使用，当依赖多个不同层级的相同类的时候加以区分。dagger2中可以直接使用 @Named("xxoo")

* @Singleton
单例模式，注解类@Provides方法 @Component组件等。

### 不是很常用的一些注解

* @Reusable
对于那些需要被重用的绑定可以使用@Reusable 域注解。@Reusable域绑定注解并不会和哪些单个的组件建立关联，而是使用缓存来管理注解。

* @CanReleaseReferences
你希望当前未使用的域object在应用内存紧张的情况下可以被删除。

* [一些其他注解在这里查看](http://stanho.top/2017/03/12/dagger2_1/)

## dagger2问题汇总
### xxoo cannot be provided with an @Provides-annotated method.
这是Component 组件的 Modules没有提供 注入需要的@Provides注解方法导致的问题，当需要的实例太多，我们总会忘记提供该方法，这时可以通过 注解默认构造器解决这个问题。

编译时首先检查module中是否有对应@Provides方法，如果没有，再检查注入依赖的构造器是否有@Inject注解的默认构造器，还是没有，报错。