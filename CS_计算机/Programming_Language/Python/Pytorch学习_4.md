---
title: Pytorch学习_4
mathjax: false
categories:
  - CS_计算机
  - Programming_Language
  - Python
abbrlink: 1c15da5f
date: 2025-04-17 15:53:52
---

# Pytorch学习_4
在上一章我们知道了 pytorch 的核心机制 Tensor 的计算图与梯度运算，接下来一切都是对它的封装

<!--more-->

## 相关的概念
`nn.Parameter`，`nn.forward`，`nn.Module`
我一开始学的时候觉得这些东西好复杂，一点都没有章法，我自己学习的时候时常会想，如果使用 Rust 里的 Trait 概念或者 Haskell 的 TypeClass 是不是能把它描述的更清楚一些，但是初学者友好的文档并不会告诉我这些。
在看完 Pytorch 的官方文档后我终于看明白了
关于看完 Pytorch 官方文档后一个上午写出来的一个手写数字识别 HelloWorld ：https://github.com/feipiao594/mnist_numrecg

## `nn.Module`
这是一个对 Tensor 的封装与管理函数，你需要实现的函数有两个 `__init__` 与 `forward` 函数，继承自 `nn.Module` 的层或者网络，有一个内秉的 parameter 集合，在 `__init__` 里面使用 `nn.Parameter` 就会把这个变量的引用交给这个 parameter 集合，如果你使用 `nn.Linear()` 里面也有 `nn.Parameter` 也会自动注册进去，这个函数就是起到这样的一个作用，同时因为他指定的是要被学习的参数，所以他也会把你输入进去的 Tensor 的 `require_grad` 变成 false。
`forward` 函数就是数值前向传播，就把在 `__init__` 定义的计算方法拿出来对输入的值运算一下 

## 优化器
举个例子
```python
optimizer = torch.optim.SGD(model.parameters(), lr=learning_rate)
```
`model.parameters()` 就是我们刚刚说到的 `nn.Module` 的子类有一个内秉的 parameter 集合，你可以通过这个方法传给优化器进行注册

```python
for batch, (X, y) in enumerate(dataloader):
        # Compute prediction and loss
        X, y = X.to(device), y.to(device)
        pred = model(X)
        loss = loss_fn(pred, y)

        # Backpropagation
        loss.backward()
        optimizer.step()
        optimizer.zero_grad()
```

具体使用时格式非常固定，loss 函数计算误差最后输出的就还是一个 Tensor ，其实里面还是保留计算图的，`loss.backward()` 就是用 Tensor 的 backward 把所有要学习的参数的梯度算出来并且存储在那些参数的成员变量里(毕竟参数也是 Tensor 嘛，它有 grad 成员变量作为他的梯度值很正常)，接着调用 `optimizer.step()` 来读取注册的这些变量的 grad 并执行优化，所以优化器和网络就完全解离，其实核心仍然在 Tensor 的梯度运算上

## 后话
听说 pytorch 已经很少有人像这样写网络了，大家都用 lightning ，后面有空我也会尝试一下的