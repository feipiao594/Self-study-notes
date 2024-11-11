---
title: Rust_Chapter_8_泛型
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - Rust
abbrlink: bdd7a1b0
date: 2024-11-11 13:09:46
---

# Rust_Chapter_8_泛型
泛型是用来缩减重复书写的代码的优良工具，Rust 如同 C++ 一样引入了这样的一个工具

<!--more-->

> 关于: 这个系列一开始是帮我学习 Rust 的，但时间拖的有些长了，我也不再是初学者了，但我没有将事情做好一半就停下的习惯，就慢慢把它写完吧，说不定到时候还能在前面的内容添加一些自己的理解，不过短期内还是以学习笔记为主吧

## 在函数定义中使用泛型

同 C++ 中的泛型一样，如果要在函数体中使用参数，就必须在函数签名中声明它的名字，好让编译器知道这个名字指代的是什么。同理，当在函数签名中使用一个类型参数时，必须在使用它之前就声明它。类型参数声明位于函数名称与参数列表中间的尖括号 <> 



```rust
fn largest<T>(list: &[T]) -> &T {...}
```

## 结构体，枚举中的泛型

**结构体&方法的泛型**
```rust
struct Point<T> {
    x: T,
    y: T,
}

impl<T> Point<T> {
    fn x(&self) -> &T {
        &self.x
    }
}

fn main() {
    let p = Point { x: 5, y: 10 };

    println!("p.x = {}", p.x());
}
```

当然定义方法时你也可以针对一个具体的从泛型确定的类型来定义，专业术语为**泛型指定限制**

```rust
impl Point<f32> {
    fn distance_from_origin(&self) -> f32 {
        (self.x.powi(2) + self.y.powi(2)).sqrt()
    }
}
```

> 结构体定义中的泛型类型参数并不总是与结构体方法签名中使用的泛型是同一类型。

**枚举的泛型**

```rust
// Result 就是一个很好的例子
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```

## 关于实现
仍然和 C++ 的模板一致，在编译期 Rust 编译器会根据具体使用到的代码，根据泛型实例化一个具体的实现