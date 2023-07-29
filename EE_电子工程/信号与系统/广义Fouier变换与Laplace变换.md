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

> 广义函数没有常义函数那种定义域，它只有作为泛函的定义域，就是整个函数空间，那么那种定义域不在整个n维欧式空间上的函数其实也是这个特殊函数空间的泛函啊
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



看上去这是双边拉普拉斯变换等价的定义，在数学里似乎并不区分双边还是单边，**单边拉普拉斯变换就是要求广义函数支集在**$(0,+\infty)$(当$a\to 0^-$下$(a,+\infty)$)，否则将没有意义

在工程中，有这么一个结论

$$\mathscr{L}\frac{\mathrm{d}f}{dx}=pF(p)-f(0^-)$$

我理解这里的$f(0^-)$为趋于0处的极限，其实就是$f(0)$，当然这个结论严格来讲肯定不对，毕竟不管怎么样，广义函数都不能直接取值，所以事实上用单边拉普拉斯变换来解微分方程似乎只是还是严格的Laplace变换解法的语法糖罢了，其中跳了一些步骤

## 求响应时对Laplace变换的解释
实质上，上面所叙述的真正的拉普拉斯变换是不会有$f(0^-)$这个东西的，这个东西是补偿出来弥补整个方程配平的
首先在工程上会解一个常微分方程，这里就是用到了拉普拉斯变换，如下
$$
\sum_{k=0}^{n}a_{k}y^{(k)}(t)=\sum_{k=0}^{m}b_{k}x^{(k)}(t),t>0
$$
其中$H(t)=1,t\ge0;H(t)=0,t<0$
首先，左边的函数$y(t)$，由于给出$y(0^-)$的初值条件，所以是一个**常义函数**，由于物理学的存在(乐)，$x(t)$也可以拆分成小于0和大于等于0的部分(广义函数应该没有这个性质，但是在这里由于要求$t\ge0$的**物理因素**，且只给出了大于等于0时的函数，就势必要与之前状态叠加，从而形成整个时间轴的输入，所以完全可以，而且只需要出现$t\ge0$的字眼，就只要将整体$x(t)-x_+(t)$就可以得到前面的信号，这也进一步说明了这里可拆解的隐藏含义)，体现在区域上，变成两个微分方程的叠加，我们现在考虑小于0的部分
$$
\sum_{k=0}^{n}a_{k}y^{(k)}(t)=\sum_{k=0}^{m}b_{k}x_{t<0}^{(k)}(t)
$$

> 事实上可拆解性以及系统叠加导致了输入信号只能是冲激函数或者冲激函数的时移或者常义函数，自然就能拆分咯

因为**物理学**的存在，$y(t)$**性质足够好**，使得零输入响应是存在的(别问，问就是公理)我对此尝试做一下解释:

对于这个函数，由于右半部分**整体计算结果**大于等于0的部分为0，所以最终结果应该在大于等于0的部分与零输入响应一致，也就是该微分方程与$\sum_{k=0}^{n-1}b_{k}x_{t<0}^{(k)}(t)$下解在大于0处相等。事实上，题设当中给出的条件和我们要求的函数并无多大关系，其实是不能称作为真正意义上的“初值条件”的，求到直接是需要的解的原因就是在于解方程时候直接有了物理这个要求的介入，其实来说，这也是求得的普通的特解罢了，实质上我们在求下面这些东西的基础:冲激响应的时候也利用了这个公理不是么，这才确定了唯一的响应啊

> 具体叙述是，物理每个时间t必须有定义，且一般这里的物理的要求是假设函数分段光滑

由此，小于0的部分和齐次微分方程同解，我们要证明一个结论，即上面说的同解的这个解，是齐次微分方程通解代入满足几个初值得到的特解，而这个特解应该**可以用几个冲激响应，或者说“求导后冲激函数”的响应来补偿**出来

从-**对书本中狄拉克函数的诠释**-这一份blog来讲(就与本篇同一目录下)，看最后一个微分方程的求解，可以看到通过直接求导的方法求得的冲激响应是除了$f^{(n-1)}(0)=\frac{1}{a_n}$，其它初值全部为0的线性齐次微分方程的特解，再乘上$H(t)$，而简单计算一下，如果想求冲激偶的响应，那么同理，要使用直接求导的方法，观察左边的大和式，可以得到一个惊人的结论，上面的初值变成了除了$f^{(n-2)}(0)=\frac{1}{a_n}$，其它初值全部为0。

还记得我们解常微分方程中有一个线性叠加原理么，我们只要把激励乘上系数，再叠加起来，就可以用乘以系数的冲激函数和其n阶导去求响应，其解就是齐次线性微分方程的通解挑一个满足$n-1$个初值的再乘上H(t)，而这个$n-1$初值，正好就完全由上面提到的系数决定，即假设右侧$\delta^{(k)}(x)$的系数为$c_k$则$f^{k}(0^-)=\frac{c_k}{a_k}$，那么我们就可以得到

$$
\sum_{k=0}^{n}a_{k}y^{(k)}(t)=\sum_{k=0}^{n-1}a_kf^{k}(0^-)\delta^{(k)}(t)
$$

这个微分方程的解在大于等于0的部分与$x(t)$小于0的部分产生的响应在大于等于0的部分完全相同

那么原微分方程小于0的部分即可完全被代替，得到
$$
\sum_{k=0}^{n}a_{k}y^{(k)}(t)=\sum_{k=0}^{n-1}a_kf^{k}(0^-)\delta^{(k)}(t)+\sum_{k=0}^{m}b_kx^{(k)}(t)
$$

这里$x(t)$是指原本方程中$x(t)$大于等于0的部分，只是没有写成$x'(t)$罢了

好了，现在明了了，现在上面的东西全部已经是大于等于0的部分了，我们终于可以进行Laplace变换了，运用广义函数的Laplace变换进行求解，反而是一件简单的事情了

所以说，$f(0^-)$完全就是一个补偿出来的东西嘛，说白了单边拉普拉斯变换确实语法糖了，要解整个方程要加入一堆物理性质的条件，不然根本解不了