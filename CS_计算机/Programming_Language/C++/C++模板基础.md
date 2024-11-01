---
title: C++模板基础
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - C++
date: 2023-07-10
abbrlink: cabf03c1
---


# C++模板基础
为了我们能在接下来书写模板元编程前有一个良好的基础，我们必须先得了解C++模板的相关内容

<!--more-->
## 参考内容
Cppreference: https://zh.cppreference.com/w/%E9%A6%96%E9%A1%B5
知乎文章: https://zhuanlan.zhihu.com/p/378355217

## TMP的简单介绍
在上世纪末，C++模板就被发现是图灵完备的，当时就有大佬利用编译器的报错，在编译器的输出里生成了质数序列

模板元编程，简称TMP，对于元编程的解释要从元程序来说

>**NOTE**: Metaprogram is a program about a program.

元程序是处理程序的程序，而元编程就是编写元程序的一种编程技巧。Python解释器就是一种元程序

C++模板元编程属于元编程中的一种(Metaprogramming in Host Language)，在这类元编程中，逻辑代码和元程序自身的代码是写在一起的，用同一种语言，元程序代码通过某种机制(通常是编译)转变为(或者说生成)逻辑代码，并与其他逻辑代码合并到一起。这就产生一种效果，这个元程序看起来像是在自己改写自己。C++TMP的代码与普通的C++代码写在一起，但TMP的逻辑在编译期执行，而普通C++代码的逻辑在运行期执行。

所以说C++TMP是用于一些编译期的运算，类型的计算，也能进一步美化代码，甚至是效率更高的编译期多态。

C++模板元和宏搭配起来可以被称为是黑魔法，但是缺点也很明显，只能对编译期起到作用，而且缺少debug的工具，debug异常困难

## 模板的声明与定义
<img src="/images/C++模板基础_图1.png" width="100%" height="100%">
(上图摘自cppreference)

在C++中，我们一共可以声明5种不同的模板，分别是：**类模板、函数模板**、**变量模板(C++14)**、**别名模板(C++11)**和**Concept(C++20)**

特别提醒，Concept作为较新的特性，放到最后我们再来说说

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
在模板中，我们可以声明三种类型的形参，分别是：**非类型模板形参**、**类型模板形参**和**模板模板形参(C++17)**

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
**cppreference**: https://zh.cppreference.com/w/cpp/language/function_template

是指由泛型的模板定义生成具体的类型、函数、和变量的过程。模板在实例化时，模板形参被替换为实参，从而生成具体的实例。
模板的实例化分为两种：**隐式实例化**和**显式实例化**，其中的**隐式的实例化**是我们平时最常用的实例化方式
采用隐式的实例化时，编译器就会在编译时根据你具体使用模板的类型，用模板生成对应的真正的函数定义，类定义等。

> **NOTE**:模板自身并不是类型、函数或任何其他实体。不会从只包含模板定义的源文件生成任何代码。模板只有实例化才会有代码出现

为了实例化一个模板，编译器需要知道所有的模板实参，但不是每个实参都要显式地指定。有时，编译器可以根据函数调用的实参来推断模板的实参，这一过程被称为**模板实参推导**。对每一个函数实参，编译器都尝试去推导对应的模板实参，如果所有的模板实参都能被推导出来，且推导结果不产生冲突，那么模板实参推导成功。C++17引入了类模板实参推导，可以通过类模板的构造函数来推导模板实参


```cpp
template<typename T>
void f(T s1, T s2)
{
    std::cout << s << '\n';
}

int main(){
  double pi_double = 3.14;
  int pi_int = 3;
  f(pi_double, pi_double); 
  f(pi_int, pi_double); //error
  f<double>(pi_int, pi_double);
}
```

## 模板特化

模板特化，望文生义，即特殊化模板参数列表中的一部分，使得他在模板实参输入特殊输入的时候，采用特殊化的模板定义，这里涉及到编译器会从所有的特化版本中选择的问题，其中有一套固定的选择的逻辑，利用这一**选择**特性使得它可以实现逻辑判断，甚至做到编译期的图灵完备，具体让我们来看看

### 部分模板特化/偏特化
<img src="/images/C++模板基础_图2.png" width="100%" height="100%">
(上图以及下面的例子摘自cppreference)

```cpp
template<class T1, class T2, int I>
class A;             // 主模板
 
template<class T, int I>
class A<T, T*, I> {};   // #1：部分特化，其中 T2 是指向 T1 的指针
 
template<class T, class T2, int I>
class A<T*, T2, I> {};  // #2：部分特化，其中 T1 是指针
 
template<class T>
class A<int, T*, 5> {}; // #3：部分特化，其中 T1 是 int，I 是 5，T2 是指针
 
template<class X, class T, int I>
class A<X, T*, I> {};   // #4：部分特化，其中 T2 是指针
```

看起来有点复杂对吧，说点人话，我们可以粗略的理解为，在原本的模板上又定义了全新的模板，即上述这个例子，在#1-#4中，我们可以把第一行template盖住，下面看作使用模板，但是我们又把这个使用模板的行为套了一层模板。但这种理解从替换的角度而言是不正确的，但能阐释它的写法了
要注意的是，后面这个尖括号里面填的是主模板的实参列表，而外面套的偏特化的形参列表可以随意发挥(当然也有一定的限制，比如偏特化一定要比主模板更特殊等，一共有好几条，具体可以搜索cppreference)，只要能匹配到就行了

