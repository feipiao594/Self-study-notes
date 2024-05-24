---
title: Rust_Chapter_6_包与crate
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - Rust
abbrlink: 23fc5c90
---


# Rust_Chapter_6_包与crate
相比于C++，Rust最吸引我得就是其强大的包管理与调用，cargo实在是太好用了。现在，我们来讨论包与crate相关的内容

<!--more-->

## 包与crate
`crate`是Rust在编译时最小的代码单位。其分为两种，一种是**二进制项**，一种是**库**，其中库crate不包括`main`函数

包(package)是提供一系列功能的一个或者多个crate。一个包会包含一个`Cargo.toml`文件，阐述如何去构建这些 crate。Cargo就是一个包含构建你代码的二进制项的包。Cargo也包含这些二进制项所依赖的库。其他项目也能用Cargo库来实现与Cargo命令行程序一样的逻辑。

包中可以包含**至多一个库**crate(library crate)。包中可以包含**任意多个二进制**crate(binary crate)，但是必须至少包含一个crate(无论是库的还是二进制的)。

一个标准的项目目录如下，来自Rust语言圣经(Rust Course):

```
.
├── Cargo.toml
├── Cargo.lock
├── src
│   ├── main.rs
│   ├── lib.rs
│   └── bin
│       └── main1.rs
│       └── main2.rs
├── tests
│   └── some_integration_tests.rs
├── benches
│   └── simple_bench.rs
└── examples
    └── simple_example.rs
```

- 唯一库包：`src/lib.rs`
- 默认二进制包：`src/main.rs`，编译后生成的可执行文件与Package同名
- 其余二进制包：`src/bin/main1.rs`和`src/bin/main2.rs`，它们会分别生成一个文件同名的二进制可执行文件
- 集成测试文件：`tests`目录下
- 基准性能测试benchmark文件：`benches`目录下
- 项目示例：`examples`目录下

要注意的是上面的这些是Cargo的默认规范，但你可以不跟据规范来，比如你想在一个自定义的文件夹底下放一个`main3.rs`，你可以在`Cargo.toml`内用`[[bin]]`来指定一个二进制项的包。就像这样：

```
[[bin]]
name ="myproject"
path ="src/myproject/bin/main3.rs"
```

但我们一般不会这么做，使用规范肯定要更加合适。

上面我们这样定义的`src/lib.rs`也好`src/main.rs`也好，其实是一个crate的一个**根文件**，编译器在编译时，会通过这个根文件里写的`use`语句按照一定的规则查找相对路径底下的一些crate的其他文件，并且将文件共同串联组成一个crate的树，这棵树叫做**模块树**

## 模块

```rust
mod my_mod {
  fn private_function() {
        println!("called `my_mod::private_function()`");
    }
  pub fn function() {
      println!("called`my_mod::function()`");
  }
}
```
这里用`mod`关键字声明了一个名叫`my_mod`的一个**模块/module**

### 引用模块内的东西
类似于C++的namespace，你可以使用相对路径，绝对路径来访问模块内的东西(前提是下面提到的可见性要符合)

```rust
mod front_of_house {
    mod hosting {
        fn add_to_waitlist() {}
    }
}

pub fn eat_at_restaurant() {
    // 绝对路径
    crate::front_of_house::hosting::add_to_waitlist();

    // 相对路径
    front_of_house::hosting::add_to_waitlist();
}
```

- 绝对路径：以crate(会指向当前所在包名)或者包名起手开始逐级下来，使用crate作为开始就和使用`/`作为开始一样。
- 相对路径：相比绝对路径少了crate根到当前module

还有一些小点子
`super`关键字，在相对路径中可以作为相对路径的开头，它代表的是当前module的父module，你可以连着使用`super`
`self`关键字，在相对路径中可以作为相对路径的开头，它代表的就是当前module

### 可见性
模块内的东西具有可见性，默认为私有，加上`pub`关键字可以使得其内部的函数，结构体之类的东西能够被外部访问，但在模块内部，是可以访问的，模块本身可以嵌套，我们可以在这个`my_mod`内同样的写一个`my_mod2`

但注意：
- 将结构体设置为`pub`，但它的所有字段依然是私有的
- 将枚举设置为`pub`，它的所有字段也将对外可见

### 模块内容存于文件(夹)中
当你使用在某个文件中使用`mod something`定义一个模块时，你可以在这个文件的相对路径下方创建一个文件或者文件夹来将花括号`{}`中的内容放到文件/文件夹下的`mod.rs`中，但要求这个文件就叫`something.rs`或者文件夹名字`something`(显然是一种规范)，如此，模块的声明和实现是分离的

看看下面这个例子：

```
.
├── Cargo.toml
├── Cargo.lock
└── src
    ├── main.rs
    ├── something1.rs
    └── something2
        └── mod.rs
        └── something3.rs
```

```rust
/*---src/main.rs---*/
mod something1;
mod something2;

fn main(){
  something2::something3::fun();
}
```

```rust
/*---src/something2/something3.rs---*/
pub fn fun(){
  println!("call something3");
}
```

```rust
/*---src/something2/mod.rs---*/
mod something3;

pub fn fun(){
  println!("call something2");
}
```

## 使用use引用模块
嗯，有一种python import的感觉

- 可以用与module定义一致的相对引用与绝对引用的方式来减少写一长串的引用，减少`::`的个数(尽管某些C++程序员觉得很多的`::`很酷)
  减少的方式就是，像上面这个[模块内容存于文件(夹)中](#模块内容存于文件(夹)中)所给出的例子来看，你可以使用`use something2::something3::fun;`令你以后使用fun的时候可以不用输入前面的一串，当然你也可以只引入一个module，即`use something2::something3;`，那么你使用时就要`something3::fun();`了
  总之就是，什么在use那一串的最后就拿他起手
- 解决冲突，当你use了两个相同的函数，这必然会导致和C++命名空间污染一样的编译期错误，这要求你尽量避免这种引用，当然即使你这么做了，你仍然可以在函数前面加上`mod_name::`的前缀去修正这个冲突
- 对于同名冲突问题，还可以使用 as 关键字来解决，它可以赋予引入项一个全新的名称：`use std::io::Result as IoResult;`
- 用花括号减少写多行的引用：`use std::{cmp::Ordering, io};`
- 使用`*`引入模块下的所有项，就像我们在python中做的那样