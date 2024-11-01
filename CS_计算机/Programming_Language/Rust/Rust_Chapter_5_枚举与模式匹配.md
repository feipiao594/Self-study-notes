---
title: Rust_Chapter_5_枚举与模式匹配
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - Rust
date: 2024-04-16
abbrlink: 28bcc6be
---


# Rust_Chapter_5_枚举与模式匹配
`enums`，一个很有用的东西，使用枚举可以简化很多东西


<!--more-->

## 枚举

### 定义
关于枚举，书上给出的一个例子是这样的

> 假设我们要处理 IP 地址。目前被广泛使用的两个主要 IP 标准：IPv4(version four)和 IPv6(version six)。这是我们的程序可能会遇到的所有可能的 IP 地址类型：所以可以 **枚举** 出所有可能的值，这也正是此枚举名字的由来

例子和代码都很简单，正如和常见语言都是一致的

```rust
enum IpAddrKind {
    V4,
    V6,
}
```

### 枚举值

可以像下面这样创建`IpAddrKind`两个不同成员的实例

```rust
let four = IpAddrKind::V4;
let six = IpAddrKind::V6;
```

也可以像C++那样作为函数参数传递给函数

### 枚举值绑定变量
这是Rust enum强于C++的地方，其允许枚举值去绑定一个变量，能够有效减少一些事情，比如像我最近写的一个[telegram_bot](https://github.com/feipiao594/telegram_rust_charge_bot)，如果一个command需要传递，我们通常不仅仅需要command的类型，还有更多的信息需要被传递。

```rust
enum IpAddr {
    V4(String),
    V6(String),
}
let home = IpAddr::V4(String::from("127.0.0.1"));
let loopback = IpAddr::V6(String::from("::1"));
```

我们直接将数据附加到枚举的每个成员上，这样就不需要一个额外的结构体了。这里也很容易看出枚举工作的另一个细节：每一个我们定义的枚举成员的名字也变成了一个构建枚举的实例的函数。也就是说，`IpAddr::V4()` 是一个获取`String`参数并返回`IpAddr`类型实例的函数调用。作为定义枚举的结果，这些构造函数会**自动被定义**。


**让我们分析这样做的好处**，对于C++ enum来说，从数学上看，一个类型我们可以声明为一个集合里的元素，称这个集合为一个类型，集合内的元素是一个具体的值，比如int类型就是一个有限长的集合，而枚举类就相当于设定一个新类型，或者说叫新集合，其中的元素或者说叫做枚举值是固定的

但是Rust高明之处就是将枚举值绑定了一个变量，它可以扩展其中的概念，让枚举的名称与枚举所带的变量构成的笛卡尔积内的元素成为了枚举的元素，大大提高了灵活度

从这点看来union其实是一个非安全的enum，它没有标签，读取时也容易发生错误

### Option\<T\>
`Option<T>`是那么有用以至于它其实被很多语言内嵌在语言当中，其表示一个值可以为空，这其实是一个很常见的东西

在对`Option<T>`进行运算之前必须将其转换为T。通常这能帮助我们捕获到空值最常见的问题之一：假设某值不为空但实际上为空的情况。

消除了错误地假设一个非空值的风险，会让你对代码更加有信心。为了拥有一个可能为空的值，你必须要显式的将其放入对应类型的`Option<T>`中。接着，当使用这个值时，必须明确的处理值为空的情况。只要一个值不是`Option<T>`类型，你就可以安全的认定它的值不为空。这是Rust的一个经过深思熟虑的设计决策，来限制空值的泛滥以增加Rust代码的安全性。

## match控制流结构

只要一个例子便可以解释这个东西，模式匹配我个人认为就是更为强大的switch case

```rust
#[derive(Debug)] // 这样可以立刻看到州的名称
enum UsState {
    Alabama,
    Alaska,
    // --snip--
}

enum Coin {
    Penny,
    Nickel,
    Dime,
    Quarter(state),
}

fn value_in_cents(coin: Coin) -> u8 {
    match coin {
        Coin::Penny => {
            println!("Lucky penny!");
            1
        },
        Coin::Nickel => 5,
        Coin::Dime => 10,
        Coin::Quarter(state) => {
            println!("State quarter from {:?}!", state);
            25
        }
    }
}
```

语法结构就是`match`关键字后写要进行匹配的那个变量，当`match`表达式执行时，它将这个变量按从上到下的顺序与每一个分支的模式相比较。如果模式匹配了这个值，这个模式相关联的代码将被执行，也就是说`=>`后面跟着的不一定非要是一个数字，也可以是一个`{}`里的一串语句，最后整个表达式输出一个值，这意味着你可以在模式匹配时做一些事情

模式匹配也能拆解一个复杂的类型，比如获取到上面提到的enum内部的`state`类型

注意，匹配表达式匹配结果将通过匹配到的`=>`返回，整个`match`是一个表达式，它有具体的值与其对应的数据

### 通配模式与`_`占位符

我们可以在match表达式匹配无法被穷尽的时候，加入一个类似switch case里default的东西，比如在上面的例子里添加一个`_ => 594`，当当你仍然要用这个无法被匹配到的值做一些事情(比如你确信它实现了display traits，打算匹配不到就输出其中的内容)，那么你就可以使用

```rust
other => {
    do_someting();
    return_value
}
```

很合理对吧

## `if let`简洁控制流

可以用下面的例子仅仅匹配一个单独的模式，`if let`既是`match`的一个简单使用时的简化版本

```rust
let mut count = 0;
if let Coin::Quarter(state) =coin {
    println!("State quarter from{:?}!", state);
} else {
    count += 1;
}
```

