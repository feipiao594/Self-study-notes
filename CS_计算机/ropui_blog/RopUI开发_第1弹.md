---
title: RopUI开发_第1弹
mathjax: false
categories:
  - CS_计算机
  - ropui_blog
abbrlink: 4de565e4
date: 2025-12-30 01:24:39
---

# RopUI开发_第1弹
RopUI，是我目前正在制作的一个项目，我的目的是开发一个跨平台的一个 UI 框架。制作这个东西的目的其实相当的明确，我就是为了写博客，做视频，以及作为一个我的求职所用的一个项目。如今我的设计进入的一个开头的阶段，便有了这样的一篇博客。虽然我有一个短期的目标，但这个项目本身作为一个超长线的项目，我想关于开发时候的博客也会有不少吧。

<!--more-->

## 前言
在刚刚进入大学之时，其实就有未来走客户端开发的一个倾向，当时加入我校社团，参加 C++ 组的相关的活动，也是凭借自己很久之前就有 Qt 的一些相关经验，自然后来也就走上了客户端开发的一条道路

写 Qt 的过程当中，一开始编写项目的时候，由于缺乏计算机网络的相关知识，我第一个遇到的问题就是网络相关的问题，当时是做一个最最简单的象棋的客户端，我们用到了 Qt 的 `QNetworkAccessManager`，这东西用起来还是很方便的。只要绑定一下信号槽，post 完接受到服务器返回的信息，回调自然而然的就会被启动。在这个过程当中并不会阻碍 UI 的运行，一切都好像完全没有关系，就像魔法一样。

在这个时候，我还对此并不好奇，也并不明白为什么在编程语言的世界会有"事件"这个概念，好像计算机诞生的时候就有了这样的行为，默认它是存在的，我只是非常高兴的写下 Qt 的信号槽，或者是像 Android 那样调用了系统的库，拼一下拼图，很好啊，这个世界上的应用都是这么写出来的吧，我心里想着

稍过一段时间，我了解到了多线程多进程，我慢慢开始察觉，这件事情没有那么简单，计算机如此简单的一个模型，在操作系统的调度下，程序只能一路走到黑，汇编/二进制代码才不会管你什么 OOP，在他们的世界里没有什么对象不对象的，对于单线程来说，只有指令流，一个时间就是只能有一条指令被送到 CPU 里被执行(我们不考虑流水线，分支预测，乱序执行等乱七八糟的硬件行为，单纯只是说顺序执行)，这些执行的指令排列组合，赋予了这个二进制的世界色彩和美丽。但他们唯独不能在单线程的情况下突破界限：我不可能即在管我显示器上显示的图样，又管网络有没有收到，我必须分步骤去做

