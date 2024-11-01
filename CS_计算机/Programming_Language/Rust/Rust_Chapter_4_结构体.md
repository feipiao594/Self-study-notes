---
title: Rust_Chapter_4_结构体
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - Rust
date: 2023-07-08
abbrlink: ae9548c
---


# Rust_Chapter_4_结构体
对于早期学习了C++的我来说，OOP是很重要的东西，因而同理Rust里的结构体也是极其重要的

<!--more-->

## 结构体的定义与实例化
和元组不一样的是，结构体需要给每个数据赋予名字以便清楚地表明它们的意义。正是由于有了这些名字，结构体的使用要比元组更加灵活：你不再需要依赖顺序索引来指定或访问实例中的值。

### 结构体的定义
关键字struct被用来定义并命名结构体，一个良好的结构体名称应当能够反映出自身数据组合的意义。除此之外，我们还需要在随后的花括号中声明所有数据的名字及类型，这些数据也被称作字段。如下代码展示了一个用于存储账户信息的结构体定义：
```rust
struct User {
  username: String,
  email: String,
  sign_in_count: u64,
  active: bool,
}
```

注意到这里与C++不同的语法，首先类型后置不必多言，所有类型结尾都要接上一个逗号`,`，而且结构体声明的最后也不需要加上一个在C/C++中很容易忘掉的分号`;`

### 结构体的实例化

直接看代码，和C++很不一样，这里首先要**加上成员变量的名字**，再把Rust结构体的定义中的类型名换成具体的名字。注意到这里是一条语句，所以语句的结尾要加上分号`;`

```rust
let user1 = User {
  email: String::from("someone@example.com"),
  username: String::from("someusername123"),
  active: true,
  sign_in_count: 1,
};
```

在获得了结构体实例后，我们可以通过**点号**来访问实例中的特定字段(熟悉的语法)。
如果你想获得某个用户的电子邮件地址，那么可以使用`user1.email`来获取。另外，**假如**这个结构体的**实例是可变**的(结构体的定义当然无关可不可变)，那么我们还可以通过点号来修改字段中的值。示例5-3展示了如何修改一个**可变**`User`实例中`email`字段的值

```rust
let mut user1 = User {
  email: String::from("someone@example.com"),
  username: String::from("someusername123"),
  active: true,
  sign_in_count: 1,
};
user1.email = String::from("anotheremail@example.com");
```

需要注意的是，一旦实例可变，那么实例中的所有字段都将是可变的。**Rust不允许我们单独声明某一部分字段的可变性**。如同其他表达式一样，我们可以在函数体的最后一个表达式中构造结构体实例，来隐式地将这个实例作为结果返回。

下面这个例子中的`build_user`函数会使用传入的邮箱和用户名参数构造并返回`User`实例。另外两个字段`active`和`sign_in_count`则分别被赋予了值true和1。
```rust
fn build_user(email: String, username: String) -> User {
  User {
    email: email,
    username: username,
    active: true,
    sign_in_count: 1,
  }
}
```

