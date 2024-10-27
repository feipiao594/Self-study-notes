---
title: Pytorch学习_2
mathjax: true
categories:
  - CS_计算机
  - Programming_Language
  - Python
abbrlink: f5767f6a
---

# Pytorch学习_2
隔了有一段时间没写东西了，前一篇主要是一些准备的工作，这次我们从线性回归开始

<!--more-->

## 概览神经网络
- 机器学习模型中的关键要素是训练数据、损失函数、优化算法，还有模型本身。
- 矢量化使数学表达上更简洁，同时运行的更快
- 最小化目标函数和执行极大似然估计等价
- 线性回归模型也是一个简单的神经网络

## 线性回归的从零开始实现
先把包引入一下
```python
%matplotlib inline
import random
import torch
from d2l import torch as d2l
```
注意第一行中的`%matplotlib inline`语句被称为魔法语句。作用就是这样图像就会出现在Jupyter Notebook里面，而不是一个新窗口里。对于纯纯使用vscode的我来说用处不大

首先为了简单起见，我们用带有噪声的线性模型手动构造一个人造数据集。首先生成一个包含1000个样本的数据集，每个样本包含从标准正态分布
我们使用线性模型参数$\mathbf{w}=[2,-3.4]^T$、$b=4.2$和噪声项$\epsilon$生成数据集及其标签：
$$
\mathbf{y}=\mathbf{Xw}+b+\epsilon
$$
$\epsilon$可以被视作模型预测和标签时的潜在观测误差。在这里我们认为标准假设成立，即$\epsilon$服从均值为0的正态分布。为了简化问题，我们将标准差设为0.01.下面的代码生成数据集

```python
def synthetic_data(w, b, num_examples): #@save
# 生成y=Xw+b噪声
  X = torch.normal(0, 1, (num_examples, len(w)))
  y = torch.matmul(X, w) + b
  y += torch.normal(0, 0.01, y.shape)
  return X, y.reshape((-1, 1))
```

> 注:`torch.matmul`是`tensor`的乘法，输入可以是高维的。当输入都是二维时，就是普通的矩阵乘法，和`tensor.mm`函数用法相同。

```python
true_w = torch.tensor([2, -3.4])
true_b = 4.2
features, labels = synthetic_data(true_w, true_b, 1000)
```


