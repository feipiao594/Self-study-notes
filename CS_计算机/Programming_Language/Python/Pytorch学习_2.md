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

注意第一行中的`%matplotlib inline`语句被称为魔法语句。作用就是这样图像就会出现在Jupyter Notebook里面，而不是一个新窗口里。对于纯纯使用vscode的我来说用处不大.