---
title: C++模板基础
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - C++
abbrlink: 3187765d
---


# C++模板基础
为了我们能在接下来书写模板元编程前有一个良好的基础，我们必须先得了解C++模板的相关内容

<!--more-->

## TMP的简单介绍
在上世纪末，C++模板就被发现是图灵完备的，当时就有大佬利用编译器的报错，在编译器的输出里生成了质数序列

模板元编程，简称TMP，对于元编程的解释要从元程序来说

>**NOTE**: Metaprogram is a program about a program.

元程序是处理程序的程序，而元编程就是编写元程序的一种编程技巧。Python解释器就是一种元程序

C++模板元编程属于元编程中的一种(Metaprogramming in Host Language)，在这类元编程中，逻辑代码和元程序自身的代码是写在一起的，用同一种语言，元程序代码通过某种机制(通常是编译)转变为(或者说生成)逻辑代码，并与其他逻辑代码合并到一起。这就产生一种效果，这个元程序看起来像是在自己改写自己。C++TMP的代码与普通的C++代码写在一起，但TMP的逻辑在编译期执行，而普通C++代码的逻辑在运行期执行。

所以说C++TMP是用于一些编译期的运算，类型的计算，也能进一步美化代码，甚至是效率更高的编译期多态。

C++模板元和宏搭配起来可以被称为是黑魔法，但是缺点也很明显，只能对编译期起到作用，而且缺少debug的工具，debug异常困难

## 模板的声明与定义
在C++中，我们一共可以声明5种不同的模板，分别是：**类模板、函数模板**、**变量模板(C++14)**、**别名模板(C++11)**和**Concept(C++20)**

特别提醒，Concept我们后面提及

```cpp
// declarations
template <typename T> struct  class_tmpl;
template <typename T> void    function_tmpl(T);
template <typename T> T       variable_tmpl;          // since c++14
template <typename T> using   alias_tmpl = T;         // since c++11
template <typename T> concept no_constraint = true;   // since c++20
```

> **INFO**: 可以看到关键的东西已经接触到了C++11，这倒不是说较旧的C++不能实现模板元，只是一般来说这些东西都会在相对来说modern cpp来进行

对于前三种模板可以拥有定义
```cpp
// definitions
template <typename T> struct  class_tmpl {};
template <typename T> void    function_tmpl(T) {}
template <typename T> T       variable_tmpl = T(3.14);
```

可以看到，对于类模板、函数模板和变量模板，它们的声明和定义与普通的类、函数和变量一致，区别仅是在开头多了一个`template`关键字以及一对尖括号`<...>`

尖括号中声明了模板的参数。参数通常是类型，因为模板的发明就是为了实现泛型编程。也正是因为如此，模板一开始就不是为了元编程来的，所以它的确很难


## 模板形参
在模板中，我们可以声明三种类型的形参，分别是：**非类型模板形参**、**类型模板形参**和**模板模板形参**

```cpp
// There are 3 kinds of template parameters:
template <int n>                               struct NontypeTemplateParameter {};
template <typename T>                          struct TypeTemplateParameter {};
template <template <typename T> typename Tmpl> struct TemplateTemplateParameter {};
```

其中，非类型的形参接受一个确定类型的常量作为实参，例如在上面的例子中，模板`NontypeTemplateParameter`接受一个int类型的常量。更一般地，非类型模板形参必须是结构化类型的，主要包括：

- 整型，如`int, char, long`
- `enum`类型
- 指针和引用类型
- 浮点数类型和字面量类型(C++20后)
- 要注意的是，非类型模板实参**必须是常量**，因为模板是在编译期被展开的，在这个阶段只有常量，没有变量。

要注意的是，非类型模板实参必须是常量，因为模板是在编译期被展开的，在这个阶段只有常量，没有变量。

对于类型模板形参，我们使用`typename`/`class`关键字声明它是一个类型。对于模板模板形参，和类模板的声明类似，也是在类型的前面加上`template <...>`。模**板模板形参只接受类模板或类的别名模板作为实参，并且实参模板的形参列表必须要与形参模板的形参列表匹配**。要注意的是，关键字`typename`和`class`是完全等效的，唯一的不同就是字面语义。

一个模板可以声明多个形参，更一般地，可以声明一个变长的形参列表，变长形参列表可以接受0个或多个非类型常量、类型、或模板作为模板实参。变长形参列表必须出现在所有模板形参的最后。

```cpp
template <int... Args>                            struct VariadicTemplate1 {};
template <int, typename... Args>                  struct VariadicTemplate2 {};
template <template <typename T> typename... Args> struct VariadicTemplate3 {};
```

模板可以声明默认实参，与函数的默认实参类似。只有主模板才可以声明默认实参，模板特化不可以。
```cpp
// default template argument
template <typename T = int> struct TemplateWithDefaultArguments {};
```

## 模板实例化
是指由泛型的模板定义生成具体的类型、函数、和变量的过程。模板在实例化时，模板形参被替换为实参，从而生成具体的实例。
模板的实例化分为两种：**隐式实例化**和**显式实例化**，其中隐式的实例化是我们平时最常用的实例化方式。