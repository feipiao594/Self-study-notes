---
title: Pytorch学习_1
mathjax: true
categories:
  - CS_计算机
  - Python
abbrlink: 6c7f2ed0
---

# Pytorch学习_1

<!--more-->

## 关于tensor单独维度的计算
```python
# 单独维度求和示例程序
import torch

a = torch.rand(2, 3, 4, 5)
print(a)
print(torch.sum(a, dim=2))
# dim即在其余指标固定情况下，第n个数字指标求和相消
#体现在多维数组上即从内向外数相同的第n层，不跨越中括号的相同子tensor对应元素完全相加
```
该部分的某次运行结果如下
<img src="/images/Pytorch学习_1_图1.png" width="70%" height="70%">