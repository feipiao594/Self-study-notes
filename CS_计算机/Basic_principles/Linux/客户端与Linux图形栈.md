---
title: 客户端与Linux图形栈
mathjax: false
categories:
  - CS_计算机
  - Basic_principles
  - Linux
abbrlink: 387e933d
date: 2026-02-20 01:52:48
---

# 客户端与Linux图形栈
计算机在我们这代人出生并接触起，就具有一个不可或缺的组成部分，即显示屏。很多并非计算机专业的用户甚至会认为显示屏就是电脑，即使他们使用的其实并非是一个老旧的一体机。但从这个例子当中我们认识到，显示，已经成为了非常重要的组成部分。但我们，真的明白了显示的原理么，对于开发者来说，UI 框架能够直接操作组件，或者再底层一些，有什么 OpenGL 和 Vulkan，但这仍然是隔靴瘙痒。中间忽略了非常多的过程，成为我们的禁区。这篇文章，我将试图表达这其中大致的关系，希望能帮到读者

<!--more-->

> **WARNING!!!**: 叠甲，接下来的知识并不一定准确，由于有些知识的获取实在是过于困难了，因此只是简单的描摹一下我所理解的大概，仅供参考。在使用本文的知识时，请一定要有一定判断能力，尊重真实的事实。

---

## 图形接口 OpenGL
作为一个广为人知的图形 API，OpenGL 在众多地方都拥有教程，但几乎较新的教程都采用的是 GLFW。GLFW 封装了平台行为，打开 GLFW 关于 linux + wayland 的源代码，你就可以清晰地看见其使用 poll syscall 监听了 4 个 fd，其中有一个是 wayland 的文件描述符。GLFW 他另一个功能就是创建 OpenGL 的上下文，提供最基础的窗口包行为，但是，对于一个 UI 框架开发者来说，其事件注册与回调机制显得过于简单，功能也相对直接手搓来说太简单了，所以一般不会使用它作为窗口层，但作为最小化窗口与输入管理库，它显然是一个非常优秀的参考实现。也正是因为如此，大伙学习 OpenGL 的时候也经常使用它。关于事件循环的部分我就不提了，此前几篇讲异步的博客讲了许多了，但是关于上下文创建的有关知识，被 GLFW 藏起来的那些东西，是时候来看看了。

> 对于 vulkan 大致的套路类似，我不多赘述

首先，OpenGL 这里有好多的名词，如刚刚说到的 GLFW，还有一些名称经常听说

### 表一、基于 OpenGL 系列 API 的外部库
> 首先是一些基于 OpenGL 系列 API 的外部库
> 
|名称|描述|
|:-:|:-:|
|GLFW|最小化窗口与输入管理库|
|GLUT/freeglut|早期的窗口处理库，已不再维护，GLFW 的前任|
|GLAD|跨平台扩展加载库|
|GLEW|跨平台扩展加载库，和 GLAD 同生态位|

### 表二、真正的 OpenGL 规范
> 其次是一些真正的规范，表中**没有包含所有**制定者 khronos 制定的规范，但我们这次要讨论的东西都在里面了
> 
|名称|描述|
|:-:|:-:|
|WGL|Windows 专供。它是 OpenGL 与 Windows GDI 之间的桥梁。|
|GLX|Linux (X11) 专供。它是 X Window 系统的扩展。|
|EGL|全平台“万能胶”。它是 Khronos 定义的现代接口，不依赖特定操作系统。旨在替代上述两个|
|OpenGL|桌面级标准。功能最全、历史最悠久的 API。支持从简单的 2D 到复杂的 3D 渲染，拥有极其丰富的特性集，主要运行在 PC 和工作站（Windows, Linux）上。|
|GLES|移动级/嵌入式标准 (OpenGL for Embedded Systems)。它是 OpenGL 的精简版。去掉了大量过时且沉重的旧特性，专为手机（Android/iOS）、游戏机和车载系统优化，追求高性能和低功耗。|

