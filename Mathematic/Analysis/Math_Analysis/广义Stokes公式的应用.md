---
title: 广义Stokes公式的应用
mathjax: false
categories:
- Mathematic
- Analysis
- Math_Analysis
---

# 广义Stokes公式的应用
今天物理课上提到了转动惯量的计算，我还在纠结体积元素之时，发现老师直接给了结论，给的计算例题还是那种只需要一个坐标就可以表示的，还说如果质量不均匀分布就算不了了
我当然知道老师是什么意思，也**不是想抬杠**(迫真)，但听到这个我顿时来了兴致，于是经过了一天的计算，我给出了一些东西
<!--more-->

## 复习Stokes公式
对于 $n$ 维微分流形 $M$ ，$\Omega\subset M$ ，$\partial\Omega$ 是一个 $n-1$ 维微分流形，为 $M$ 的**边界**，$\omega$ 为 $(n-1)$ -形式，$d\omega$ 为 $n$ -形式，可得
$$\int_{\partial \Omega}\omega=\int_{\Omega}d\omega$$
利用stokes公式可以将微分形式降阶升阶来进行计算，例如把重积分降为曲线积分并换元，或者说升阶使得微分形式基变为1个，方便进行累次积分

## 随便构造的例子
记$\omega:\left \{(x,y)|x^2+y^2\le1\right \} $，则$\partial\omega:\left \{(x,y)|x^2+y^2=1\right \} $
$$
\psi = f_r\mathrm{d}r + f_\theta\mathrm{d}\theta +f_h\mathrm{d}h \\
\mathrm{d}\psi = (\frac{\partial f_r}{\partial \theta} - \frac{\partial f_\theta}{\partial r} )\mathrm{d}r \wedge \mathrm{d}\theta + (\frac{\partial f_h}{\partial \theta} - \frac{\partial f_\theta}{\partial h} )\mathrm{d}\theta \wedge \mathrm{d}h + (\frac{\partial f_r}{\partial h} - \frac{\partial f_h}{\partial r} )\mathrm{d}h \wedge \mathrm{d}r \\
\varphi  = f_1\mathrm{d}r \wedge \mathrm{d}\theta + f_2\mathrm{d}\theta \wedge \mathrm{d}h + f_3\mathrm{d}h \wedge \mathrm{d}r \\
\mathrm{d}\varphi = (\frac{\partial f_1}{\partial h} +\frac{\partial f_2}{\partial r} +\frac{\partial f_3}{\partial \theta})\mathrm{d}r \wedge \mathrm{d}\theta \wedge \mathrm{d}h
$$
从上面的式子可以看见，其实从高阶的微分形式向下变低阶的过程是一个**解PDE的过程**，而这里所解得的函数其实是非常多样的，只要满足约束的条件，随便什么函数都是可以的。
而且

## 证明
未完待续