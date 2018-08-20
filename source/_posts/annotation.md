---
title: Annotation
date: 2017-3-11 11:22:13
tags: 学习笔记
---

<center> 太久没用的知识点总是忘，昨晚又翻了一遍，整理一下。 </center>

<!----more---->
## 注解简介
Java SE5 内置3种标准注解：@Override、@Deprecated、@SupportWarnings 名字能分辨出其注解作用。

4种元注解:

* @Target 表示修饰注解可以的地方，可能的ElementType包括 CONSTRUCTOR(注解构造器)、FIELD(注解 域，包括enum实例)、LOCAL_VARIABLE(注解局部变量)、METHOD(注解方法)、PACKAGE(注解包)、PARAMETER(注解参数)、TYPE(注解类，接口或enum声明)、ANNOTATION_TYPE(注解 注解)、TYPE_PARAMETER(1.8加入，注解方法参数)、TYPE_USE(1.8加入 注解使用类型)
* @Retention 表示可以在什么级别保存该注解信息，可选参数RetentionPolicy包括 SOURCE(注解讲被编译器丢弃)、CLASS(注解在class中可用，但会被vm丢弃)、RUNTIME(vm运行时也可以保留注解，可以通过反射机制读取注解信息)
* @Documented 将注解包含到javadoc中
* @Inherited 允许子类继承父类中的注解

## 示例
### 编写一个方法注解
```
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface UseCase {
    public int id();
    public String description() default "no description";
}
```
### 使用注解
```
public class Annotation {

    @UseCase(id= 14,description = "print someThing!")
    public static void print(String message) {
        System.out.println("message : "+message);
    }

    @UseCase(id= 18)
    public static void password(String message) {
        System.out.println("message : "+message);
    }
    @UseCase(id= 10,description = "input your name!")
    public static void name(String message) {
        System.out.println("message : "+message);
    }
}
```
### 注解处理器
```
public class UseCaseHandler {
    public static void trackUseCase(List<Integer> useCases, Class<?> c1) {
        for (Method m : c1.getDeclaredMethods()) {
            UseCase uc = m.getAnnotation(UseCase.class);
            if (uc != null) {
                System.out.println("Find useCase : "+uc.id()+ " description: "+uc.description());
                useCases.remove(new Integer(uc.id()));
            }
        }
        for (int i : useCases) {
            System.out.println("missing --> "+i);
        }
    }

    public static void main(String[] args) {
        List<Integer> useCases = new ArrayList<>();
        Collections.addAll(useCases,10,18,14,20);
        trackUseCase(useCases,Annotation.class);
    }
}
```
输出：
```
Find useCase : 10 description: input your name!
Find useCase : 14 description: print someThing!
Find useCase : 18 description: no description
missing --> 20
```
以上就是一个简单的示例，注解套路基本同上。
## 一些知识点
### 注解元素
注解元素可用类型包括
* 所有的基本类型
* String
* Class
* enum
* 以上类型的数组
注解元素必须有默认值，也就是default值。为了表示一个空，可以定义一个注解来表示空注解
```
@Target(ElementType.ANNOTATION_TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface DefaultNull {
    int value() default -1;
    String  description() default "";
}
```
#### 注解嵌套。
```
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@DefaultNull //出现在这里的注解一般是起限定作用，类似一个大类中的小类标记。比如狗，分泰迪，吉娃娃，田园犬，可以用一个枚举注解在这里区分，不用再写很多元素和@interface。
@....//可以有多个自定义注解出现。
public @interface Simple {
    DefaultNull getDefault() default @DefaultNull(value = 2);//修改默认值
}
```
这里用 DefaultNull相当于一个Tag，用以表示一个默认值，可以根据反射取得Simple的所以注解，如果发现该注解则。。。。

### 最后写一个注解注入的简单例子。
#### AnimalType
枚举类，划分内部注解范畴
```
public enum AnimalType {
    DOG("DOG"),CAT("CAT");
    private String name;
    AnimalType(String name) {
        this.name = name;
    }
    public String getName() {
        return name();
    }
}
```
#### POJO类
```
public class Dog {
    public String action;
    public Dog(String action) {
        this.action = action;
    }
}
//实际上它们是分开的
public class Cat {
}
```
#### CategoryAnnotation
基础种类注解
```
@Target(ElementType.ANNOTATION_TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface CategoryAnnotation {
    AnimalType animalType();
    String  name();
}
```
#### 注解类

定义吉娃娃和泰迪注解，它们同时也被 CategoryAnnotation注解，CategoryAnnotation的存在，不需要再在这两个注解类的内部声明新元素。
```
@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@CategoryAnnotation(animalType = AnimalType.DOG,name = "Ji-wa-wa")
public @interface JiwawaAnnotation {
}

//实际上它们是分开的

@Target(ElementType.FIELD)
@Retention(RetentionPolicy.RUNTIME)
@CategoryAnnotation(animalType = AnimalType.DOG, name ="Tai-di" )
public @interface TaidiAnnotation {
}
```
#### inject类，注入类。实现注解注入
```
public class InjectUtil {
    public static void inject(Test cl) {
        Field[] fields = cl.getClass().getFields();
        for (Field field : fields) {
            Annotation[] annotations = field.getAnnotations();
            for (Annotation annotation : annotations) {
                Class<?> annotationType = annotation.annotationType(); //返回方法上面使用的注解类
                CategoryAnnotation categoryAnnotation = annotationType.getAnnotation(CategoryAnnotation.class);
                if (categoryAnnotation != null) {
                    String name = categoryAnnotation.name();
                    AnimalType type = categoryAnnotation.animalType();
                    try {
                        if (type == AnimalType.DOG) {
                            if (name.equals("Ji-wa-wa")) {
                                 field.set(cl, new Dog("ji wa wa start sa huan!"));//没错就是 吉娃娃开始撒欢
                            }else {
                                 field.set(cl,new Dog("tai di start run!")); //泰迪开始跑
                        } else if (type == AnimalType.CAT) {
                            field.set(cl,new Cat());
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                } else {
                    System.out.println("no categoryAnnotation!");
                }
            }
        }
    }
}
```
#### 最后是Test类
```
public class Test {
    {
        InjectUtil.inject(this);
    }

    @TaidiAnnotation
    public Dog dog1;
    @JiwawaAnnotation
    public Dog dog2;

    public void liuGou() {
        System.out.println("dog1.action : "+dog1.action);
        System.out.println("dog2.action : "+dog2.action);
    }

    public static void main(String[] args) {
       Test test = new Test();
        test.liuGou();
    }
}

```
#### OutPut
```
dog1.action : tai di start run!
dog2.action : ji wa wa start sa huan!
```
#### 示例总结
这里实现了依赖注入，但是injectUtil可以抽离出来，讲类需要的依赖进行Module封装，再通过contract连接就是dagger的框架了。
上例主要演示注解在反射机制下的运用，要使用该机制 @Retention(RetentionPolicy.RUNTIME) 是必须的。

[以上示例地址](https://github.com/stanhe/Annotation/tree/master/lib)