**重要**: 对于**显卡厂商**而言，要实现的只有**表二**，OpenGL 规范制定之下，显卡厂商需要实现一个**动态链接库**，应用程序通过链接这个动态链接库来使用其中的函数，而这个动态链接库里提供的符号的规范，正是 OpenGL 系列，而这个动态链接库，就是显卡厂商为显卡实现的**用户态驱动**

而链接完毕之后，由于这些用户态在实现上的一些特殊性，OpenGL 的函数地址在编译期是不确定的，你必须需要 GLAD，GLEW 这样的库来从在运行时动态获取，否则就要通过一些

而 GLFW 这类库，只不过是在 GLEW 完活后，调用了一些 OpenGL 的接口完成了初始化，并且实现了事件循环而已

---

## 用户态驱动视角下的 OpenGL
考虑 OpenGL ES，它提供了一组工具，其中主要包含着色器的提交与编译，资源对象传输与管理的接口，渲染调用接口等等。其中着色器，对于 OpenGL 全系列，都是要使用 `glCreateShader`，`glCompileShader` 这样的 API 提交一个字符串(glsl)并编译才能使用的。实际上是传入了用户态驱动中进行编译。因此实际上厂商携带的用户态驱动里面一定会有一个 glsl 的相对于 CPU 的异构编译器，还有很多别的乱七八糟的管理工具。

### libglvnd
很多时候，你的电脑上并不只有一个用户态驱动，比如我的电脑就是核显(r7-6800h)和独显(3060 laptop)混合输出。在这样的 Linux 的多显卡或多驱动环境下，如果多个厂商都提供了名为 libGL.so 的动态链接库，系统就会陷入冲突。为了解决这个问题，NVIDIA 牵头并与社区共同开发了 **libglvnd**

作为**通用显卡驱动分发层**。libglvnd 不实现具体的 OpenGL 逻辑，而是根据当前的上下文决定将 API 调用转发给哪一个具体的厂商驱动。

libglvnd 的引入彻底改变了 Linux 图形库的链接方式：

1. 统一入口：应用程序不再直接链接到 Mesa 或 NVIDIA 的私有库，而是链接到 libglvnd 提供的公共入口（如 `libGL.so.1` 或 `libOpenGL.so.0`）。
2. 动态分发：当你调用 `glDrawArrays` 时，libglvnd 会在内部查询当前的渲染上下文（Context），并将其重定向到实际的后端实现。

### Mesa3D
如果每个厂商都要实现这么多东西，显然工作量太大了，Linux 后期社区孵化了一个叫做 mesa3d 的项目，mesa3d 提供了一套通用的状态跟踪器(State Trackers)和驱动框架(Gallium3D)，极大地简化了硬件厂商的适配工作。

Mesa3D 对应用程序来说提供了 OpenGL 接口的动态链接库。Mesa3D 实现了一个中间层，很多厂商在这个中间层之下接入了自家的后端，Mesa3D 因此能够将应用程序调用 Mesa3D 的动态链接库里的函数时转发给实际的后端。

在 Mesa3D 的架构下，**厂商不再需要从零开始编写整个图形** API 的逻辑。具体来说，Mesa3D 提供了以下三个核心层面的支持：

1、统一的硬件抽象层：**Gallium3D**

Mesa 引入了 Gallium3D 架构，它将图形驱动拆分为两个部分：

- 前端（Frontend）：负责处理复杂的 OpenGL、OpenCL 或 VDPAU 状态机。这部分代码是全硬件通用的。

- 后端（Backend）：厂商只需要编写一个极简的“硬插件”，负责将 Gallium 的中间表示（TGSI 或 NIR）翻译成自家显卡的机器码。

结果： 厂商只需要完成自家的硬件相关代码，剩下的通用逻辑全部由 Mesa 社区维护。

2、强大的着色器编译器：**NIR**

现代图形渲染的核心是着色器编译。Mesa 提供了一个高性能的中间表示层 NIR。
它包含了大量的优化算法。无论是 Intel、AMD 还是高通的 Adreno，都可以直接利用这些现成的优化逻辑，而不需要各自去研究复杂的编译器架构。

3、跨平台的系统集成接口

Mesa 统一处理了图形缓冲区的分配与共享。通过：

