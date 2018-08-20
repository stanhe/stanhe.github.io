---
title: Dagger2_译(1)
date: 2017-3-9 22:33:59
tags: dagger2
---
![Dagger2](http://oanvj2lsv.bkt.clouddn.com/google/dagger.png)
 <center> dagger2哪里都是一搜4个注解，分分钟放进工程里面使用，然而能用并不是使用第三方框架的初衷，毕竟继承框架都要有其优越性对我们的工程大有裨益才会去使用，这特喵到底有啥用，怎么用，我也很好奇啊，我也想知道啊，我看了User Guide，还是懵的呀~
  所以我决定翻译一下，不对的地方请指正，反正我也会无视的。let's go ...</center>
<!---more--->
### [Dagger](https://google.github.io/dagger/users-guide.html)
翻译于google的dagger2
### User's Guide
根据这个user guide来看，一个优秀设计的类应该是专一、简洁、高效的，如果这个类设计得特别大，看起来功能齐全，然而使用的功能不那么多的话，就会显得臃肿。dagger 简介的模板实现了注入依赖设计模式，可以很好的替换掉这种工厂方法类去生成实例，将一个类的依赖分开，放到类的外部，让该类专注于它更应该做的事。

简单的说就在一个类中需要依赖其他类的时候不用在类的内部去new实例，而是在外部去new，那有特喵什么差别，差别就是类不用自己做，让其他类去做。

优点，测试方面优越性很好，你只需要更改外部module，不会涉及到具体类的内部模块。另一方面就在于外部module的复用性，和可构造，可以使用多个module去构造一个新的module，不用new everywhere。

### Why Dagger 2 is Different

>既然注入依赖已经存在很多年了，为什么还要去改造轮子呢？

dagger2通过编译时自动生成繁复的代码,跟手写的一样(原意是这个)，确保其注入的简洁。

### Using Dagger
下面通过[咖啡例子](https://github.com/google/dagger/tree/master/examples/simple/src/main/java/coffee)来介绍dagger2的使用。

Attention：下面部分不使用主观视角，避免带入误导性思维。

#### Declaring Dependencies

Dagger 为你的应用构建实例并满足依赖，它使用[javax.inject.Injext](http://docs.oracle.com/javaee/7/api/javax/inject/Inject.html)注解来识别当前应用需要的关注的构造器和字段。

使用`@Injext`去注解构造器，dagger就会使用这个构造器来生成该类的实例，当需要一个新的实例的时候，dagger就会通过这个被 `@Injext`注解的构造器和相关参数去生成相应实例。
```
class Thermosiphon implements Pump {
  private final Heater heater;

  @Inject
  Thermosiphon(Heater heater) {
    this.heater = heater;
  }

  ...
}
```
dagger 也可以直接注入字段。 下面的例子中 通过注解取得两个相应的字段。Heater的实例 heater字段，和Pump的实例 pump字段。

```
class CoffeeMaker {
  @Inject Heater heater;
  @Inject Pump pump;

  ...
}
```
如果你的类有@Inject注解的字段，却没有 @Inject注解对应的构造器，dagger 会注入这些字段，但是不会生成字段对应的新实例。所以可以添加一个@Injext注解的无参构造器，保证dagger可以创建实例。

虽然构造函数或字段注入通常是首选，实际上dagger也支持方法注入。

缺少@Inject的注解类不能被dagger注入依赖。
#### Satisfying Dependencies
通常情况下 dagger会根据实例类型去创建新实例，以满足类需求的依赖，当你请求一个新实例CoffeeMaker的时候，它会调用 new CoffeeMaker() 并注入到需求的域。

@Inject不会在以下情况工作：

* 不能构建接口。
* 第三方类不能被注解。
* 可配置的对象必须配置（Configurable objects must be configured 这特喵是啥）。

由于以上的不足，需要引入@Provides注解方法来满足依赖，根据该方法的返回类型来确定满足的依赖。

举个栗子，当需要Heater实例的时候需要请求provideHeater()方法：
```
@Provides
static Heater provideHeater(){
    return new ElectricHeater();
}
```
@Provides 方法也可以依赖自身，下面需求Pump实例的时候可以返回Thermosiphon实例(这不就是向上转型么)
```
@Provides static Pump providePump(Thermosiphon pump) {
  return pump;
}
```


所有@Provides 方法都必须属于一个module，module是添加了@Module注解的类。
```
@Module
class DripCoffeeModule {
  @Provides static Heater provideHeater() {
    return new ElectricHeater();
  }

  @Provides static Pump providePump(Thermosiphon pump) {
    return pump;
  }
}
```

为了方便，@Provides 方法都加上provide前缀 module类都加上 Module后缀

#### Building the Graph
The @Inject and @Provides-annotated classes form a graph of objects, linked by their dependencies. Calling code like an application’s main method or an Android Application accesses that graph via a well-defined set of roots.
将@Inject 和@Provides注解的类通过依赖关系组建成有向图对象，将他们的相应关系串起来，方便在应用的主方法，或者Android应用的application中调用。

 在Dagger2中，则是通过在一个接口中定义一个无参但有返回类型的方法来实现。使用@Component注解一个接口，然后把module类型传递给它，然后dagger2会自动生成相关联的实现。

```
@Component(modules = DripCoffeeModule.class)
interface CoffeeShop {
  CoffeeMaker maker();
}
```
自动生成的实现类会一Dagger作为前缀，请求它的 builder()方法已获取相关实例，使用返回的builder实例设置依赖并调用build()创建实例。
```
CoffeeShop coffeeShop = DaggerCoffeeShop.builder()
    .dripCoffeeModule(new DripCoffeeModule())
    .build();
```
> Note：如果你的 @Component 注解不是顶层注解，而是内部类，那么生成的dagger桥样式略有不同。

```
class Foo {
  static class Bar {
    @Component
    interface BazComponent {}
  }
}

生成类： DaggerFoo_Bar_BazComponent.
```
module 可以省略默认的构造器，builder可以自行构建该类的默认构造器，对于module中所有 注解@Provides都是静态方法的更不需要module实例，如果所有依赖都可以不用创建依赖实例而构造，那么生成的实现类一样有create() 方法 可以用来创建新实例而不再需要使用builder。

```
CoffeeShop coffeeShop = DaggerCoffeeShop.create();
```
现在，我们的CoffeeApp可以简单的使用dagger生成的CoffeeShop实现来获取一个完全注入的cofferMaker.

```
public class CoffeeApp {
  public static void main(String[] args) {
    CoffeeShop coffeeShop = DaggerCoffeeShop.create();
    coffeeShop.maker().brew();//这特喵.brew()哪儿来的呀，扎铁了！老心，反正我在上面没找到。我猜。。。。猜你妹。。
  }
}
```

现在 这个有向图就构造好了，进入点就是已经被注入。

上面就是基本用法了，虽然这个user guide跳跃性很大，我脑补一下也就差不多了。

##### Bindings in the graph

上面的栗子展示了怎样使用绑定来构建组件，但是绑定到有向图的机制有很多种。下面的方法均可用于生成可用依赖构成组件。

* 在@Module中被@Provides注解的方法可以直接被@Component.modules或者通过@Module.includes引用。
* 任何格式的@Inject注解的无作用域构造器 或者被@Scope注解并匹配多个组件其中一个组件的作用域。
* 该组件依赖的组件提供的方法
* 组件本身
* 任何包含子组件的不合格的builders
* 提供或者包含任何以上绑定的
* 提供弱引用依赖的绑定
* 任何格式的注入者

（这特喵都是啥呀，啊！西坝~难道是我水准问题，那不能，肯定是眼花了，明天再改，续接
Singletons and Scoped Bindings
）

