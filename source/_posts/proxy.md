---
title: 动态代理
date: 2017-3-16 21:21:31
tags: 学习笔记
---
<center> 不修改源码的情况下，增强方法，在方法执行前后做任何你想做的事 </center>
<!---more--->
### 什么是动态代理
代理类在程序运行前不存在、运行时由程序动态生成的代理方式称为动态代理。
动态代理好处是在不改变委托类的现有结构的基础上进行方法增强，在方法运行的前后增加方法，可以方便对代理类的函数做统一或特殊处理。
### 一个栗子
#### 首先是一个接口和实现了该接口的委托类。
接口
```
public interface Action {
    void jump();
    void run();
    void sahuan();
}
```
委托类
```
public class Dog implements Action {

    @Override
    public void jump() {
        System.out.println("start Jump!");
    }

    @Override
    public void run() {
        System.out.println("start Run!");
    }

    @Override
    public void sahuan() {
        System.out.println("start sahuan");
    }
}
```
#### 实现InvocationHandler的连接类，在委托类方法前加上了判定。
```
public class DogActionHandler implements InvocationHandler {

    private Object target;
    public DogActionHandler(Object o) {
        this.target = o;
    }

    @Override
    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        // proxy通过 Proxy.newProxyInstance() 生成的代理类对象
        //method表示代理对象被调用的函数。
        //args表示代理对象被调用的函数的参数。

        if (method.getName().equals("jump")) {
            System.out.println("dog is out of control!");
        } else if (method.getName().equals("run")) {
            System.out.println("dog crazy!");
        } else if (method.getName().equals("sahuan")) {
            System.out.println("dog is the dog!");
        }
        Object object = method.invoke(target,args);
        return object;
    }
}
```
#### Main Test and Output
```
public class Main {

    public static void main(String[] args) {
        DogActionHandler handler = new DogActionHandler(new Dog());
        Action action = (Action) Proxy.newProxyInstance(Dog.class.getClassLoader(),new Class[]{Action.class},handler);
        action.jump();
        action.run();
        action.sahuan();
    }
}
```
```
dog is out of control!
start Jump!
dog crazy!
start Run!
dog is the dog!
start sahuan
```
### 动态代理原理
动态代理类是在调用Proxy.newProxyInstance(…)函数时动态生成的,代理类是以$Proxy为类名前缀，继承自Proxy，并且实现了Proxy.newProxyInstance(…)第二个参数传入的所有接口的类。
#### newProxyInstance(…)
其中 h 就是 protected InvocationHandler h;
```
public static Object newProxyInstance(ClassLoader loader,
                                      Class<?>[] interfaces,
                                      InvocationHandler h)
    throws IllegalArgumentException
{
    if (h == null) {
        throw new NullPointerException();
    }

    /*
     * Look up or generate the designated proxy class.
     */
    Class cl = getProxyClass(loader, interfaces);

    /*
     * Invoke its constructor with the designated invocation handler.
     */
    try {
        Constructor cons = cl.getConstructor(constructorParams);
        return (Object) cons.newInstance(new Object[] { h });
    } catch (NoSuchMethodException e) {
        throw new InternalError(e.toString());
    } catch (IllegalAccessException e) {
        throw new InternalError(e.toString());
    } catch (InstantiationException e) {
        throw new InternalError(e.toString());
    } catch (InvocationTargetException e) {
        throw new InternalError(e.toString());
    }
}
```
中间的生成过程略。