- EGL/GLX：解决了窗口系统（Wayland/X11）与图形 API 之间的衔接。

- gbm (Generic Buffer Management)：提供了统一的内存管理接口。

- dma_buf：实现了 GPU 与 CPU、甚至不同硬件单元（如视频解码器与显示控制器）之间的零拷贝数据交换。

总的来说，Mesa3D 提供了一套方便厂商编写用户态驱动的开发套件，只要接入 Mesa3D，适配 Gallium 接口并提供基础的内核 DRM 驱动，就能立刻获得成熟、稳定且高性能的 OpenGL 和 Vulkan 支持。

> 是的，nvidia 就是没有接入 Mesa3D，自己实现了用户态驱动。值得一提的是 nvidia 的社区版，逆向出来的驱动 nouveau 也是接入的 Mesa3D，nouveau 这个项目的内容就是 Mesa3D 的一个文件夹以及其内核态驱动

顺带一提，对于某些需要特殊符号的任务，Mesa3D 也能如 nvidia 一样有一套超越 OpenGL 的私人接口，这些接口的实现和不再有像 libglvnd 那样通用的、跨平台的 Loader 了。

<img src="/images/客户端与Linux图形栈_图1.png" width="100%" height="100%">

<img src="/images/客户端与Linux图形栈_图2.png" width="100%" height="100%">

mesa3d 架构图，对外暴露动态链接库

---

## EGL
在 Linux 现代图形栈中，EGL 是连接图形 API（OpenGL/GLES）与底层窗口系统（Wayland/X11）的唯一纽带。

首先我们介绍一下 Wayland：在 Linux 图形栈中，Wayland 它是一套目前最现代的现代图形显示协议。它定义了客户端如何与合成器(Compositor/Server，如 Hyprland)进行对话。应用程序，在wayland 语境下就是客户端，他们通过递交一个被称为 framebuffer 的渲染结果(可以理解为用户这边的绘制的画布)，交给合成器，合成器将统合所有客户端的结果，绘制桌面等其余的东西，合成一个完整的图像交给显示器显示

EGL 是怎么做到和平台通信的呢？对于 wayland，EGL 会通过链接 libwayland-client.so，利用其底层协议与 Wayland Server 通信。对于 Wayland 而言：

- 获取 Surface：Wayland Client 需要向 Server 申请一个 wl_surface。

- fd 传递：EGL 会通过 dma_buf 机制，把包含渲染结果的内存文件描述符（fd）发给 Server。

- 零拷贝：Server 拿到 fd 后，直接将其作为纹理合成到屏幕上，整个过程数据无需在 CPU 和 GPU 之间来回搬运。

其实如果你只是调用纯 CPU 的方式，你也可以使用一些方法递交一个数组来当作渲染的结果递交给合成器，但是 EGL 规范化了这一个过程。不管是什么，应用程序客户端想要显示页面，必须提交 framebuffer，由于 EGL 实际上是厂商实现的用户态驱动，它内部可以创建具有特殊格式的 framebuffer，要想使用这个 framebuffer，当然只有与 EGL 对应的相同厂商的 OpenGL 库能够实现了。

这个特殊格式主要是 framebuffer 的解释方式，这些格式只有厂商最了解，为了封闭性，也为了支持各种平台，厂商不会将发送到 wayland 合成器这一动作在 EGL 的外部实现，而是自己使用 libwayland 下的工具发送，很合理。不过 EGL 显然不能包含所有 libwayland 的动作，他只是调用一部分 wayland 的 api 实现发送 framebuffer 或者其他他所需要的动作罢了

## 图形 API 之下之 DRM
在图形 API 之下，用户态驱动和内核与内核态驱动之间，在如今主要是一个称为 DRM 的系统在工作。直接渲染管理器(DRM)是 Linux 内核的一个子系统，负责与现代显卡的 GPU 进行交互。DRM 提供了一个 API，用户空间程序可以使用该 API 向 GPU 发送命令和数据，并执行诸如配置显示模式之类的操作。

