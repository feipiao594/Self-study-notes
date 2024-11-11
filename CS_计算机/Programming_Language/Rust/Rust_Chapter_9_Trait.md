---
title: Rust_Chapter_9_Trait
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - Rust
abbrlink: fa0fbc5d
date: 2024-11-11 14:00:29
---

# Rust_Chapter_9_Trait
Trait 是我认为 Rust 中最好用最有特色的特性之一，它和 C++20 的 Concept 很像，trait 也类似于其他语言中的常被称为**接口**(interfaces)的功能，虽然有一些不同。

<!--more-->

## 定义一个 Trait

```rust
pub trait Summary {
    fn summarize(&self) -> String;
}
```

`pub` 字段说明了其对外部 crate 的可见性，在这里不重要
这里我们定义了一个签名为 `Summary` 的 Trait，当然 Trait 体中可以有多个方法：一行一个方法签名且都以分号结尾。在大括号中声明描述实现这个 trait 的类型所需要的行为的方法签名，在这个例子中是 `fn summarize(&self) -> String`。在定义了 Trait 后我们就可以为类型实现 Trait 了

### 为类型实现 Trait

```rust
pub struct NewsArticle {
    pub headline: String,
    pub location: String,
    pub author: String,
    pub content: String,
}

impl Summary for NewsArticle {
    fn summarize(&self) -> String {
        format!("{}, by {} ({})", self.headline, self.author, self.location)
    }
}

pub struct Tweet {
    pub username: String,
    pub content: String,
    pub reply: bool,
    pub retweet: bool,
}

impl Summary for Tweet {
    fn summarize(&self) -> String {
        format!("{}: {}", self.username, self.content)
    }
}
```

这里我们为两个类型 `NewsArticle`、`Tweet` 分别 `impl` 了 `Summary Trait`，也就是需要提供一个 summarize 的函数定义

可以看到它的语义像是：一个可以 **summarize** 的东西是一个 **Summary**

## 默认实现
我们可以在定义 Trait 时给予函数一个定义，是为默认定义，如果后面 `impl` 时没有被显式覆盖，则使用默认定义，当然就像函数默认值那样，你可以不在 `impl` 时具体声明它，这样就使用的是默认定义

## Trait 作为参数

知道了如何定义 Trait 和在类型上实现这些 Trait 之后，我们可以探索一下如何使用 Trait 来接受多种不同类型的参数。下面的示例中为 `NewsArticle` 和 `Tweet` 类型实现了 `Summary` Trait，用其来定义了一个函数 notify 来调用其参数 item 上的 `summarize` 方法，该参数是实现了 `Summary` Trait 的某种类型。为此可以使用 `impl` Trait 语法，像这样：

```rust
pub fn notify(item: &impl Summary) {
    println!("Breaking news! {}", item.summarize());
}
```
对于 `item` 参数，我们指定了 `impl` 关键字和 Trait 名称，而不是具体的类型。该参数支持任何实现了指定 Trait 的类型。在 `notify` 函数体中，可以调用任何来自 `Summary` trait 的方法，比如 `summarize。我们可以传递任何` `NewsArticle` 或 `Tweet` 的实例来调用 `notify`。任何用其它如 `String` 或 `i32` 的类型调用该函数的代码都不能编译，因为它们没有实现 `Summary`

## Trait Bound

上面的示例其实更像下面代码的语法糖

```rust
pub fn notify<T: Summary>(item: &T) {
    println!("Breaking news! {}", item.summarize());
}
```

**Trait Bound** 这种写法的适用性更强

下面的两个例子分别展示了使用 `+` 表示一个同时实现了  `Display` 和 `Clone` 的类型，这意味着 `some_function` 接受的类型必须同时实现 `Display` 和 `Clone` 

其中前者写进了尖括号<>
后者写在 `where` 从句中

```rust
fn some_function<T: Display + Clone, U: Clone + Debug>(t: &T, u: &U) -> i32 {...}

fn some_function<T, U>(t: &T, u: &U) -> i32
where
    T: Display + Clone,
    U: Clone + Debug,
{...}
```


也可以在返回值中使用 `impl` Trait 语法，来返回实现了某个 trait 的类型：

```rust
fn returns_summarizable() -> impl Summary {
    Tweet {
        username: String::from("horse_ebooks"),
        content: String::from(
            "of course, as you probably already know, people",
        ),
        reply: false,
        retweet: false,
    }
}
```

> 注意此处要求返回确定的类型，如果你这个函数可能返回不止一种类型那么也是不行的


## 有条件的实现方法

```rust
use std::fmt::Display;

struct Pair<T> {
    x: T,
    y: T,
}

impl<T> Pair<T> {
    fn new(x: T, y: T) -> Self {
        Self { x, y }
    }
}

impl<T: Display + PartialOrd> Pair<T> {
    fn cmp_display(&self) {
        if self.x >= self.y {
            println!("The largest member is x = {}", self.x);
        } else {
            println!("The largest member is y = {}", self.y);
        }
    }
}
```

这有点像 C++ 偏特化，可以对任何实现了特定 trait 的类型有条件地实现 trait。对任何满足特定 trait bound 的类型实现 trait 被称为 blanket implementations，它们被广泛的用于 Rust 标准库中。