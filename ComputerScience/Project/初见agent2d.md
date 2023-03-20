---
title: 初见Agent2D
mathjax: false
categories:
- ComputerScience
- Project
---

# 初见Agent2D
见到这个项目本身就是异常意外，我对足球的兴趣并不大。这两天看代码也看的有一点晕，随手写下一些探索的过程吧

<!--more-->


## 项目内容
这次的项目其实全部都在`*/NJUPT2023Apollo2D/your-team/src/bhv_penalty_kick.cpp`当中，要修改的东西也很清楚，目的就是利用已经完成的rcsc内的各种API，在**整体框架结构**不变的前提下，优化点球大战中我方`taker`和`keeper`的行为逻辑，以提高其在面对`helios`球队时候的胜率。

---

## 整理一下逻辑
我们直接从`Bhv_PenaltyKick::execute`这个入口的函数开始分析起，它根据服务器反馈的当前点球大战的情况来`switch`选择是给`Agent`运行什么代码。
我们先来看看`taker`，在这里，主要的带球和踢球动作是由如下函数
```c++
bool Bhv_PenaltyKick::doKicker(PlayerAgent *agent)
{
    //
    // server does NOT allow multiple kicks
    //

    if (!ServerParam::i().penAllowMultKicks())
    {
        return doOneKickShoot(agent);
    }

    //
    // server allows multiple kicks
    //

    const WorldModel &wm = agent->world();

    // get ball
    if (!wm.self().isKickable())
    {
        ......
    }

    // kick decision
    if (doShoot(agent))
    {
        return true;
    }

    return doDribble(agent);
}
```
在这段代码中可以看到它首先会根据服务器是否允许多次踢球来决定是不是调用`doOneKickShoot`，然后是`if (doShoot(agent))`这里如果可以踢球并且踢球踢球成功就会返回true，这里的**判断和执行是一体**的
而如果返回false，则会调用`doDribble`
阅读`doShoot()`里面的内容，我们可以看到，它其中的内容首先是，时间不够就执行`doOneKickShoot`来实现紧急情况下的踢球，如果时间足够将会计算`if (getShootTarget(agent, &shot_point, &shot_speed))`，如果返回true则说明可以开踢，这边选择的策略是构造函数创建`Body_SmartKick`临时对象并且`execute`传入`agent`执行踢球操作，至于`Body_SmartKick`有多**smart**，我也不知道(笑)
那么承担判定的责任就从`doShoot()`转移到了`getShootTarget()`这个函数身上，观察这样一个函数的内容，会发现豁然开朗，因为在这个函数内部有很多if，写了一堆情况，比如球过远，对方没有守门员等等情况，并且开始**具体计算**了，只要开始回到数学问题，~~一般的问题也就变得简单多了~~(划掉)
同理，`doDribble`也和`doShoot()`一样的重计算，这很舒服，终于找到了主要核心判断的源头了

---

## 对于后面项目的工作
我们要完成一些记录
首先大部分的数据获取都来自于当前`agent`的`worldmodel`，而动作的执行往往都是调用`rcsc/action`下的行为类，构造完临时变量后直接`execute`执行兵传入`agent`指针
需要一种记录log的手段，在文件当中可以经常看见以下代码
```c++
dlog.addText(Logger::TEAM,
                 __FILE__ "this is a sample");
```
其中`__FILE__`是C语言的宏，其意义就是当前的文件
关于这个log到底输出到哪还需要查找

---

### TO BE CONTINUE