> 在 DRM 以前，这个位置是一个内核提供的被称为 fbdev 的东西，但是他过于古早有过多的缺点，这里因为我们只是简单介绍一下 drm，就不提了

这里我们借用 wikipedia 关于 drm 条目上的一张图
<img src="/images/客户端与Linux图形栈_图3.png" width="100%" height="100%">


内核主要提供了 ioctl 这个 syscall 用以调用内核的 drm 功能，内核预设了一部分 ioctl，在你使用的时候，通过 ioctl 传递某些枚举值可以调用对应的功能。厂商的驱动可以注册新的 ioctl 表上的枚举值，以此实现他们各自自己的功能

但用户态的应用程序不会直接调用 ioctl 的，太裸了(笑)，所以会存在有一个叫 libdrm 的库。他基本就是对 drm 直接 syscall 这种操作进行一个最简单的封装。在 libdrm 的代码里也有一些其他厂商的功能，比如 amdgpu，所以也可以认为 libdrm 里有时也会包含一些比较靠近 drm 机制的显卡用户态驱动。但很多显卡 libdrm 里就没有了，比如树莓派的小显卡，它的驱动就只存在于 Mesa3D 中

限于篇幅问题，在这里我不对 drm 的详细内容进行解释，其中涉及复杂的交互过程，总之，通过它，我们就正式将 shader 也好，顶点数据也好，GPU 的其他控制指令也好作为数据下传给内核里的驱动了。详细的使用方式大家可以自己查询并学习

下面这个示例程序展示了如何调用 libdrm 进行 CPU 渲染，需要在 tty 环境下运行，他绘制一张我提到过相当多次的小脸

