---
title: 广义Stokes公式的应用
mathjax: true
categories:
- Mathematic
- Analysis
---

# 广义Stokes公式的应用
今天物理课上提到了转动惯量的计算，我还在纠结体积元素之时，发现老师直接给了结论，给的计算例题还是那种只需要一个坐标就可以表示的，还说如果质量不均匀分布就算不了了
我当然知道老师是什么意思，也**不是想抬杠**(迫真)，但听到这个我顿时来了兴致，于是经过了一天的计算，我给出了一些东西
<!--more-->

## 复习Stokes公式
对于 $n$ 维微分流形 $M$ ，$\Omega\subset M$ ，$\partial\Omega$ 是一个 $n-1$ 维微分流形，为 $M$ 的**边界**，$\omega$ 为 $(n-1)$ -形式，$d\omega$ 为 $n$ -形式，可得
$$\int_{\partial \Omega}\omega=\int_{\Omega}d\omega$$
利用stokes公式可以将微分形式降阶升阶来进行计算，例如把重积分降为曲线积分并换元，或者说升阶使得协变基变为1个，方便进行累次积分

---

## 导出公式
$$
\psi = f_rdr + f_\theta \theta +f_hdh \\
d\psi = (\frac{\partial f_r}{\partial \theta} - \frac{\partial f_\theta}{\partial r} )dr \wedge d\theta + (\frac{\partial f_h}{\partial \theta} - \frac{\partial f_\theta}{\partial h} )d\theta \wedge dh + (\frac{\partial f_r}{\partial h} - \frac{\partial f_h}{\partial r} )dh \wedge dr \\
\varphi  = f_1dr \wedge d\theta + f_2d\theta \wedge dh + f_3dh \wedge dr \\
d\varphi = (\frac{\partial f_1}{\partial h} +\frac{\partial f_2}{\partial r} +\frac{\partial f_3}{\partial \theta})dr \wedge d\theta \wedge dh
$$
从上面的式子可以看见，其实从高阶的微分形式向下变低阶的过程是一个**解PDE的过程**，而这里所解得的函数其实也不是唯一确定的，有无穷多个。

---
## 特殊情况
利用stokes公式将上式降维求积分的过程中，高阶微分形式中那个系数往往是多个函数的偏导数的和差，这里我们可以只让一个函数不为0，其它函数全为0构造一种特殊的情况

比如我们要求
$$
\iiint_D g(r,\theta,h)dr \wedge d\theta \wedge dh
$$
利用公式
$$
d\varphi = (\frac{\partial f_1}{\partial h} +\frac{\partial f_2}{\partial r} +\frac{\partial f_3}{\partial \theta})dr \wedge d\theta \wedge dh
$$
$f_2$，$f_3$都是0，$f_1=g(r,\theta,h)$，那么就得到这个式子：
$$
\iiint_D g(r,\theta,h)dr \wedge d\theta \wedge dh=\iint_{\partial D}d\theta \wedge dh \int g(r,\theta,h)dr
$$
可以看到，这和n重积分拆成n次积分的式子很想，或者说几乎是一模一样的，不过这里的积分从定积分变成了不定积分，把求值的过程延后了，而我们将它提前的话，就自然得到了n重积分转为n次积分的式子
这种转化的过程其实是**遍历**$\partial D$时候进行的，我们可以想见，在进行遍历的时候，根据流形的方向，积分的值会多出正负号，凭借这些正负号，可以使得总体累加的式子里有部分可以消除，形成定积分，进而被改写为n次积分，这就是stokes公式和n重积分转n次积分之间的关系

---

## $\partial \Omega$的方向

当$p \in \partial M$时，我们可以选择一个局部坐标系$(x_1,\ldots,x_{n-1})$和坐标域$U$，使得$\partial M$在这个坐标系下可以表示为：

$$x_1=0,x_2=0,\ldots,x_{n-1}=0$$

然后，我们定义向量场

$$v(p)=\dfrac{\partial}{\partial x_1}\bigg|_p$$

在$p$处的值是$T_p \partial M$的正向基。重复对$\partial M$上每个点进行这样的选择，即可得到$\partial M$上的一个自然定向。

需要注意的是，$\partial M$的自然定向取决于$M$的定向以及在构造局部坐标系时的选择。在某些情况下，不同的选择可能会得到不同的自然定向。但是，如果我们要使用定向的$\partial M$来计算积分或者应用斯托克斯公式，我们需要选择一种确定的自然定向，并且在整个计算过程中都要保持这种定向的一致性。如果**所有自然定向和M的定向相同**，那么就是有向流形M边界自然诱导定向了

而定向相同就是**两个坐标系的转换方程的雅可比行列式大于0**

对于$R^n$，可以把自然诱导定向拓展为内法向量

在欧式空间中直观的观察可以归结如下图
<img src="/images/广义Stokes公式的应用_图1.jpg" width="100%" height="100%">
$\omega$的顶端那个面肯定是算作正的嘛，确实按照这样的算法也是正的了。
对于二重积分，利用green公式转化为的曲线积分也是逆时针的，和这张图中的$\partial\partial\omega$计算一致，证明我们的思路正确
xyz要根据顺序从高到低消去，这是由原本的**笛卡尔坐标系赋予**的

至于第二类积分和第一类积分的差别，我发现，第一类积分往往都是正的，有物理意义的特例，在计算上往往会化归为第一类，而且由于它是物理意义的，所以默认$dxdy$，$\omega$它都是方向与坐标系一致

之后也就沿袭这种默认了，可以用计算验证，重积分也默认区域和坐标系同向
 
如果说不是欧式空间，那必然会**知道**流形**预设**的方向，而利用之前的微分公式，列出微分方程，可以做到积分的需求，stokes向上的过程不管积分的是标量场还是向量场都是需要解PDE的(可以替代积分哦)

至此在任意坐标系下积分都成为流形上的运算了，已经都能算了