### 显式具体化/模板全特化
全特化的语法也用人话说就是，当模板中所有的部分全部确定，偏特化到极点，使得`template <...>`的尖括号里不需要放任何东西，就换了个名字，称为全特化，很形象吧
要注意全特化和显式实例化的写法很类似，不要混淆
```cpp
// Don't mix the syntax of "full specialization declaration" up with "explict instantiation"
template    void foo<int, int>;   // this is an explict instantiation
template <> void foo<int, int>;   // this is a full specialization declaration
```


模板的特化允许我们替换一部分或全部的形参，并定义一个对应改替换的模板实现。其中，**替换全部形参的特化称为全特化，替换部分形参的特化称为偏特化**，非特化的原始模板称为主模板。只有类模板和变量模板可以进行偏特化，函数模板只能全特化。
在实例化模板的时候，编译器会从所有的特化版本中选择**最匹配的那个实现来做替换**，如果没有特化匹配，那么就会选择主模板进行替换操作。

> **INFO**:在这里要另外提一个事情，C++中有部分概念的翻译没有那么的好，就像这里将要提到的全特化，有好几种叫法，比如显式模板特化，还有一种叫法是显式具体化，在我写这份文档的时候也对我产生了一点困惑。其实去各大平台和cppreference搜一搜就会发现，显示具体化就是Explicit specialization这个术语，也就是模板全特化，所以在学习时，还请**中英文结合学习**，当然我本人英语很差，如果各位可以不必借助翻译软件就畅读英文文献，自然是能获得最好的学习体验的

## C++ Templates——SFINAE
到了SFINAE正式开始上强度
SFINAE是“Substitution failure is not an error.”的缩写。意为替换失败并非一个错误
根本方法是利用函数重载和静态行为(static, sizeof，constexpr等，即编译期确定行为)。

怎么理解SFINAE这个东西呢？还记得我们刚刚提到的模板特化有一套选择的方法吧，再想想我们这次SAST笔试题C++组出的题，重点考察了函数重载决议的内容，编译器也会在你调用函数时在所有的函数重载版本中挑选一个最符合的版本进行调用，而这种选择，和存在模板特化的主模板调用时的在众多特化版本中的选择是有异曲同工之妙的，在这些“选择”发生时，如果有一个重载版本或者特化版本选不上的时候，编译器会忽略它，尝试匹配下一个，而不抛出错误


## 实例化的过程
> **NOTE**: 我觉得这部分是最重要的，C++14前的模板元要想实现复杂的功能，完全利用了泛型模板实现的细节顺序，正如我所说的，模板一开始不是为了元编程所服务的，所以抠顺序的细节去实现“黑魔法”

整个实例化的过程具体的步骤是这样的，当一个实例化发生时，编译器：
1. 进行名字查找，找到所有匹配该名字的模板
   - 如果是函数模板，可能会找到一个或多个重载
   - 如果是类/变量模板，应找到唯一一个主模板，否则报错:重定义
2. 确定所有的模板实参，需要推导的，通过主模板来推导
   - 对函数模板，如果推导失败，那么这个模板从重载集中剔除
   - 对类/变量模板，如果推导失败，则抛出错误
3. 对函数模板，进行重载决议，决议时只考虑主模板，偏序规则和SFINAE在此发挥作用
4. 对确定的主模板和它的特化，选择最匹配的那个
   - 对类/变量模板，因为存在偏特化，偏序规则和 SFINAE 在此发挥作用
   - 对函数模板，只有全特化，直接匹配就行了
5. 对最终选定的主模板或特化进行替换，生成真实代码，放到 POI 中


## `type_traits`

不知道大家有没有听过`type_traits`这个标准库，它的译名叫做类型萃取，顾名思义，就是把类型提取出来，其中有许多好东西：`std::is_class`/`std::is_same`/`std::is_base_of`/...，他们其中有许多都是模板元编程的产物，我们挑点简单的例子来看看这些东西是怎么实现的吧



### template is_void_v<>
```cpp
template <typename T>
struct is_void{
  constexpr static bool value = false;
};

template <>
struct is_void<void>{
  constexpr static bool value = true;
};

template <typename T>
constexpr bool is_void_v = is_void<T>::value;


//调用
is_void_v<int>
```

### template is_reference<>
```cpp
template <typename T> struct is_reference      { static constexpr bool value = false; };    // #1
template <typename T> struct is_reference<T&>  { static constexpr bool value = true; };     // #2
template <typename T> struct is_reference<T&&> { static constexpr bool value = true; };     // #3

std::cout << is_reference<int>::value << std::endl;    // 0
std::cout << is_reference<int&>::value << std::endl;   // 1
std::cout << is_reference<int&&>::value << std::endl;  // 1
```

### is_class
从前的版本
```cpp
template<typename T>
struct is_class {
    typedef char success [1];
    typedef char failure [2];
    //注意编译器对函数重载的匹配顺序：
    template<typename U> static success& test(void U::* p) {}
    template<typename U> static failure& test(...) {}
    
    enum {value = sizeof(test<T>(NULL)) == sizeof(success)}
}
```
如今的版本
```cpp
template<typename T>
struct is_class {
    //void *不行了
    template<typename C> static constexpr bool test(int C::* p) { return true; }
    template<typename> static constexpr bool test(...) { return false; }
     
    static constexpr bool value = test<T>(NULL);
}
```

## 总结
这些只是一个概览，具体的细节留到提高篇针对单一情况具体说明，下次，我们会对更多的代码例子进行导读