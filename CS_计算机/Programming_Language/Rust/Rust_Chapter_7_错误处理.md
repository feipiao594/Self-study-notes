---
title: Rust_Chapter_7_错误处理
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - Rust
abbrlink: d7b468f6
date: 2024-11-10 09:11:24
---

# Rust_Chapter_7_错误处理
Rust 没有异常。相反，它有 `Result<T, E>` 类型，用于处理可恢复的错误，还有 `panic!` 宏，在程序遇到不可恢复的错误时停止执行。

<!--more-->

## `panic!`

`panic!` 针对的是不可恢复的操作

执行会造成代码 `panic` 的操作（比如访问超过数组结尾的内容）或者显式调用 `panic!` 宏。这两种情况都会使程序 `panic`。通常情况下这些 panic 会打印出一个错误信息，展开并清理栈数据，然后退出。

在错误信息中，通常会提示你设置 `RUST_BACKTRACE` 环境变量已得到错误发生时的函数调用栈，以帮助你定位错误发生的位置

## 使用 Result
现如今，很多语言都引入了 Result 的概念，将错误和结果打包成一个枚举返回有助于错误的传递
当结果无误时，返回 Ok(something)，在结果有错误时，返回一个 Err(some_error)

可以利用模式匹配来处理这些枚举

```rust
use std::fs::File;
use std::io::ErrorKind;

fn main() {
    let greeting_file_result = File::open("hello.txt");

    let greeting_file = match greeting_file_result {
        Ok(file) => file,
        Err(error) => match error.kind() {
            ErrorKind::NotFound => match File::create("hello.txt") {
                Ok(fc) => fc,
                Err(e) => panic!("Problem creating the file: {e:?}"),
            },
            other_error => {
                panic!("Problem opening the file: {other_error:?}");
            }
        },
    };
}
```

但模式匹配仍然会导致代码长度很长，你也可以使用一些相对来说更简单易用的函数，例如 `unwrap_or_else`

比较常用的另一组是 `unwarp` 和 `expect`，他们两作为 Result 的函数，会获取 Ok 内部的值，如果获取不到，则陷入 panic，区别在于 expect 有自己的参数，你填写的字符串作为报错信息显示

```rust
use std::fs::File;

fn main() {
    let greeting_file = File::open("hello.txt").unwarp();
    let greeting_file = File::open("hello.txt")
        .expect("hello.txt should be included in this project");
}
```

## 传播可恢复的错误
当编写一个其实先会调用一些可能会失败的操作的函数时，除了在这个函数中处理错误外，还可以选择让调用者知道这个错误并决定该如何处理。这被称为**传播**错误，这样能更好的控制代码调用，因为比起你代码所拥有的上下文，调用者可能拥有更多信息或逻辑来决定应该如何处理错误。

你可以使用下面的方法手动把获取到的 Result 拆开，生成你自己函数要返回的 Result
```rust
use std::fs::File;
use std::io::{self, Read};

fn read_username_from_file() -> Result<String, io::Error> {
    let username_file_result = File::open("hello.txt");

    let mut username_file = match username_file_result {
        Ok(file) => file,
        Err(e) => return Err(e),
    };

    let mut username = String::new();

    match username_file.read_to_string(&mut username) {
        Ok(_) => Ok(username),
        Err(e) => Err(e),
    }
}
```

因为这种错误传播效果比较明显，所以会被大量使用，但每次都这么写太冗余了

## 传播错误的简写：? 运算符

```rust
use std::fs::File;
use std::io::{self, Read};

fn read_username_from_file() -> Result<String, io::Error> {
    let mut username_file = File::open("hello.txt")?;
    let mut username = String::new();
    username_file.read_to_string(&mut username)?;
    Ok(username)
}
```

如果 Result 的值是 Ok，这个表达式将会返回 Ok 中的值而程序将继续执行。如果值是 Err，Err 将作为整个函数的返回值，就好像使用了 return 关键字一样，这样错误值就被传播给了调用者。

? 运算符所使用的错误值被传递给了 from 函数，它定义于标准库的 From trait 中，其用来将错误从一种类型转换为另一种类型。当 ? 运算符调用 from 函数时，收到的错误类型被转换为由当前函数返回类型所指定的错误类型。这在当函数返回单个错误类型来代表所有可能失败的方式时很有用，即使其可能会因很多种原因失败。

例如，我们可以将示例中的 `read_username_from_file` 函数修改为返回一个自定义的 `OurError` 错误类型。如果我们也定义了 `impl From<io::Error> for OurError` 来从 `io::Error` 构造一个 `OurError` 实例，那么 `read_username_from_file` 函数体中的 ? 运算符调用会调用 from 并转换错误而无需在函数中增加任何额外的代码。

关于 ? 运算符还有以下几点
- ? 运算符只能被用于返回值与 ? 作用的值相兼容的函数。
- ? 运算符也可用于 `Option<T>` 值。