看过我此前[深入异步通用概念](https://blog.feipiao.xyz/posts/9b424f3e.html)这片博客的朋友应该知道，我现在已经明了这样的事情究竟是怎么发生的。因此我有一个执念，我想要在 UI 线程里也同样能够调度网络请求。

是的，我希望我这个 UI 框架不依赖 glfw 这样的库，同时由于绝大部分比较裸的事件库其实是网络库，并不太支持自己添加事件源。我决定亲自完成关于窗口，关于图像绘制，关于底层事件调度器的工作

这将是一个完完全全直接接入底层的 UI 框架。

其实我看网上关于这方面的描述并不是很多，客户端，或者说泛前端，在今年早就已经开始退化。可我并不希望这些知识逐渐遗失，我希望我的努力能为社区做出一点点贡献。为大家了解所谓我们这帮 UI 仔，所做的一切也没有那么的简单

## 前期调研
当确定了目标之后，我就开始了前期调研，距离我毕业还有大概半年多一点的时间，我其实并没有很充分的机会去完成这样的一个事情，但我会尽力。
我当下仍然在使用 Gentoo Linux 作为我的主力机，其上和图形有关的一些环境是 Wayland 以及渲染库使用的是 Mesa3D。Linux 在这一个方面有一个非常大的优势，在 2025 年的二月份，我曾了解过 drm 的工作原理，并且成功让一个程序在 tty 下切换图形状态为 graphic，显示一张直接所谓 CPU 绘制的图像，其实核心原理就是调用 libdrm 库上的一些函数，初始化，创建 framebuffer，然后 mmap 映射到内存空间，这种方式创建的 framebuffer 就是一个内存里的二维数组，在上面写入 rgba 信息提交即可

<img src="/images/RopUI开发_第1弹_图1.png" width="100%" height="100%">

> 这是天依蓝 #66ccff UwU

我还让它成功作为我树莓派的启动程序顶掉了桌面环境(笑)

在此以后，我还在暑假实习的空余时间学习了计算机图形学的相关知识。了解了一些关于渲染的原理
总之，各种原因叠加下来，我决定先为 Linux wayland 做我的一个支持，现在看来这个选择也挺正确的。

那么我们第一步就是要实现一个可靠的 Async Runtime

## EventLoopCore/EventLoopBackend/EventSource
作为异步实现的核心，任何一个 UI 框架都必须有所谓的 IO syscall，他们有的是 IO 多路复用，有的是真正的异步 IO,这并不重要，但是他们必然在每一个线程都会存在，而这些处理 IO 的线程就必然会进入到一个状态：他们只能做 IO 密集型任务，不能承担计算密集型任务，换而言之，这种状态让他们和同步执行的逻辑再也不会关联起来了

一开始我是打算直接设计 EventLoop 的，但后来改名叫 `EventLoopCore` 了，原因很简单，事实上按照现在的设计，每一个 IO syscall/系统 API 都将对应一个 `EventLoopCore`，这些 `EventLoopCore` 继承自 `IEventLoopCore`

```cpp
class IEventLoopCore {
public:
    virtual ~IEventLoopCore() = default;

    void applyInitialChanges() {
        applyPendingChanges();
    }
    void runOnce(int timeout = -1);
    
    void addSource(IEventSource* source);
    void removeSource(IEventSource* source);
    
protected:
    explicit IEventLoopCore(std::unique_ptr<IEventCoreBackend> backend);
    virtual void dispatchRawEvents();
    
private:
    void applyPendingChanges();

private:
    std::unique_ptr<IEventCoreBackend> backend_;

    std::vector<IEventSource*> sources_;
    std::vector<IEventSource*> pending_add_;
    std::vector<IEventSource*> pending_remove_;

    bool in_dispatch_ = false;
};
```

这个实现并不复杂，主要是对 IO syscall/系统 API 的一个封装，你可以简单调用 `runOnce` 运行等待

但其实 `EventLoopCore` 也只是一个代理者，核心的处理逻辑在相对应的 Backend，`EventLoopCore` 提供了统一上传事件的接口 `addSource` 与 `removeSource`，递交一个 `IEventSource`，会加入缓冲区，等待一个合适的时机真正加入 backend 的 Source 里

这里的 `EventLoopBackend` 和 `EventSource` 是真正处理事件的

```cpp
class IEventCoreBackend {
    BackendType type_;
public:
    IEventCoreBackend(BackendType type) : type_(type) {}
    virtual ~IEventCoreBackend() = default;

    virtual void addSource(IEventSource* source) = 0;
    // 添加事件源
    virtual void removeSource(IEventSource* source) = 0;
    // 移除事件源

    virtual void wait(int timeout) = 0;

    virtual RawEventSpan rawEvents() const = 0;

    BackendType getType() {
        return type_;
    }
};

class IEventSource {
protected:
    BackendType type_;
public:
    IEventSource(BackendType type) : type_(type) {};
    virtual ~IEventSource() = default;
    
    virtual void arm(IEventCoreBackend& backend) = 0;
    // 绑定到 backend

    virtual void disarm(IEventCoreBackend& backend) = 0;
    // 从 backend 解绑

    virtual bool matches(const void* raw_event) const = 0;
    // 判断某个原始回调是否属于自己

    virtual void dispatch(const void* raw_event) = 0;
    // 调用回调

    bool isSourceMatchBackend(IEventCoreBackend* backend) {
        return type_ == backend->getType();
    }
};
```

在 Linux 下 `EventSource` 需要你传入一个 fd 作为其监听的文件描述符，把 `EventSource` 传入 `EventLoopCore` 的 `addSource` 方法中，会透穿给 `Backend`，Backend 会在分发收到的任务时，主动调用注册进来的 `EventSource` 的 `Dispatch` 方法以此实现一个原始事件分发的一个功能

设计完了这些原始的事件源和事件循环核心，就要来实现一个真的 EventLoop 了

## EventLoop
我前面说 `EventLoopCore` 只是 IO syscall 的代理层，它的职责是“收事件”，而不是“安排工作”。  
真正面向 UI 线程的事件循环，必须还要干三件事：  
1) 能从别的线程安全地投递任务；  
2) 能有定时器，按时间触发任务；  
3) 能随时唤醒正在阻塞的 IO syscall。  
于是我在 `EventLoopCore` 外面包了一层 `EventLoop`，它就是 UI 线程真正跑的那一层。

如果只看接口，它其实非常朴素：

