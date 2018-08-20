---
title: Dagger2_译(2)
date: 2017-3-12 16:33:59
tags: dagger2
---
![Dagger2](http://oanvj2lsv.bkt.clouddn.com/google/dagger.png)
<center> 接译1，Singletons and Scoped Bindings</center>
<!---more--->
当我返回去把注解好好理了一遍之后发现dagger也就好理解多了，其实就是注解机制的使用，其设计框架还是值得学习的，有机会再深入源码。接下来是@Singleton(单例) 和 Scoped Bindings(域绑定)
### Singletons and Scoped Bindings
当使用@Singleton注解@Provides注解的方法时，有向图会为其所有使用该方法的依赖提供单例模式。

```
@Provides @Singleton static Heater provideHeater(){
    return new ElectricHeater();
}
```

@Singleton 注解也可用于注解可注入类文档，提醒维护者，该类可能被多个线程使用。

```
@Singleton
class CoffeeMaker{
...
}
```

由于在有向图中是通过`组件实例`的实现来连接域实例，所以组件自身需要声明其作用域。举个栗子，组件中可以包含有@Singleton和@RequestScoped注解的绑定，然而两个注解有不同的生命周期，所以这样的组件就没多大意义了。在组件中使用域注解

```
@Component(modules = DripCoffeeModule.class)
@Singleton
interface CoffeeShop {
  CoffeeMaker maker();
}
```

组件可能被应用多个域注解，这表明他们有共同的别名域，组件可以绑定到任何一个声明的域中。

### Reusable scope
有时你想限制被@Inject注解的构造器实例化的数量 或者 @Provides方法的调用次数，但在组件或者子组件的生命周期中你不需要保证精确的相同实例个数。但在Android 环境下，这一点还是很有必要。
对于那些需要被重用的绑定可以使用@Reusable 域注解。@Reusable域绑定注解并不会和哪些单个的组件建立关联，而是使用缓存来管理注解。
也就是说如果在一个组件中使用了@Reusable绑定安装了一个Module，但是实际上只有这一个组件的一部分使用了该绑定，那么就只有这一部分被缓存。同理，如果两个拥有不同父类的组件分别使用了绑定，那么他们就会被分别缓存。如果组件的父类已经缓存了当前类实例，那么子组件将重用该实例。
> 这里并不能保证组件只调用一次绑定，所以用@Reusable去绑定返回可变对象 或者 需要引用一个重要的相同实例就会很危险。所以如果不考虑分配次数，对无作用域的不可变对象使用@Reusable是安全的

```
@Reusable // It doesn't matter how many scoopers we use, but don't waste them.
class CoffeeScooper {
  @Inject CoffeeScooper() {}
}

@Module
class CashRegisterModule {
  @Provides
  @Reusable // DON'T DO THIS! You do care which register you put your cash in.
            // Use a specific scope instead.
  static CashRegister badIdeaCashRegister() {
    return new CashRegister();
  }
}

@Reusable // DON'T DO THIS! You really do want a new filter each time, so this
          // should be unscoped.
class CoffeeFilter {
  @Inject CoffeeFilter() {}
}

```

### Releasable references
当绑定中使用域注解的时候，表明组件类持有相关object的引用直到object被回收。像Android这种内存敏感的环境下，你希望当前未使用的域object在应用内存紧张的情况下可以被删除。
这种情况下，就可以使用@CanReleaseReferences注解

```
@Documented
@Retention(RUNTIME)
@CanReleaseReferences
@Scope
public @interface MyScope {}
```

当你决定在垃圾回收期间如果在相关域中的object没有被其他object使用的情况被删除，你可以在域中注入一个 ReleasableReferenceManager 类然后调用 releaseStrongReferences() 方法，使得组件持有这个类的 WeakReference

```
@Inject @ForReleasableReferences(MyScope.class)
ReleasableReferences myScopeReferences;

void lowMemory() {
  myScopeReferences.releaseStrongReferences();
}
```

同理，在内存压力不大的时候，可以通过调用 restoreStrongReferences()方法 存储任何没有被垃圾回收的缓存类的强引用。

```
void highMemory() {
  myScopeReferences.restoreStrongReferences();
}
```

### Lazy injections

有时需要懒加载，例如绑定T,可以创建Lazy<T>推迟实例化到第一次调用Lazy<T>'s get()method方法, 如果T是单例，Lazy<T> 将为objectGraph注入相同实例，否则将为每个注入类单独保存Lazy<T>实例。不管怎样，后续调用懒加载实例都会返回相同实例。

```
class GridingCoffeeMaker {
  @Inject Lazy<Grinder> lazyGrinder;

  public void brew() {
    while (needsGrinding()) {
      // Grinder created once on first call to .get() and cached.
      lazyGrinder.get().grind();
    }
  }
}
```

### Provider injections
有时需要返回多个实例而不是一个，当你有多个选项(如 Factories，Builders，等)，一个选项是注入一个 Provider<T> 代替T。Provider<T> 每次都会调用T的绑定逻辑。如果绑定逻辑是一个@Inject注解的构造器，那么就会创建一个新实例，但是@Provides注解方法没有这种机制。

```
class BigCoffeeMaker {
  @Inject Provider<Filter> filterProvider;

  public void brew(int numberOfPots) {
  ...
    for (int p = 0; p < numberOfPots; p++) {
      maker.addFilter(filterProvider.get()); //new filter every time.
      maker.addCoffee(...);
      maker.percolate();
      ...
    }
  }
}
```

`Note`: Provider<T>可能创建混淆的代码，或者导致缺少作用域或打乱注入有向图结构。通常情况下是使用 factory或者 Lazy<T>来组织代码的生命周期和结构。然而Provider<T>有些情况下又很有用，一种常见的用途是在你必须使用不符合对象生命周期的传统架构的时候（例如：servlets是设计的单例模式，但只适用于要求特定数据的上下文）。
### Qualifiers
有时单独类型不足以识别依赖。比如一个复杂的咖啡机应用只需要单独的热水器和热板加热器。
这种情况下添加一个 qualifier注解 @Qualifier。下面声明一个@Named。

```
@Qualifier
@Documented
@Retention(RUNTIME)
public @interface Named {
  String value() default "";
}
```

你可以自定义qualifier注解，或者只使用@Named注解。使用qualifiers注解字段或者参数。那么类型和qualifier注解都将被用于辨识依赖。

```
class ExpensiveCoffeeMaker {
  @Inject @Named("water") Heater waterHeater;
  @Inject @Named("hot plate") Heater hotPlateHeater;
  ...
}
```

注解相应的@Provides方法以提供备选值。

```
@Provides @Named("hot plate") static Heater provideHotPlateHeater() {
  return new ElectricHeater(70);
}

@Provides @Named("water") static Heater provideWaterHeater() {
  return new ElectricHeater(93);
}
```

依赖项可能没有多个限定符注释。

### Optional bindings
如果你希望某些并没有绑定到组件的依赖起作用，可以给Module添加 @BindsOptionalOf方法。

```
@BindsOptionalOf abstract CoffeeCozy optionalCozy();
```

也就意味着 @Inject注解的构造器、成员和@Provides方法可以依赖一个*Optional<CoffeeCozy>*类。如果组件中有CoffeeCozy类的绑定，那么就可用。如果没有相关绑定，那么可选无效。
具体来说，可以注入以下任何一项：
```
 Optional<CoffeeCozy>

 Optional<Provider<CoffeeCozy\>>

 Optional<Lazy<CoffeeCozy>>

 Optional<Provider<Lazy<CoffeeCozy>>>
```
如果子组件包含基础类型的绑定 那么组件中缺少的可选绑定可以出现在子组件中。

### Binding Instances
构建组件时通常包含可用数据，例如，假设你有使用命令行参数的应用，你可能想把这些参数绑定到组件中。
也许你的应用需要一个单一参数展示用户名称就可以使用@UserName String注入。你可以给组件构造器添加一个方法注解 @BindsInstance 允许在该组件中注入实例

```
@Component(modules = AppModule.class)
interface AppComponent {
  App app();

  @Component.Builder
  interface Builder {
    @BindsInstance Builder userName(@UserName String userName);
    AppComponent build();
  }
}
```

Your app then might look like

```
public static void main(String[] args) {
  if (args.length > 1) { exit(1); }
  App app = DaggerAppComponent
      .builder()
      .userName(args[0])
      .build()
      .app();
  app.run();
}
```

上面的例子中，调用方法时，使用提供给builder的实例来进行@UserName String的注入。@BindsInstance注解方法必须在创建组件之前调用，并传递一个非空值。
如果@BindsInstance的参数有@Nullable注解，那么参数可以为空。此外 builder调用者会忽视调用方法，组件也将该注入实例视为空。

@BindsInstance 方法应优先使用于写一个 提供构造参数并立即提供这些值的 @Module 。
### Compile-time Validation
dagger注解处理器非常严格，如果绑定不可用或者未完成都会引起编译时错误。比如，被调用的module中缺少Executor绑定。

```
@Module
class DripCoffeeModule {
  @Provides static Heater provideHeater(Executor executor) {
    return new CpuHeater(executor);
  }
}
```

编译它时会报一下错误：

```
[ERROR] COMPILATION ERROR :
[ERROR] error: java.util.concurrent.Executor cannot be provided without an @Provides-annotated method.
```
这时候就需要添加@Provide方法 提供返回Executor的方法。
### Compile-time Code Generation
dagger的注解处理器也会生成源文件如 CoffeeMaker_Factory.java或者CoffeeMaker_MembersInjector.java 这些文件都是dagger的实现细节.使用中都不会直接使用到。一般我们只需要关注一个以Dagger为前缀生成的组件。
