---
title: Pytorch学习_3
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - Python
abbrlink: 82714ffc
date: 2025-04-17 09:06:54
---

# Pytorch学习_3
距离上次写 pytorch 相关的东西已经过了很久，也是看了另一些去学习

<!--more-->

## 一些变化
我并不是很喜欢 AI ，感觉大家都过于看重 AI 了，其实它也就是一个普普通通的工具罢了，而且使用的技术入门十分容易，并没有大家想象的那么高深，它不是一个万能钥匙，能开世界上任何一扇门
中文互联网上有太多 pytorch 的资料了，但是这些资料大多都不止是在讲 pytorch 本身，他们大多有一个"利好初学者"的标签，但是往往这时候意味着他们对 pytorch 本身这个库的诠释完全不足，所以最近我选择了直接去看 pytorch 的官方文档，总算是总结出来了一些东西。

## Tensor 的一些新理解
pytorch 里面我个人认为最重要的库就是 Tensor 库，它定义了 Tensor 和其他一系列和 Tensor 计算有关的函数。但 Tensor 这个名字很有趣，它来自于数学，它的标准中文译名叫**张量**，在中文互联网(bing)上搜索 Tensor ，你得到的前几条信息都是深度学习 pytorch 里的 Tensor ，但是你如果搜索它的中文名张量，你得到的就是数学和物理里的那个张量，这很有趣了 :)

> 我个人认为 Tensor 是纯纯的名词污染，我并不认为这个东西它是一个张量在欧式空间上的矩阵表示，即使它确实等价，但你不可以用一个东西的片面去描述一个东西，就像，还有些朋友认为它和 numpy 里的数组之间最大的差别是它可以交给 GPU 去处理所以要取一个和数组不一样的高大上的名字，但我作为一个 C/C++ 程序员，成天能和底层打交道，觉得这个纯是扯了

言归正传，在我看来 Tensor 和普通的n维数组最大的差别是，Tensor 中有一个计算图累加的概念，简单来说，Tensor 这个类中有一个成员变量"存储"了得到这个 Tensor 通过了什么运算，这个就是计算图，你使用的 Tensor 只会调用 pytorch 里的 Tensor 数学运算函数进行运算，原因是这些数学运算函数不止做了 Tensor 的运算，他们同时承担了这个成员变量的计算图计算的内容，而如果你自己实现一个 Tensor 的运算，你就要手动去实现这个计算图拼合的行为。

懵懵的？举个例子，`torch.matmul` 是 `Tensor` 的乘法，在上一章我们讲过，事实上 Tensor 的运算都是**输入(单个或者多个) Tensor 输出 Tensor 的函数**，对于乘法，它实质上会提取输入的两个 `Tensor` 里面成员变量存储的计算图，用一个乘号把他们相连，同时数值也会被相乘，最后输出的 Tensor 就是一个数值是前两个 Tensor 计算的结果，同时计算图是前两个 Tensor 的计算图加一个乘号拼合的结果

### 看看 Tensor 机理
你也许会好奇，口说无凭，Tensor 在 pytorch 上的原文就是说的不同于 numpy 的 ndarrays 之处就只是可以在 GPU 或其他硬件加速器上运行:

> Tensors are similar to NumPy’s ndarrays, **except that Tensors can run on GPUs or other hardware accelerators**. In fact, Tensors and NumPy arrays can often share the same underlying memory, eliminating the need to copy data (see Bridge with NumPy). Tensors are also optimized for automatic differentiation (we’ll see more about that later in the Autograd section). If you’re familiar with ndarrays, you’ll be right at home with the Tensor API. If not, follow along! (https://pytorch.org/tutorials/beginner/basics/Tensorqs_tutorial.html)

以及看看文档里说的 Tensor 的成员变量



>In PyTorch, a regular Tensor is a multi-dimensional array that is defined by the following components:
>>**Storage**: The actual data of the Tensor, stored as a contiguous, one-dimensional array of bytes.
>>**dtype**: The data type of the elements in the Tensor, such as torch.float32 or torch.int64.
>>**shape**: A tuple indicating the size of the Tensor in each dimension.
>>**Stride**: The step size needed to move from one element to the next in each dimension.
>>**Offset**: The starting point in the storage from which the Tensor data begins. This will usually be 0 for newly created Tensors.
>
>These components together define the structure and data of a Tensor, with the storage holding the actual data and the rest serving as metadata.
>(https://pytorch.org/docs/stable/storage.html)

这压根没提到计算图啊，博主你这是给我们干哪来了，这还是 Tensor 么，别急，让我们深入代码看看实际的机理来佐证我们刚刚说的话

首先看 Python 侧的 Tensor 定义，发现它继承自一个 `torch._C.TensorBase` ，同时追踪观察 `torch.matmul` 发现追踪到了一个 `.pyi` 的文件里，所以其实现明显不是 python 实现的，其实实际上它和 Tensor 都是通过 PyBind11 绑定到 C++ 的。让我们来看看 C++ 里它是怎么实现的

相关的文件有
- `aten/src/ATen/core/Tensor.h`
- `aten/src/ATen/core/Tensor.cpp`
- `aten/src/ATen/core/TensorBase.h`

在 TensoBase 里有一个这样的成员变量
```cpp
c10::intrusive_ptr<TensorImpl, UndefinedTensorImpl> impl_;
```

在这里提到的 `TensorImpl` 中，有一大段话描述了下面这个成员变量，这就是存储计算图的实际指针

```cpp
std::unique_ptr<c10::AutogradMetaInterface> autograd_meta_ = nullptr;
```

在上面的注释当中你可以知道 `autograd_meta_` 指向了和梯度有关的信息，比如 `grad_fn`

你自己构造的 Tensor 是计算图中的叶子节点，它的grad_fn 为 None

这就是计算图的存储，可想而知，其实计算的函数会更新这个 Tensor 的计算图，而 Tensor 的核心其实就是这个在 C++ 侧没被文档所写出来的计算图相关的成员变量，当你计算梯度的时候，正是查看了这个成员变量的信息，因而能够计算出梯度来，所以能计算梯度的也是 Tensor

> 如果要我给 Tensor 下一个定义的话，那么我会说，**Tensor 就是一个保存了历史计算方式的多维数组类，同时其有在 CPU 或其他来加速存储的能力**
> 其实在 GPU 上跑个人感觉完全不是一个核心的概念值得多言，难道计算机图形学里的 shaders 算的那些东西都是 Tensor 吗

## 鸣谢
这篇博客的另一位贡献者 Github@besthope-official ，一开始是他的探索才让我研究这个比较容易，这份博客也有他的一份力