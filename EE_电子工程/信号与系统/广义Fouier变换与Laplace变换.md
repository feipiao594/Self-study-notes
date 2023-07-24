---
title: 广义Fouier变换与Laplace变换
mathjax: true
categories:
  - EE_电子工程
  - 信号与系统
abbrlink: f38b0ecb
---


# 广义Fouier变换与Laplace变换
这一篇记录广义函数的Fouier变换与Laplace变换的定义

<!--more-->

---

## 广义函数的卷积运算
设$f$，$g$为$\mathcal{D}^{\prime}(\Omega)$，而且至少有一个具有紧致集，定义$f*g$为$\mathcal{D}^{\prime}(\Omega)$广义函数
$$
\langle f*g,\varphi\rangle=\langle f(x),\langle g(y),\varphi(x+y)\rangle\rangle
$$

卷积运算满足结合律，交换律，分配律
$$f*g*h=f*(g*h)\qquad f*g=g*f$$
且关于Dirac函数满足
$$f*\delta=\delta*f=f$$

---

## Fouier变换
若$\varphi\in\mathscr{S}(\mathbb{R}^N)$，即速降函数(schwartz function)，定义$T\in\mathscr{S}'(\mathbb{R}^N)$的傅里叶变换如下
$$\langle\mathscr{F}T,\varphi\rangle=\langle T,\mathscr{F}\varphi\rangle $$
同理
$$\langle\mathscr{F}^{-1}T,\varphi\rangle=\langle T,\mathscr{F}^{-1}\varphi\rangle\\\langle\mathscr{F}^{-1}\mathscr{F}T,\varphi\rangle=\langle\mathscr{F}\mathscr{F}^{-1}T,\varphi\rangle=\langle T,\varphi\rangle$$
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



看上去这是双边拉普拉斯变换等价的定义，在数学里似乎并不区分双边还是单边，单边拉普拉斯变换可以理解为$T_x$乘上一个Heaviside函数，我**个人觉得**这才是单边拉普拉斯变换的定义，理由是在工程中，有这么一个结论
$$\mathscr{L}\frac{\mathrm{d}f}{dx}=pF(p)-f'(0^-)$$
既然有$0^-$的部分，那显然在0前是有定义的，那必然得进行双边的傅里叶变换，只有乘上Heaviside函数(严格来讲不叫这个函数，因为需要补上零点的定义，设函数为$u(x)$，额外添加$u(0)=1$，显然这个函数的导数也是Dirac函数)，再进行拉普拉斯变换才是最符合含义的

在这样的定义下，上面这个工程结论也能够被解释

---

**proof**.由于定义式后面一小部分都是换元，其实只要证明
$$\begin{aligned}\langle\mathscr{F}\{f'ue^{-\xi x}\},\varphi\rangle&=\langle\mathscr{F}\{((fu)'-f\delta)e^{-\xi x}\},\varphi\rangle\\
&=\langle\mathscr{F}\{(fu)'e^{-\xi x}\},\varphi\rangle-\langle\mathscr{F}\{f(0)\delta \},\varphi\rangle\\
&=\langle\mathscr{F}\{(fu)'e^{-\xi x}\},\varphi\rangle-\langle f(0),\varphi\rangle
\end{aligned}$$

关于Fouier变换有微分性质如下
$$\mathscr{F}\left(\mathrm{T}^{\left(n\right)}\right)=\left(2\pi\mathrm{is}\right)^\mathrm{n}\mathscr{F}\text{T}\\\left(\mathscr{F}\text{T}\right)^{\left(\mathrm{n}\right)}=\mathscr{F}\left(\left(-2\pi\text{it}\right)^\text{n}{ \mathrm{T}}\right)$$

所以减号前的部分
$$\begin{aligned}\langle\mathscr{F}\{(fu)'e^{-\xi x}\},\varphi\rangle
&=\langle\mathscr{F}\{(fue^{-\xi x})'+\xi fue^{-\xi x}\},\varphi\rangle
\\&=\langle\mathscr{F}\{(fue^{-\xi x})'\},\varphi\rangle+\xi\langle\mathscr{F}\{fue^{-\xi x}\},\varphi\rangle
\\&=\langle 2\pi i x\mathscr{F}\{fue^{-\xi x}\},\varphi\rangle+\xi\langle\mathscr{F}\{fue^{-\xi x}\},\varphi\rangle
\\&=\langle i\eta\mathscr{F}\{fue^{-\xi x}\},\varphi\rangle+\xi\langle\mathscr{F}\{fue^{-\xi x}\},\varphi\rangle
\\&=\langle (i\eta+\xi)\mathscr{F}\{fue^{-\xi x}\},\varphi\rangle
\end{aligned}$$

总结可得
$$\begin{aligned}
\langle\mathscr{F}\{f'ue^{-\xi x}\},\varphi\rangle&=\langle(\xi+i\eta)\mathscr{F}\{fue^{-\xi x}\}-f(0),\varphi\rangle
\end{aligned}$$

故
$$
\mathscr{F}\{f'ue^{-\xi x}\}=(\xi+i\eta)\mathscr{F}\{fue^{-\xi x}\}-f(0)
$$

经过换元代换之后就能得到
$$
\left(\mathscr{L}f'u(\xi)\right)_{\eta}=pF(p)-f(0)
$$
**Q.E.D**