```cpp
class EventLoop {
public:
    EventLoop(BackendType backend_type);
    ~EventLoop();

    void post(Task task);
    void postDelayed(Task task, Duration delay);
    void requestExit();

    void attachSource(IEventSource* source);
    void detachSource(IEventSource* source);

    void run();
};
```

### 先说构造：选 backend + 安排唤醒源
构造函数里干了两件事：

- 调用 `createEventLoopCore(backend_type)` 创建核心 `EventLoopCore`。
- 根据 backend 创建一个 `WakeUpWatcher`，把它作为一个事件源注册进去。

为什么需要唤醒源？因为 `post()` 和 `postDelayed()` 是线程安全的，我允许别的线程投任务。  但是 UI 线程很可能正卡在 `epoll_wait/poll` 里，如果没人唤醒它，它永远看不到新的任务。  所以“唤醒源”其实就是一个可被触发的 fd（Linux 下可以用 eventfd 或 pipe），它一旦写入，就会让 IO syscall 立刻返回。

这就是 `post()` 的核心逻辑：

```cpp
void EventLoop::post(Task task) {
    if (!task) return;
    {
        std::lock_guard<std::mutex> lock(mu_);
        tasks_.push_back(std::move(task));
    }
    wakeup_->notify();
}
```

它不直接跑任务，只是把任务丢进队列，然后用唤醒源把阻塞的 IO 拉起来。事实上按照设计，`EventSource` 的回调函数就可以选择将事件 post 入队列中，等待处理。实际使用的时候可以灵活选择

### 任务队列 + 定时器
`EventLoop` 里有两个“任务容器”：

- `tasks_`：一个简单的 `deque`，存放即时任务。
- `timers_`：一个小顶堆（优先队列），按照 deadline 排序的延迟任务。

延迟任务的投递是这样的：

```cpp
void EventLoop::postDelayed(Task task, Duration delay) {
    if (!task) return;
    {
        std::lock_guard<std::mutex> lock(mu_);
        timers_.push(TimerTask{Clock::now() + delay, std::move(task)});
    }
    wakeup_->notify();
}
```

依然是先入队，再唤醒，保证 UI 线程不会错过。

### 计算 timeout：决定 IO 等多久
这一步是整个 loop 的“节拍器”。  
`computeTimeoutMs()` 负责告诉 `EventLoopCore::runOnce()`：你最多等多久。

规则也很直觉：

- 有即时任务：`timeout = 0`，不要阻塞，直接跑。
- 没有定时器：`timeout = -1`，可以无限等 IO。
- 有定时器：计算最近 deadline 到现在的差值，作为等待上限。

而且我还加了一个“上限保护”，避免超时值溢出 `int`。

### 主循环：IO + 定时器 + 任务队列
真正的 `run()` 就是一个非常直白的 while：

1. 先 `applyInitialChanges()`，把初始事件源都注册好（包括唤醒源）。
2. 计算 timeout，调用 `core_->runOnce(timeout)` 处理 IO。
3. 执行到期的定时器任务。
4. 执行即时任务队列。
5. 循环直到 `requestExit()` 被调用。

`runExpiredTimers()` 的实现我也刻意做成“先收集后执行”的模式：  
先在锁内把到期任务全部搬出来，再在锁外执行。这样避免回调里再 `post()` 造成死锁，也减少锁的持有时间。

### 退出机制
`requestExit()` 只是把一个 `atomic<bool>` 置为 true，然后唤醒一次 loop。  
这是为了保证即使 UI 线程正在阻塞，也能被拉起来看见“退出请求”。

到这里为止，`EventLoop` 已经完成了一个 UI 线程所需的“基本调度器”：  
它能收 IO，能收任务，能有定时器，能安全唤醒和退出。  
后面我只需要把“窗口事件”、“渲染时机”、“输入设备”都包装成 `IEventSource`，就可以自然接入这套体系。

于是乘热打铁我还写了几个 example

<img src="/images/RopUI开发_第1弹_图2.png" width="100%" height="100%">
可以创建一个 TCP client

<img src="/images/RopUI开发_第1弹_图3.png" width="100%" height="100%">
看看回调地狱

## EventLoop 的后续
事实上这套做法在 linux 上实现的很顺利，在 Windows 和 MacOS 上却出现了问题。Linux 内核本身是不具有图形环境的，所以接口相对统一，但是对于其他两个平台，他们的 UI 线程往往非常具有平台特色，而且独立

Windows 平台的 WinMain 函数支持 UI，但是与此同时又只支持同时监听 64 个句柄，要想使用 IOCP 必须单独开一个线程，这体验并不好，所以 EventLoop 有可能在后续的版本被废弃，转而使用更复杂的多线程调度器，请等待我的后续信息叭