---
title: 广义Fouier变换与Laplace变换
mathjax: true
categories:
  - EE_电子工程
  - 数字信号相关
date: 2023-08-08
abbrlink: f38b0ecb
---


# 广义Fouier变换与Laplace变换
这一篇记录广义函数的Fouier变换与Laplace变换的定义

<!--more-->

---

## 广义函数的卷积运算
设$f$，$g$为$\mathcal{D}^{\prime}(\Omega)$，而且至少有一个具有紧致集(即$\mathcal{E}'$)，定义$f*g$为$\mathcal{D}^{\prime}(\Omega)$广义函数
$$
\langle f*g,\varphi\rangle=\langle f(x),\langle g(y),\varphi(x+y)\rangle\rangle
$$

>$\mathcal{E}^{\prime}(\Omega)$与 $\mathcal{D}^{\prime}(\Omega)$ 之间的联系：设 $T\in D^{\prime}(\Omega),$ 则 $T\in\mathcal{E}^{\prime}(\Omega)$ 当且仅当 $\mathrm{supp} T$是中紧集



卷积运算满足结合律，交换律，分配律
$$f*g*h=f*(g*h)\qquad f*g=g*f$$
且关于Dirac函数满足
$$f*\delta=\delta*f=f$$

要注意的是，不存在一般情况下$f$，$g$为$\mathcal{D}^{\prime}(\Omega)$时候的卷积，不满足上面的定义时，只有一些特殊情况可以满足卷积存在

---

## Fouier变换
若$\varphi\in\mathscr{S}(\mathbb{R}^N)$，即速降函数(schwartz function)，定义$T\in\mathscr{S}'(\mathbb{R}^N)$的傅里叶变换如下
$$\langle\mathscr{F}T,\varphi\rangle=\langle T,\mathscr{F}\varphi\rangle $$
同理
$$\langle\mathscr{F}^{-1}T,\varphi\rangle=\langle T,\mathscr{F}^{-1}\varphi\rangle\\\langle\mathscr{F}^{-1}\mathscr{F}T,\varphi\rangle=\langle\mathscr{F}\mathscr{F}^{-1}T,\varphi\rangle=\langle T,\varphi\rangle$$

> 广义函数没有常义函数那种定义域，它只有作为泛函的定义域，就是整个函数空间，那么那种定义域不在整个n维欧式空间上的函数其实也是这个特殊函数空间的泛函

关于傅里叶变换，首先$\mathscr{F}$是$\mathscr{S}'\to\mathscr{S}'$的同构映射，而它的逆变换如下：

$$\mathscr{F}^{-1}f=\frac{(\mathscr{F}f)(-x)}{2\pi}$$

我们能证明，对于$f,g\in\mathscr{S}'$，其中一个具有紧支集($\mathscr{E}'$)，那么满足下式
$$\mathscr{F}(f*g)=\mathscr{F}f\cdot\mathscr{F}g$$

已知$ (f*g)(-x) = f(-x)*g(-x) $与卷积的**线性性质**得
$$\begin{aligned}f*g&=\mathscr{F}^{-1}(\mathscr{F}f\cdot\mathscr{F}g)\\&\Downarrow\\\mathscr{F}^{-1}f*\mathscr{F}^{-1}g&=\mathscr{F}^{-1}(f\cdot g)\\&\Downarrow\\\frac{(\mathscr{F}f*\mathscr{F}g)(-x)}{4\pi^2}&=\frac{\mathscr{F}(f\cdot g)(-x)}{2\pi}\\&\Downarrow\\\frac{\mathscr{F}f*\mathscr{F}g}{2\pi}&=\mathscr{F}(f\cdot g)\\&\Downarrow\\\mathscr{F}(f\cdot g)&=\frac{\mathscr{F}f*\mathscr{F}g}{2\pi}\end{aligned}$$

要满足的条件是$f$，$g$中有一个为常义的光滑函数，假设是$g$，另一个$f\in\mathscr{S}'$，且$\mathscr{F}^{-1}g\in\mathscr{E}'$(或者说即$\mathscr{F}g\in\mathscr{E}'$)

### 计算$\delta$函数的傅里叶变换
$$\begin{aligned}
\langle\mathscr{F}\delta,\varphi\rangle&=\langle\delta,\mathscr{F}\varphi\rangle =\mathscr{F}\varphi(0)=\langle1,\varphi\rangle\end{aligned}$$
可得
$$\mathscr{F}\delta=1$$

---

### Laplace变换
定义下面从$\mathbb{\Gamma}$到$\mathscr{S}_{\eta}^{\prime}$的映射$\xi\to\left(E(\xi)\right)_\eta $，被称为$T\in\mathscr{S}_x^{\prime}(\Gamma)$的Laplace变换记作$\left(\mathscr{L}T(\xi)\right)_n$或简记为$\mathscr{L}T$，其中$\mathscr{S}_x^{\prime}(\Gamma)=\left\{T\in\mathscr{D}_x^{\prime}\right.:\left.\exp(-\xi x)T\in\mathscr{S}_x^{\prime},\forall\xi\in\Gamma\right\}.$
$$\begin{aligned}\left(\mathscr{L}T(\xi)\right)_{\eta}&=\mathscr{L}T=\left(E(\xi)\right)_{\eta}\\&=\left[{\mathscr F}_{(x)}\left(\exp(-\xi x)T_{x}\right)\right]_{\eta}\end{aligned}$$

这里的意义是先进行Fouier变换后再把它看作为$\eta$的广义函数，而我们所用的其实下面这个命题叙述得到的

若$\mathbb{\Gamma}$为凸开集，则$\mathscr{S}_{\eta}^{\prime}$的Laplace变换是一个从$\mathbb{\Gamma}$到$(\mathscr{O}_M)_\eta $的无穷可微映射，并且还有

$$
\left(E(\xi)\right)_\eta=E(\xi,\eta)=F(\xi+i\eta)=F(p)
$$

其中$F$为关于$p\in\Gamma+i\Xi^n$的全纯函数,也称为$T$的Laplace变换
反过来,定义在$\Gamma+i\Xi^n$上使得对于$\mathbb{\Gamma}$的任意紧子集$K$,在$K+i\Xi^n$上可被$\eta$的多项式界住的任意全纯函数$F$，均为唯一的广义函数$T\in\mathscr{S}_x^{\prime}(\Gamma)$的 Laplace变换

解读一下，只有支集在$[0,\infty)$上的广义函数，其具有普遍的拉普拉斯变换，定义为

$$\mathscr{L}f=\langle f,e^{-st}\rangle$$

在工程中，有这么一个结论

$$\mathscr{L}\frac{\mathrm{d}f}{dx}=pF(p)-f(0^-)$$

如果说拉普拉斯变换要求支集在$[0,\infty)$，那么这个式子不应该存在后面减去的常数项，对于求解微分方程来说，处理因果信号，假设响应也是单边的，对响应的微分也是单边的，那么确实可以对两边进行拉普拉斯变换，而且解出的解应当是特解，而零输入响应就是线性齐次微分方程的解，它是"自然存在的响应，不会被消除"，它不是某个信号造成的响应，因此对函数左半边极限的描述可以适用于此，早就了上述式子这样的一个语法糖