```c
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/ioctl.h>
#include <xf86drm.h>
#include <xf86drmMode.h>
#include <sys/mman.h>

drmModeConnectorPtr getFirstConnectedConnector(int fd, drmModeResPtr mode_resources)
{
	drmModeConnectorPtr connector = 0;
	for (int i = 0; i < mode_resources->count_connectors; i++)
	{
		char name[32];

		connector = drmModeGetConnectorCurrent(fd, mode_resources->connectors[i]);
		if (!connector)
			continue;

		if (connector->connection == DRM_MODE_CONNECTED)
			return connector;

		drmModeFreeConnector(connector);
	}
	return NULL;
}

drmModeModeInfoPtr getPreferredMode(drmModeConnectorPtr connector)
{
	/* Get the preferred resolution */
	drmModeModeInfoPtr resolution = 0;
	for (int i = 0; i < connector->count_modes; i++)
	{
		resolution = &connector->modes[i];
		if (resolution->type & DRM_MODE_TYPE_PREFERRED)
			return resolution;
	}
	return NULL;
}

void drawRect(uint32_t *data, size_t width, int x1, int y1, int x2, int y2, uint32_t color)
{
	for (int y = y1; y < y2; ++y)
	{
		for (int x = x1; x < x2; ++x)
		{
			int pix_pos = y + (width / sizeof(*data)) * x;
			data[pix_pos] = color;
		}
	}
}

int main()
{
	int fd = open("/dev/dri/card0", O_RDWR);
	drmModeResPtr mode_resources = drmModeGetResources(fd);
	/* Get the resources of the DRM device (connectors, encoders, etc.)*/
	if (!mode_resources)
	{
		fprintf(stderr, "Could not get drm resources\n");
		return -1;
	}
	printf("Num crtcs: %d\n", mode_resources->count_crtcs);
	printf("Num encoders: %d\n", mode_resources->count_encoders);
	printf("Num fbs: %d\n", mode_resources->count_fbs);
	printf("Num connecters: %d\n", mode_resources->count_connectors);
	/* Search the connector provided as argument */
	drmModeConnectorPtr connector = getFirstConnectedConnector(fd, mode_resources);
	if (connector == NULL)
	{
		fprintf(stderr, "Failed to find connected connector\n");
		return -1;
	}
	printf("Connector type %d:%d\n", connector->connector_type, connector->connector_type_id);
	drmModeModeInfoPtr preferred_mode = getPreferredMode(connector);
	if (preferred_mode == NULL)
	{
		fprintf(stderr, "Failed to find preferred mode\n");
		return -1;
	}

	printf("Horizontal params: %d %d %d %d\n", preferred_mode->hdisplay, preferred_mode->hsync_start, preferred_mode->hsync_end, preferred_mode->htotal);
	printf("Vertical params: %d %d %d %d\n", preferred_mode->vdisplay, preferred_mode->vsync_start, preferred_mode->vsync_end, preferred_mode->vtotal);

	struct drm_mode_create_dumb dumb_framebuffer;

	memset(&dumb_framebuffer, 0, sizeof(dumb_framebuffer));

	dumb_framebuffer.height = preferred_mode->vdisplay;
	dumb_framebuffer.width = preferred_mode->hdisplay;
	dumb_framebuffer.bpp = 32;

	if (ioctl(fd, DRM_IOCTL_MODE_CREATE_DUMB, &dumb_framebuffer))
	{
		fprintf(stderr, "Failed to create dumb framebuffer\n");
		return -1;
	}

	uint32_t db_id, pitch;
	uint64_t size;

	if (drmModeCreateDumbBuffer(fd, preferred_mode->hdisplay, preferred_mode->vdisplay, 32, 0, &db_id, &pitch, &size))
	{
		fprintf(stderr, "Failed to create framebuffer");
		return -1;
	}

	uint32_t fb_id;
	if (drmModeAddFB(fd, preferred_mode->hdisplay, preferred_mode->vdisplay, 24, 32,
					 pitch, db_id, &fb_id))
	{
		fprintf(stderr, "Failed to add framebuffer");
		return -1;
	}

	drmModeEncoderPtr encoder = drmModeGetEncoder(fd, connector->encoder_id);
	if (encoder == NULL)
	{
		fprintf(stderr, "Failed to get encoder\n");
		return -1;
	}

	drmModeCrtcPtr crtc = drmModeGetCrtc(fd, encoder->crtc_id);
	if (crtc == NULL)
	{
		fprintf(stderr, "Failed to get crtc\n");
		return -1;
	}

	uint64_t db_offs;
	if (drmModeMapDumbBuffer(fd, db_id, &db_offs))
	{
		fprintf(stderr, "Failed prepare scanout buffer mmap\n");
		return -1;
	}

	uint32_t *db_data = mmap(0, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, db_offs);

	drawRect(db_data, pitch, 0, 0, preferred_mode->vdisplay, preferred_mode->hdisplay, 0x0011cc10);

	// #11cc10

	uint16_t width = preferred_mode->hdisplay / 10;
	uint16_t left_center_x = preferred_mode->hdisplay / 3;
	uint16_t right_center_x = preferred_mode->hdisplay / 3 * 2;
	uint16_t eye_center_y = preferred_mode->vdisplay / 3;
	uint16_t mounth_center_y = eye_center_y * 2;

	drawRect(db_data, pitch,
			 eye_center_y - width / 2,
			 left_center_x - width / 2,
			 eye_center_y + width / 2,
			 left_center_x + width / 2,
			 0x0);

	drawRect(db_data, pitch,
			 eye_center_y - width / 2,
			 right_center_x - width / 2,
			 eye_center_y + width / 2,
			 right_center_x + width / 2,
			 0x0);

	drawRect(db_data, pitch,
			 mounth_center_y - width / 2,
			 left_center_x - width / 2,
			 mounth_center_y + width / 2,
			 right_center_x + width / 2,
			 0x0);

	// why x and y exchange themselves ?

	drmModeSetCrtc(fd, crtc->crtc_id, 0, 0, 0, NULL, 0, NULL);
	drmModeSetCrtc(fd, crtc->crtc_id, fb_id, 0, 0, &connector->connector_id, 1, preferred_mode);
	sleep(20);
	drmModeFreeEncoder(encoder);
	drmModeFreeCrtc(crtc);
	drmModeFreeConnector(connector);
	drmModeFreeResources(mode_resources);
	return 0;
}
```

显示如下

<img src="/images/客户端与Linux图形栈_图4.png" width="100%" height="100%">

