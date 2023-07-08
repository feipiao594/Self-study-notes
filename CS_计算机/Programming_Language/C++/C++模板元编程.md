---
title: C++模板元编程
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - C++
abbrlink: 9244e40f
---


# C++模板元编程
之前看到一个说法，说正常用模板就是模板编程，神神叨叨用模板就是模板元编程，我深以为然，但是模板这东西他提供的编译期运算太过于强大，而且STL里面的内容大量的用到了模板，我觉得我还是有必要写一写东西的。

<!--more-->

## 推荐
推荐一个[知乎链接](https://zhuanlan.zhihu.com/p/378355217)，作者的讲述非常优秀
模板元编程是一个庞大的课题，我打算慢慢写它

## 一些零碎的理解
由于本人也学艺不精，所以这个板块先写一些临时的感悟啥的，以及学习时候使用的一些例子

### std::enable_if的一种用法

学习时候用到测试代码如下
```cpp
#include <iostream>
#include <type_traits>

template <typename T, typename N = void>
struct test
{
    constexpr static int value = 0;
};

template <typename T>
struct test<T, std::enable_if_t<std::is_same_v<T, int>, void>>
{
    constexpr static int value = 1;
};

int main()
{
    std::cout << test<int>::value;//1
    std::cout << test<char>::value;//0
    return 0;
}
```

通过一个迂回的方式来判断一个类型是不是int类型，当然我只是想叙述`std::enable_if`应该怎么用，这个模板是输入两个参数，第一个是`bool`类型，第二个是当输入`true`时，其`type`是什么类型，由于`std::enable_if`所返回的类型任意，且利用偏特化进行分支选择时，其主模板，和`std::enable_if`所处同样位置必须时模板`typename T`，且由于一般不会写上`enable_if`这一个位置的类型，主模板必须缺省，缺省`void`就是一个好选择

注意特化和函数的默认参数不同，可以特化任意位置的参数，如我们可以特化如下：
```cpp
template<typename N>
struct MyTemplateType<float, N>
{
    //content
};
```

利用上述特化的性质，`enable_if`可以塞在模板参数中间，但以我之见，在其等价位置的后方应该只存在形参包或者有缺省值的模板参数