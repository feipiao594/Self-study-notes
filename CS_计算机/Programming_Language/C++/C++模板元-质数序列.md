---
title: C++模板元-质数序列
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - C++
date: 2023-07-08
abbrlink: 3187765d
---


# C++模板元-质数序列
花了一点时间巩固自己的模板元编程，写了一个编译期质数数组生成器
<!--more-->

## 代码
```c++
#include <iostream>

template <bool b>
struct bool_instant
{
    constexpr static int value = b;
};

using true_instant = bool_instant<true>;
using false_instant = bool_instant<false>;

template <int... pack>
struct intArrayPack
{
    constexpr static int length = sizeof...(pack);
    constexpr static int value[sizeof...(pack)] = {pack...};
};

template <int N, int current = 2, int flag = 0>
struct isPrime : isPrime<N, current + 1, !!!(N % current)>{};

template <int N>
struct isPrime<N, N, 0> : true_instant{};

template <int N, int current>
struct isPrime<N, current, 1> : false_instant{};

template <int N, int current = 2, bool flag = false, int... pack>
struct primePack : primePack<N, current + 1, isPrime<current>::value, pack...>{};

template <int N, int current, int... pack>
struct primePack<N, current, true, pack...> : primePack<N, current, false, current - 1, pack...>{};

template <int N, int... pack>
struct primePack<N, N, false, pack...> : intArrayPack<pack...>{};

int main()
{
    auto numlist = primePack<220>::value;
    for (auto i = 0; i < primePack<220>::length; i++)
    {
        std::cout << numlist[i] << " ";
    }
    return 0;
}
```

## 讲解
```c++
primePack<220>::value
```

输出**小于**输入数字的所有质数组成的数组

```c++
primePack<220>::length
```

输出上述数组的长度


重要的是`intArrayPack`这种通过形参包生成对应序列的方法，以及`primePack`这种通过`true`和`false`，利用模板特化进行`if`的模式

本身代码在`MSVC for amd64`最大只能输出到227的质数，在之后就会报错，原因是**模板递归超过上限**，因而代码仍需要优化，但作为一个练手的，第一次写模板元编程，也挺不错的