## AMDGPU
> TODO: 关于这一部分，主要是通过对 `umr` 抓取到的一个包进行诠释，介绍一下 amdgpu ring buffer 以及其 CU CP 的结构，以及一些通用的 gpu 知识

我们已经进入了深水区，这一部分的学习方法只有一个，阅读源码，由于 n 卡的特殊性，我们选取 amdgpu 来学习，阅读 mesa3d，与 linux 内核里提供的源码，以及 amd 官方提供的手册与工具，能对 amdgpu 有一个大致的了解已经殊为不易

显卡，众所周知，具有极多的小"CPU 核心"，通过并发来实现对某些计算的加速。然后其内部有一些固定的硬件，比如硬件级的渲染管线，可以加速 3D 渲染的过程。只需要知道这点，我们就可以来对 AMDGPU 进行一个简单的了解了

(To be continue)

## 图形 API 之上
对于前文的讨论，我们知道，图形 API 之上，其实基本上最简单的构筑就是 GLFW，他提供的能力我们通常称之为**窗口层**，他基本就只包含了下面三个能力：

- 事件循环与分发的能力，可以新建并挂载事件，监听与回调
- 完成了 OpenGL 这类图形 API 的初始化，能够进行绘制，并把图像推到屏幕上
- 能够直接调用平台相关的控制接口

使用我此前异步的文章里提到的技术，以及本文中关于 OpenGL + EGL 的认识，你可以创建更加复杂的窗口库。

> TODO: 结合 RopUI 的 example 讨论

终于，你获得了一个 UI 框架的底座，窗口层！但是，在此基础上 UI 框架的构筑才刚刚开始...

> TODO: 简单介绍，控件树，diff 算法，布局算法，命中测试，事件消息传递，目前我研究也不深入，更具体 UI 框架的研究等待后续再来

> TODO: 介绍，为什么你自己搓的窗口层不可能和平台所谓原生框架很好的兼容，因为他们有自己的设计，和你同生态位，你只有在他们提供的最基础的，可以调用 opengl 这种或者封装过后的绘制接口进行绘图的时候，才能够获得一个相对独立的，满足上述 3 项基础能力的窗口层，直接兼容由于生态位的挤占是做不到的

## 总结：世界总是复杂的
这条线路可能是最现代的，但你的电脑上还有许多历史债务，世界总是复杂的，我们这边只是阐述了 linux 模糊的样貌，至于 windows 和 macos，甚至是其他的移动端设备，整体的样子又会有所不同，但总的来说，因为各种兼容性，大家又有相当的一致性

事实上我们没办法给这个系统画出一个完整的图，错综复杂的结构，或许只有显卡厂商他们自己有能力研究明白，在这里我仍旧贴一张来自 wikipedia 相对完整的图，请注意，即使是这张图，在结构上仍然没有展示完全

<img src="/images/客户端与Linux图形栈_图5.png" width="100%" height="100%">


在这个板块我将写一些我了解到的上述内容里没提到的，关于一个 linux user 使用 linux 作为主力机时遇到的其他细节，希望能让你对你的电脑的一切有一个大体上的了解

- 你的电脑上或许会安装 xf86-video-xxx 系列驱动，他们是 xorg 的老产物。x server 一部分渲染(2D等)依赖他们，x server 应当只用 mesa3d 进行 3d 渲染
- 在上面这张总体图上，可以看见 computaion 板块，在当下 GPGPU 的出现，使得 AI 相关的技术栈实质上和图形栈极度相似。可以预想到 pytorch 对应 qt，计算图文件 onnx 对应 opengl 里 shader，算子编程更像是用户态的驱动编程，至于下方的厂商驱动，其实对于厂商完全就是同一套东西了
- 在上面这张总体图上左侧有一个 libinput，那是一个事件处理的库，主要的用途是解释来自内核发送的输入设备事件，他可以很好的与我此前异步所讲的事件循环系统，和 ropui 里真实的调度器兼容
- 可以看到 mesa 里还有 vaapi 这种音视频方面的用户态驱动实现，vaapi 和 opengl 一样是个协议，也有类似 libglvnd 的存在(libva)和对应的硬件驱动后端。