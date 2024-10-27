---
title: C++模板元-欧拉函数表
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - C++
abbrlink: acc766b1
---


# C++模板元-欧拉函数表
SAST 2023 C++组免试题之模板元编程部分，本身是一个小玩具，不具有多少实际意义
<!--more-->

## 代码
```c++
#include <iostream>
#include <type_traits>

constexpr unsigned int eulerFunction(unsigned int n)
{
    unsigned int ans = n;
    for (unsigned int i = 2; i * i <= n; i++)
        if (n % i == 0)
        {
            ans = ans / i * (i - 1);
            while (n % i == 0)
                n /= i;
        }
    if (n > 1)
        ans = ans / n * (n - 1);
    return ans;
}

template <unsigned int... pack>
struct function2List
{
    constexpr static unsigned int length = sizeof...(pack);
    constexpr static unsigned int value[sizeof...(pack)] = {eulerFunction(pack)...};
};

constexpr unsigned int log2_func(unsigned int x)
{
    int ans = 0;
    while (x >>= 1)
        ++ans;
    return ans;
}

template <unsigned int N, typename T, unsigned int temp, unsigned int MAX, unsigned int... pack>
struct generatorList : generatorList<N, void, temp - 1, 2 * MAX, pack..., (pack + MAX)...> {};

template <unsigned int N, unsigned int temp, unsigned int MAX, unsigned int... pack>
struct generatorList<N, std::enable_if_t<(N >> (temp - 1)) % 2, void>, temp, MAX, pack...> : generatorList<N, void, temp - 1, 2 * MAX + 1, 1, (pack + 1)..., (pack + MAX + 1)...> {};

template <unsigned int N, unsigned int... pack>
struct generatorList<N, void, 0, N, pack...> : function2List<pack...> {};

template <unsigned int N>
struct EulerFunctionList : generatorList<N, void, log2_func(N) + 1, 0> {};

int main()
{
    constexpr unsigned int N = 50000;
    for (auto i = 0; i < EulerFunctionList<N>::length; i++)
    {
        std::cout << EulerFunctionList<N>::value[i] << " ";
    }
    return 0;
}
```

## 解释
这里`eulerFunction`函数为C++17的`constexpr`函数，可以在编译器执行并获取到输入值的欧拉函数

模板递归部分利用了形参包的多次展开，做到二分法的序列生成，大大提高了自然数序列生成的效率，减少了模板迭代的次数，可以有效的在编译器默认允许的范围内打出更大的值