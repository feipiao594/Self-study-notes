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
计算机在我们这代人出生并接触起，就具有一个不可或缺的组成部分，即显示屏。很多并非计算机专业的用户甚至会认为显示屏就是电脑，即使他们使用的其实并非是一个老旧的一体机。但从这个例子当中我们认识到，显示，已经成为了非常重要的组成部分。但我们，真的明白了显示的原理么，对于开发者来说，UI 框架能够直接操作组件，或者再底层一些，有什么 OpenGL 和 Vulkan，但这仍然是隔靴瘙痒。中间忽略了非常多的过程，成为我们的禁区。这篇文章，我将试图表达这其中大致的关系，希望能帮到读者建立起自上而下的，对单一设备上的应用开发的相对泛化的认识

<!--more-->

> **WARNING!!!**: 叠甲，接下来的知识并不一定准确，由于有些知识的获取实在是过于困难了，因此只是简单的描摹一下我所理解的大概，为了方便理解，也用了很口语化的表达，仅供参考。在使用本文的知识时，请一定要有一定判断能力，查询相关的资料，尊重真实的事实。

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
|EGL|全平台"万能胶"。它是 Khronos 定义的现代接口，不依赖特定操作系统。旨在替代上述两个|
|OpenGL|桌面级标准。功能最全、历史最悠久的 API。支持从简单的 2D 到复杂的 3D 渲染，拥有极其丰富的特性集，主要运行在 PC 和工作站(Windows, Linux)上。|
|GLES|移动级/嵌入式标准 (OpenGL for Embedded Systems)。它是 OpenGL 的精简版。去掉了大量过时且沉重的旧特性，专为手机(Android/iOS)、游戏机和车载系统优化，追求高性能和低功耗。|

**重要**: 对于**显卡厂商**而言，要实现的只有**表二**，OpenGL 规范制定之下，显卡厂商需要实现一个**动态链接库**，应用程序通过链接这个动态链接库来使用其中的函数，而这个动态链接库里提供的符号的规范，正是 OpenGL 系列，而这个动态链接库，就是显卡厂商为显卡实现的**用户态驱动**

而链接完毕之后，由于这些用户态在实现上的一些特殊性，OpenGL 的函数地址在编译期是不确定的，正是因为如此在现代 OpenGL 环境中，需要使用像 GLAD/GLEW 这样的加载器来获取**扩展或新版** API 的入口地址，因为这些接口在编译期无法静态链接。

而 GLFW 这类库，只不过是在 GLEW 完活后，调用了一些 EGL 这类的接口完成了初始化，并且实现了事件循环而已

---

## 用户态驱动视角下的 OpenGL
考虑 OpenGL ES，它提供了一组工具，其中主要包含着色器的提交与编译，资源对象传输与管理的接口，渲染调用接口等等。其中着色器，对于 OpenGL 全系列，都是要使用 `glCreateShader`，`glCompileShader` 这样的 API 提交一个字符串(glsl)并编译才能使用的。实际上是传入了用户态驱动中进行编译。因此实际上厂商携带的用户态驱动里面一般会有一个 glsl 的相对于 CPU 来说异构的编译器，还有很多别的乱七八糟的管理工具。

### libglvnd
很多时候，你的电脑上并不只有一个用户态驱动，比如我的电脑就是核显(r7-6800h)和独显(3060 laptop)混合输出。在这样的 Linux 的多显卡或多驱动环境下，如果多个厂商都提供了名为 libGL.so 的动态链接库，系统就会陷入冲突。为了解决这个问题，NVIDIA 牵头并与社区共同开发了 **libglvnd**

作为**通用显卡驱动分发层**。libglvnd 不实现具体的 OpenGL 逻辑，而是根据当前的上下文决定将 API 调用转发给哪一个具体的厂商驱动。

libglvnd 的引入彻底改变了 Linux 图形库的链接方式: 

1. 统一入口: 应用程序不再直接链接到 Mesa 或 NVIDIA 的私有库，而是链接到 libglvnd 提供的公共入口(如 `libGL.so.1` 或 `libOpenGL.so.0`)。
2. 动态分发: 当你调用 `glDrawArrays` 时，libglvnd 会在内部查询当前的渲染上下文(Context)，并将其重定向到实际的后端实现。

### Mesa3D
如果每个厂商都要实现这么多东西，显然工作量太大了，Linux 后期社区孵化了一个叫做 mesa3d 的项目，mesa3d 提供了一套通用的状态跟踪器(State Trackers)和驱动框架(Gallium3D)，极大地简化了硬件厂商的适配工作。

Mesa 实现了 OpenGL/Vulkan 等 Khronos API，并通过 libGL/libGLES 等库供应用链接。Mesa3D 实现了一个中间层，很多厂商在这个中间层之下接入了自家的后端，Mesa3D 因此能够将应用程序调用 Mesa3D 的动态链接库里的函数时转发给实际的后端。

在 Mesa3D 的架构下，**厂商不再需要从零开始编写整个图形** API 的逻辑。具体来说，Mesa3D 提供了以下三个核心层面的支持: 

1、统一的硬件抽象层: **Gallium3D**
Mesa 引入了 Gallium3D 架构，它将图形驱动拆分为两个部分: 前端负责处理复杂的 OpenGL、OpenCL 或 VDPAU 状态机。这部分代码是全硬件通用的，而后端厂商只需要编写一个极简的"硬插件"，负责将 Gallium 的中间表示(TGSI 或 NIR)翻译成自家显卡的机器码。于是厂商只需要完成自家的硬件相关代码，剩下的通用逻辑全部由 Mesa 社区维护。
2、强大的着色器编译器: **NIR**
现代图形渲染的核心是着色器编译。Mesa 提供了一个高性能的中间表示层 NIR。
它包含了大量的优化算法。无论是 Intel、AMD 还是高通的 Adreno，都可以直接利用这些现成的优化逻辑，而不需要各自去研究复杂的编译器架构。
3、跨平台的系统集成接口
Mesa 统一处理了图形缓冲区的分配与共享。通过: 

- EGL/GLX: 解决了窗口系统(Wayland/X11)与图形 API 之间的衔接。
- gbm (Generic Buffer Management): 提供了统一的内存管理接口。
- dma_buf: 实现了 GPU 与 CPU、甚至不同硬件单元(如视频解码器与显示控制器)之间的零拷贝数据交换。

总的来说，Mesa3D 提供了一套方便厂商编写用户态驱动的开发套件，只要接入 Mesa3D，适配 Gallium 接口并提供基础的内核 DRM 驱动，就能立刻获得成熟、稳定且高性能的 OpenGL 和 Vulkan 支持。

> 是的，nvidia 就是没有接入 Mesa3D，自己实现了用户态驱动。值得一提的是 nvidia 的社区版，逆向出来的驱动 nouveau 也是接入的 Mesa3D，nouveau 这个项目的内容就是 Mesa3D 的一个文件夹以及其内核态驱动

顺带一提，对于某些需要特殊符号的任务，Mesa3D 也能如 nvidia 一样有一套超越 OpenGL 的私人接口，这些接口的实现和不再有像 libglvnd 那样通用的、跨平台的 Loader 了。

<img src="/images/客户端与Linux图形栈_图1.png" width="100%" height="100%">

<img src="/images/客户端与Linux图形栈_图2.png" width="100%" height="100%">

mesa3d 架构图，对外暴露动态链接库

---

## EGL
在 Linux 现代图形栈中，EGL 是连接图形 API(OpenGL/GLES)与底层窗口系统(Wayland/X11)的唯一纽带。

首先我们介绍一下 Wayland: 在 Linux 图形栈中，Wayland 它是一套目前最现代的现代图形显示协议。它定义了客户端如何与合成器(Compositor/Server，如 Hyprland)进行对话。应用程序，在wayland 语境下就是客户端，他们通过递交一个被称为 framebuffer 的渲染结果(可以理解为用户这边的绘制的画布)，交给合成器，合成器将统合所有客户端的结果，绘制桌面等其余的东西，合成一个完整的图像交给显示器显示

EGL 是怎么做到和平台通信的呢？对于 wayland，EGL 会通过链接 libwayland-client.so，利用其底层协议与 Wayland Server 通信。对于 Wayland 而言: 

- 获取 Surface: Wayland Client 需要向 Server 申请一个 wl_surface。

- fd 传递: EGL 会通过 Wayland 协议，基于 dma_buf 机制把包含渲染结果的内存文件描述符(fd)发给 Server。

- 零拷贝: Server 拿到 fd 后，直接将其作为纹理合成到屏幕上，整个过程数据无需在 CPU 和 GPU 之间来回搬运。

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

> **WARNING**: 本节内容基本上是 AI 辅助探索，不确定性因素较大，好在大家并不会直接接触这方面的内容，注意打标签(unsure)的是不够确定的项，但也是具有一定可信的，只不过 AI 说出后我没有手段对其加以验证，如果有人能够解决，请联系我

我们已经进入了深水区，这一部分的学习方法只有一个，阅读源码，由于 n 卡的特殊性，我们选取 amdgpu 来学习，阅读 mesa3d，与 linux 内核里提供的源码，以及 amd 官方提供的手册与工具，能对 amdgpu 有一个大致的了解已经殊为不易

显卡，众所周知，具有极多的小"CPU 核心"，通过并发来实现对某些计算的加速。然后其内部有一些固定的硬件，比如硬件级的渲染管线，可以加速 3D 渲染的过程。只需要知道这点，我们就可以来对 AMDGPU 进行一个简单的了解了

我们首先介绍一下一个工具 `umr`，https://umr.readthedocs.io/en/main/index.html

我们此次要讲的东西包含在下面这个板块: https://umr.readthedocs.io/en/main/ring.html

你可以访问我这个博客的文档仓库中的 [amdgpu_ring_grab.txt](https://github.com/feipiao594/Self-study-notes/blob/main/CS_%E8%AE%A1%E7%AE%97%E6%9C%BA/Basic_principles/Linux/amdgpu_ring_grab.txt) 来看我之前抓取的我自己电脑上的一个文件

这个文件抓取的东西叫做 ring buffer，内核驱动在启动时会创建这些队列(是这些，因为并发性，不只一个环形队列，而且也不只图形渲染)，其实就是在 CPU 和 GPU 的共享内存上创建一个环形队列，通过它推送命令。环形队列其中的单一元素叫做一个 PM4 包，你可以看下面这样的一张示意图: 

<img src="/images/客户端与Linux图形栈_图5.png" width="100%" height="100%">

下面这张图是展示一下不只有一个ring，可以看到这边有两个关于图像的 ring，分别是 `amdgpu_ring_gfx_0.0.0`，`amdgpu_ring_gfx_0.1.0` 位于倒数第二列，但是其实还有别的功能的 ring，比如 comp 是指通用计算，vcn_dec，vcn_enc 是视频编解码，都会像 gfx 图像一样工作。音频不太一样，它的场景不同，这块我们就先按下不表了

<img src="/images/客户端与Linux图形栈_图6.png" width="100%" height="100%">

让我们具体看看抓取的内容吧

```text
......
Decoding IB at 0x0@0x0 from 0x0@0x0 of 2048 words (type 4)
[0x0@0x00000000 + 0x0000]	[        0xc0032200]	Opcode 0x22 [PKT3_COND_EXEC] (4 words, type: 3, hdr: 0xc0032200)
[0x0@0x00000000 + 0x0004]	[        0x00401160]	|---> GPU_ADDR_LO32=0x401160
[0x0@0x00000000 + 0x0008]	[        0x00000000]	|---> GPU_ADDR_HI32=0x0
[0x0@0x00000000 + 0x000c]	[        0x00000000]	|---> COMMAND=0
[0x0@0x00000000 + 0x0010]	[        0x0000001b]	|---> EXEC_COUNT=27
[0x0@0x00000000 + 0x0014]	[        0xc0012800]	Opcode 0x28 [PKT3_CONTEXT_CONTROL] (2 words, type: 3, hdr: 0xc0012800)
[0x0@0x00000000 + 0x0018]	[        0x80000000]	|---> LOAD_EN=1, LOAD_CS=0, LOAD_GFX=0, LOAD_GLOBAL=0, LOAD_MULTI=0, LOAD_SINGLE=0
[0x0@0x00000000 + 0x001c]	[        0x00000000]	|---> SHADOW_EN=0, SHADOW_CS=0, SHADOW_GFX=0, SHADOW_GLOBAL=0, SHADOW_MULTI=0, SHADOW_SINGLE=0
[0x0@0x00000000 + 0x0020]	[        0xc0009000]	Opcode 0x90 [PKT3_FRAME_CONTROL] (1 words, type: 3, hdr: 0xc0009000)
[0x0@0x00000000 + 0x0024]	[        0x00000000]	|---> TMZ=0, COMMAND=0
......
```

看一下我抓取文件的开头部分 2-6 行就是一个 PM4 包，他以一个 Opcode 打头，然后后面会跟着一组参数，看起来像是一个简单序列化的结构体，这样的东西通过一个环形队列交给 GPU，CPU 负责在这个环形队列上创建 PM4 来控制 AMDGPU，诶，那 shader 的 isa 怎么没看见呢？不是说 GPU 是极多的小"CPU 核心"么？

其实我们忽略了一件事情，那么多小核心总要有人管的吧，这个总管的控制器，我们称其为 CP (Command Processor，命令处理器)，你可以理解为 CP 的指令就是 PM4，他将在硬件层级解析这个包并执行指令。所以 CP 其实是这个环形队列的消费者，而我们熟悉的 CPU 世界是生产者

不知道你关注到没有，上面这一段代码有一个"[0x0@0x00000000 + 0x0000]"的前置信息，这段信息就是指的地址，在这里显然是指的 ring buffer，但是文件里还有别的地址，比如第 284 行

```text
......
Decoding IB at 0x3@0x80010005ad00 from 0x0@0x28 of 176 words (type 4)
[0x3@0x80010005ad00 + 0x0000]	[        0xc0012800]	Opcode 0x28 [PKT3_CONTEXT_CONTROL] (2 words, type: 3, hdr: 0xc0012800)
[0x3@0x80010005ad00 + 0x0004]	[        0x80000000]	|---> LOAD_EN=1, LOAD_CS=0, LOAD_GFX=0, LOAD_GLOBAL=0, LOAD_MULTI=0, LOAD_SINGLE=0
[0x3@0x80010005ad00 + 0x0008]	[        0x80000000]	|---> SHADOW_EN=1, SHADOW_CS=0, SHADOW_GFX=0, SHADOW_GLOBAL=0, SHADOW_MULTI=0, SHADOW_SINGLE=0
[0x3@0x80010005ad00 + 0x000c]	[        0xc0004600]	Opcode 0x46 [PKT3_EVENT_WRITE] (1 words, type: 3, hdr: 0xc0004600)
[0x3@0x80010005ad00 + 0x0010]	[        0x0000000e]	|---> EVENT_TYPE=[BREAK_BATCH]/14, EVENT_INDEX=0
[0x3@0x80010005ad00 + 0x0014]	[        0xc0001200]	Opcode 0x12 [PKT3_CLEAR_STATE] (1 words, type: 3, hdr: 0xc0001200)
[0x3@0x80010005ad00 + 0x0018]	[        0x00000000]	|---> CMD=0
......
```

这又是怎么回事呢，你可以看到这里面内容也是 PM4，其实这些东西是通过 DMA 机制直接送给 GPU 可以读取的内存区域的，而我刚刚说了 CP 是消费者，他只会消费 ring buffer 里的 PM4 包。但其实这些其他区域的这块 PM4 包，是通过"函数调用"的机制运行的

依旧查看我们的抓取的文件的内容，第 13 行: 

```text
......
[0x0@0x00000000 + 0x0028]	[        0xc0023f00]	Opcode 0x3f [PKT3_INDIRECT_BUFFER] (3 words, type: 3, hdr: 0xc0023f00)
[0x0@0x00000000 + 0x002c]	[        0x0005ad00]	|---> IB_BASE_LO=0x5ad00, SWAP=0
[0x0@0x00000000 + 0x0030]	[        0xffff8001]	|---> IB_BASE_HI=0x8001
[0x0@0x00000000 + 0x0034]	[        0x030000b0]	|---> IB_SIZE=176, IB_VMID=3, CHAIN=0, PRE_ENA=0, CACHE_POLICY=0, PRE_RESUME=0, PRIV=0
......
```

`PKT3_INDIRECT_BUFFER` 意味着这是在使用一个 indirect 的 buffer，看他的参数 `IB_BASE_LO=0x5ad00`，`IB_BASE_HI=0x8001` 分别是低位和高位，拼起来就是 0x8001|0005ad00，嗯对就是刚刚那个地方说的 `[0x3@0x80010005ad00 + 0x0000]`

> [0x0@0x00000000 + 0x002c]	[        0x0005ad00]	|---> IB_BASE_LO=0x5ad00, SWAP=0，请看第二列"汇编是"0x0005ad00，是省略了高三位的 0 的

不过 GPU 没有函数调用栈，它应该是通过固定几个寄存器存储的调用关系(unsure)，所以深度非常有限，可以看下面这张示意图(图片来源于，https://www.jianshu.com/p/e835413c2e1f)

<img src="/images/客户端与Linux图形栈_图7.png" width="100%" height="100%">

所以 ring buffer 能调用内存里的一块 PM4 包，那当然也可以调用 shader，CP 在具体运行到某一个 ring buffer 命令的时候，会把内存里此前通过 DMA 传递的 shader 真的发射到他管辖的那堆小 "CPU" 上，而这些小 "CPU" 我们叫它为 CU (Compute Unit，计算单元)

来看看文件里的 shader 内容: 

```text
......
Shader from 0x3@[0x80010005a100 + 0x6f0] at 0x3@0x800000600400, type PS (0), size 96
Shader registers (unfiltered):
	gfx1033.mmCB_BLEND0_CONTROL(3@0x80010005a36c) == 0x40000501
	gfx1033.mmCB_COLOR0_ATTRIB(3@0x80010005a4ec) == 0x0
	gfx1033.mmCB_COLOR0_ATTRIB2(3@0x80010005a548) == 0x1dfc437
......
Shader program:
    pgm[3@0x800000600400 + 0x0   ] = 0xbe84047e		s_mov_b64 s[4:5], exec                                     	
    pgm[3@0x800000600400 + 0x4   ] = 0xbefe0a7e		s_wqm_b64 exec, exec                                       	
    pgm[3@0x800000600400 + 0x8   ] = 0xbe800303		s_mov_b32 s0, s3                                           	
    pgm[3@0x800000600400 + 0xc   ] = 0xb0018000		s_movk_i32 s1, 0x8000                                      	
    pgm[3@0x800000600400 + 0x10  ] = 0xbfa10001		s_clause 0x1                                               	
    pgm[3@0x800000600400 + 0x14  ] = 0xf40c0200		s_load_dwordx8 s[8:15], s[0:1], 0x400                      	
    pgm[3@0x800000600400 + 0x18  ] = 0xfa000400	;;                                                          	
    pgm[3@0x800000600400 + 0x1c  ] = 0xf4080000		s_load_dwordx4 s[0:3], s[0:1], 0x430                       	
    pgm[3@0x800000600400 + 0x20  ] = 0xfa000430	;;                                                          	
    pgm[3@0x800000600400 + 0x24  ] = 0xbefc0307		s_mov_b32 m0, s7                                           	
    pgm[3@0x800000600400 + 0x28  ] = 0xc8000002		v_interp_p1_f32_e32 v0, v2, attr0.x                        	
    pgm[3@0x800000600400 + 0x2c  ] = 0xc8040102		v_interp_p1_f32_e32 v1, v2, attr0.y                        	
    pgm[3@0x800000600400 + 0x30  ] = 0xc8010003		v_interp_p2_f32_e32 v0, v3, attr0.x                        	
    pgm[3@0x800000600400 + 0x34  ] = 0xc8050103		v_interp_p2_f32_e32 v1, v3, attr0.y                        	
    pgm[3@0x800000600400 + 0x38  ] = 0x87fe047e		s_and_b64 exec, exec, s[4:5]                               	
    pgm[3@0x800000600400 + 0x3c  ] = 0xbf8cc07f		s_waitcnt lgkmcnt(0)                                       	
    pgm[3@0x800000600400 + 0x40  ] = 0xf0800f08		image_sample v[0:3], v[0:1], s[8:15], s[0:3] dmask:0xf dim:SQ_RSRC_IMG_2D	
    pgm[3@0x800000600400 + 0x44  ] = 0x00020000	;;                                                          	
    pgm[3@0x800000600400 + 0x48  ] = 0xbf8c3f70		s_waitcnt vmcnt(0)                                         	
    pgm[3@0x800000600400 + 0x4c  ] = 0x5e000300		v_cvt_pkrtz_f16_f32_e32 v0, v0, v1                         	
    pgm[3@0x800000600400 + 0x50  ] = 0x5e020702		v_cvt_pkrtz_f16_f32_e32 v1, v2, v3                         	
    pgm[3@0x800000600400 + 0x54  ] = 0xf8001c0f		exp mrt0 v0, v0, v1, v1 done compr vm                      	
    pgm[3@0x800000600400 + 0x58  ] = 0x00000100	;;                                                          	
    pgm[3@0x800000600400 + 0x5c  ] = 0xbf810000		s_endpgm                                                   	
Done disassembly of shader
......
```

前面是抓取时一堆 GPU 的寄存器内容，后面是 shader 具体的内容

可以看到 shader 确实 DMA 进来的，第 1432 行

```text
......
[0x3@0x80010005a100 + 0x0718]	[        0xc0055000]	Opcode 0x50 [PKT3_DMA_DATA] (6 words, type: 3, hdr: 0xc0055000)
[0x3@0x80010005a100 + 0x071c]	[        0x60200000]	|---> ENGINE_SEL=0, SRC_CACHE_POLICY=0, DST_SEL=2, DST_CACHE_POLICY=0, SRC_SEL=3, CP_SYNC=0
[0x3@0x80010005a100 + 0x0720]	[        0x00600400]	|---> SRC_ADDR_LO_OR_DATA=0x600400
[0x3@0x80010005a100 + 0x0724]	[        0xffff8000]	|---> SRC_ADDR_HI=0xffff8000
[0x3@0x80010005a100 + 0x0728]	[        0x00600400]	|---> DST_ADDR_LO=0x600400
[0x3@0x80010005a100 + 0x072c]	[        0xffff8000]	|---> DST_ADDR_HI=0xffff8000
......
```

然后是设置 shader 的代码，1439 行，这里就展示一个设置低位的，定位到了 `pgm[3@0x800000800300 + 0x0   ]`

```test
......
[0x3@0x80010005a100 + 0x0734]	[        0xc0017600]	Opcode 0x76 [PKT3_SET_SH_REG] (2 words, type: 3, hdr: 0xc0017600)
[0x3@0x80010005a100 + 0x073c]	[        0x00008003]	|---> gfx1033.mmCOMPUTE_PGM_LO=0x8003
......
```

最终经过其他指令的一系列配置之后应当通过 `PKT3_DISPATCH_DIRECT` 这类命令发射(unsure)

总而言之，这一部分就是想告诉大家，shaders 和顶点资源等是一样的，通过 DMA 传输进显卡认可的内存区域，一般情况下再在 ring buffer 里放置 PM4 包交给 CP 执行，CP 会把 shader 发射到一组 CU 里进行执行，再实际产生效果。

所以这里有一些基本的事实。用口语化的说法，PM4 是 CP 的"汇编"，而 shader isa 是 CU 的"汇编"，他们俩不一样。事实上我也确实没能在 AMD 的开放手册里翻到 PM4 和 shader isa 同时出现在一个 pdf 里。

而 PM4 实际上对应的是 OpenGL 的一堆具体 API，而 shader 实质上是 glsl 文件编译的结果，他们俩可能中间都会经历复杂的转换阶段，但是显然各自单独处理的。

## 图形 API 之上
对于前文的讨论，我们知道，图形 API 之上，其实基本上最简单的构筑就是 GLFW，他提供的能力我们通常称之为**窗口层**，他基本就只包含了下面三个能力: 

- 事件循环与分发的能力，可以新建并挂载事件，监听与回调
- 完成了 OpenGL 这类图形 API 的初始化，能够进行绘制，并把图像推到屏幕上
- 能够直接调用平台相关的控制接口

使用我此前异步的文章里提到的技术(实际上网络库所使用的事件循环本身和网络用的没有非常明显的本质区别，在实现上略有差别，但 io 多路复用在其并发的实现机理上是一样一样的)，以及本文中关于 OpenGL + EGL 的认识，你可以创建更加复杂的窗口库。注意，我们此前的行文逻辑是从窗口层往底层讲，但现在我们终于可以跳回来，看最上层的构筑了！

不过也别得意的太早，在此处进入了客户端工程师所有 UI 制作的起点，关于 UI 框架的构筑才刚刚开始...

接下来我将抛出一系列相对在各种 UI 框架(包括但不限于 QWidget，QtQuick，Slint，Flutter，React，Android 原生，Cocoa Touch 原生，SwiftUI)常见的统一的概念，并逐一对其进行一般性的概念解释，所以这一节并不一定只包含 Linux 的部分，不过对于窗口层来说，他们只不过都是一样的，上层构筑而已

### 控件树
这部分和开发者最相关，在现在 2026 年已经被讲烂的声明式 UI 出现之前(典型案例 SwiftUI，Android Kotlin Compose，React)，在更早的时候是像 QWidget 不依赖 `*.ui` 编写的那种写法，称为命令式，后来 `*.ui` 的写法也是在哪个之上的一个改进。不过历史演进不仅仅只有这三个，我这里只对比前两者。

声明式写法和命令式写法最大的区别在于: 

在命令式的写法里，你的代码充满了"动作"。你需要先实例化一个对象，然后像搭建积木一样，一行行地去设置它的尺寸、颜色、位置，最后再把它手动添加到父容器里。这种感觉就像是在写一份详细的施工说明书，每一个步骤都不能错位。如果你想在某个点击事件后改变 UI，你得再次写下寻找该对象、修改该属性的动作。代码的逻辑是碎片化的，散落在各种回调函数和初始化方法中。比较典型的例子就是你在 QWidget 里必须手动将你的组件作为一个 child 调用某个方法挂在父组件上，状态也需要手动修改

而在声明式写法里，你的代码更像是在画一张"蓝图"。你不是在命令程序"去做什么"，而是在宣告"这儿有一个什么样的东西"。你会发现 UI 的结构和逻辑是高度耦合在一起的，代码的层级感直接反映了 UI 的嵌套关系。最核心的快感在于，你只需要维护一个数据变量，界面会自动根据这个变量的变化而重新"坍缩"成正确的样子。React 是相当早的一批革新者，`useState` 这种方式将界面视作状态的函数，即 UI 等于 f(state)。开发者从繁琐的 DOM 或控件树手动操作中解脱出来，将精力完全集中在业务逻辑和数据流的设计上，从而极大地降低了 UI 开发的维护成本。

讲到这里其实还没提到组件树，事实上上面两种写法说白了就是在构建**组件树**，顾名思义就是组件组成的树咯。组件树父与子节点的关系一般也会反映他们在屏幕上的关系，因为最早组件树的出现，本质上就是为了解决 UI 复杂度和屏幕空间管理之间的矛盾。

就像我们前文提到的，窗口层只提供了裸的绘图 API，在这之上，有的 UI 框架可能会对绘图 API 进行再一次封装，但本质上还是绘图库。对于 UI 框架处理的最原始的绘图阶段，我们实际面对的是一个二维的像素阵列。如果没有组件树，你想在屏幕上画一个带文字的按钮，你得手动计算按钮矩形的坐标，再计算文字在矩形里的偏移量。一旦按钮往右挪动了 10 个像素，所有依赖它的元素坐标都得跟着手动重算。这种平铺直叙的坐标计算，在界面稍微复杂一点时就会变成一场灾难。

组件树的引入，实际上是引入了一套相对坐标系和逻辑归属关系。它模仿了现实世界中的包含关系: 一个窗口包含一个面板，面板包含一个工具栏，工具栏里又包含按钮。当你移动父节点时，所有的子节点会带着自己的相对坐标随之移动。这种层级结构极大地简化了位置计算，让开发者只需要关心局部，而不需要时刻盯着全局坐标。

更重要的是，组件树提供了一种分而治之的组织方式。每一个节点不仅代表一个视觉区域，还代表了一个逻辑边界。父节点负责管理子节点的布局算法，比如是横着排还是竖着排；父节点还负责截获和分发原始的硬件事件，比如鼠标点击了屏幕上的某个点，系统会顺着这棵树向下查找，看看到底是哪个叶子节点被点中了。

这种树形结构让 UI 变得可以预测。当你看到代码里的嵌套关系时，你脑子里立刻就能映射出屏幕上的遮盖关系和包含关系。它把杂乱无章的像素点，变成了一组有生命、有层级、能够互相通信的逻辑实体。同时他也便利了一堆开发调试工具的开发，在现在你能见到的真正能够被商用的 UI 框架里，都会具备有在调试阶段查看组件树的功能，甚至有一些极度美观可视化的页面。

组件树更多情况下实质上只是内存(不管是动态的还是静态的代码)里一棵对象树而已，但要想把组件树转换成真实上屏的东西，需要渲染组件树，实质上是在合适的时间点调用前文我们提到的绘图 API，而具体如何组织，便延伸出来了接下来的一堆概念: 布局算法，以及如果是声明式的写法，其以 diff 算法著称的实现。 

### 布局系统
布局系统其实是一个在各个 UI 框架里很不同的东西，例如 iOS Cocoa 的自动布局算法，本质上要求解布局约束的线性函数。而 flutter 这样的框架则是用的另外一套叫做弹性 Flex 布局的模式。

布局系统存在的意义，在于将组件树中抽象的"层级关系"转化为物理上真实的"几何信息"(即每个节点的 x,y,width,height)。在组件树那一节我们提到，子节点只需要关心相对坐标，但这个"相对坐标"具体是多少，正是布局系统的职能所在。

现代 UI 框架的布局过程，通常是一个父子节点之间不断"协商"的过程。父节点拥有对空间的最终解释权，它会向下传递约束(Constraints)，告诉子节点: "你有这么多地方可以用，你自己看着办"；而子节点则会根据自身内容(比如文字长度或图片大小)向上反馈它的尺寸(Size)。

这种"约束向下，尺寸向上"的模式在 Flutter 中被发挥到了极致，而在 iOS 的 Auto Layout 中，这种协商被进一步抽象为了一组线性方程组——开发者定义"按钮距离左边 20 像素"或"两个文本框等宽"，底层的 Cassowary 算法会实时求解这些约束，得出最终坐标。

当布局系统确定了所有组件的位置后，接下来，UI 框架需要面对另一个问题: 如果我只是改了一个小小的状态，难道要重新跑一遍所有的布局计算和绘图 API 吗？

这便引出了我们下一节的核心: 渲染流水线与 Diff 算法。

### 渲染流水线与 Diff 算法
当我们在代码里写下 state.count++ 时，UI 框架内部其实正在经历一场"从抽象逻辑到物理像素"的马拉松。渲染流水线(Rendering Pipeline)就是这场马拉松的赛道。

对于命令式框架，这套流水线通常是手动的: 你修改属性，框架标记该区域为"脏"(Dirty)，然后在下一帧调用绘制函数。但对于声明式框架，由于我们每次都像是重新"宣告"了一棵新树，如果真的粗暴地把整棵树推倒重来，CPU 和 GPU 都会陷入无意义的加班。

于是，Diff 算法登场了。它的核心任务是对比"新树"和"旧树"，它会像找不同一样，快速定位出哪些节点是新增的，哪些被删除了，哪些只是属性变了。通过对比，框架计算出一份"差异清单"。比如，只有这个 Label 的文字变了，那么流水线就只触发这个 Label 的重绘，而保持其他数以千计的组件不动。

这样的实现通常要不只要依赖组件树一棵树，事实上在 flutter 里组件树 Widget 树还会以自己为模板映射出另外 2 棵树: Element 树和 RenderObject 树，前者存储状态，后者真有一个调用绘制 API 的成员方法，它的 diff 算法不比较 Widget 树，而是比较 Element 树，如果有 Element 树底下成员的大变动，就要对应析构并生成新的 RenderObject 树上的对应映射过去的对象；如果只是状态变化，不涉及成员变更，就复用，只是把数据推过去针对那个节点重绘(当然有可能会涉及到子节点的一些重绘)。

### 命中测试与事件传递
组件树上每一个组件都存储有他们对应的位置，而当你点击屏幕上的某处时，实际上窗口层只给你提供了一个最裸的回调，你需要依赖这个回调生成在你 UI 框架下的"事件"的概念，在组件树里进行分发，这就是 UI 框架一侧的上层的事件分发机制。

所以，当用户的一根手指按在屏幕坐标(200,350)时，这个压力感应到底属于谁？

首先先要进行一个叫做命中测试的过程，通常 UI 框架会启动一次深度优先的深度搜索: 从根节点开始，询问当前坐标是否在自己的几何范围内。如果在，则递归询问自己的子节点。最终定位到最深层的那个叶子节点(比如那个按钮)

一旦找到了目标，事件消息传递就开始了。这就是大家熟知的"冒泡"或"捕获"机制(可能做前端的同学会更熟悉一点)。事件从叶子节点往回传，沿途的每一个父节点都有机会拦截这个点击并做出反应。这种设计保证了 UI 交互的逻辑自洽——你点中了一个放在面板上的按钮，面板和按钮都能感知到这个动作，且你可以决定谁先处理。

关于事件传递，可能会引发一些组件有复杂的竞争机制，设想这样一个常见，一个检测手势的可滑动组件套了一个检测手势的可滑动组件，那么他们的事件要怎么传递，你用户刚刚落下手指，或者是按下鼠标左键，此刻其实需要额外引入判断: 如外层的滚动列表想监测你是否在上下滑动，内层的滑块想监测你是否在调节数值，而中间的按钮还在等待一个可能的双击。为了解决这种"主权争议"，如 flutter 框架就引入一个**竞争场**的概念:

1. 当手指落下时，框架并不会立即宣布谁赢得了事件，而是将所有对此感兴趣的手势识别器都拉进这个竞争场，拉进竞争场的一般是命中测试通过的组件，接着开始缓冲后续的移动数据。

2. 由于实际上窗口层传递的事件是 Push，Move(dx, dy)，Down 这样的信息，所以滑动行为其实 UI 框架上层根据事件流推动建立在所有竞争场下滚动组件里的状态机，直到某一方"说自己胜出"

3. 如果手指移动距离超过了某个阈值，某个滚动组件里状态机发生改变，由滚动组件会跳出来宣布: "这是我的滑动行为！"并由框架分发"胜出"信号，此时其他竞争者会被强制踢出局，动作被锁定在滑动逻辑上。如果在短时间内手指抬起，且位移极小，那么点击识别器就会胜出，触发 `onClick` 回调。

4. 一旦某个识别器赢得了竞争，它就会"消费"掉后续所有的相关事件，直到手指离开屏幕。

这种机制有效地防止了 UI 操作的混乱——你不会在滑动列表的时候，莫名其妙地触发了列表项里的按钮。你可以尝试一下在常见的社交聊天软件中，如果你的好友那一项可以被左右滑动，你就不能在弹起手指前做上下滑动的动作了。

### 为什么你无法简单地"兼容"原生框架
可能你偶尔会产生一个宏大的想法: 既然大家都有一套类似的窗口层和组件树逻辑，我能不能写一个库，直接把我的组件"塞进" Android 的原生 View 系统或者 Cocoa 的视图层里？

答案往往是令人沮丧的: 很难，且不优雅。

原因在于**生态位的挤占**。原生框架(如 Android SDK 或 iOS UIKit)不仅是绘图工具，它们是操作系统的"管家"。它们拥有一套极其霸道的生命周期管理、线程模型和辅助功能支持，以及实际上你也不能扔掉平台专有的特性，你必须借助他们当你试图在它们之上构筑自己的框架时，你实际上是在"套娃"。你只有两个选择: 
完全妥协: 把你的组件封装成原生的视图。这样你会受限于原生的布局性能，且无法实现真正跨平台的极致一致性(就像早期的 React Native)，而且事实上这就只是一个普通的平台组件库罢了
彻底独立: 像 Flutter 或从头搓 Linux 图形栈一样，只向系统索要一个最基础的绘制上下文。

> 所以这就是 UI 框架构筑的冰山一角。从底层的窗口层到高层的组件树，每一层都在为"降低复杂度"而努力，因此，其展现出了吸引我的独特魅力

## 总结: 世界总是复杂的

> 所以，都看到这里了，你还觉得一个端侧应用开发是一个简单的事么(笑)

这条线路可能是最现代的，但你的电脑上还有许多历史债务，世界总是复杂的，我们这边只是阐述了 linux 模糊的样貌，至于 windows 和 macos，甚至是其他的移动端设备，整体的样子又会有所不同，但总的来说，因为各种兼容性，大家又有相当的一致性

事实上我们没办法给这个系统画出一个完整的图，错综复杂的结构，或许只有显卡厂商他们自己有能力研究明白，在这里我仍旧贴一张来自 wikipedia 相对完整的图，请注意，即使是这张图，在结构上仍然没有展示完全

<img src="/images/客户端与Linux图形栈_图8.png" width="100%" height="100%">


在这个板块我将写一些我了解到的上述内容里没提到的，关于一个 linux user 使用 linux 作为主力机时遇到的其他细节，希望能让你对你的电脑的一切有一个大体上的了解

- 你的电脑上或许会安装 xf86-video-xxx 系列驱动，他们是 xorg 的老产物。x server 一部分渲染(2D等)依赖他们，x server 应当只用 mesa3d 进行 3d 渲染
- 在上面这张总体图上，可以看见 computaion 板块，在当下 GPGPU 的出现，使得 AI 相关的技术栈实质上和图形栈极度相似。可以预想到 pytorch 对应 qt，计算图文件 onnx 对应 opengl 里 shader，算子编程更像是用户态的驱动编程，至于下方的厂商驱动，其实对于厂商完全就是同一套东西了
- 在上面这张总体图上左侧有一个 libinput，那是一个事件处理的库，主要的用途是解释来自内核发送的输入设备事件，他可以很好的与我此前异步所讲的事件循环系统，和 ropui 里真实的调度器兼容
- 可以看到 mesa 里还有 vaapi 这种音视频方面的用户态驱动实现，vaapi 和 opengl 一样是个协议，也有类似 libglvnd 的存在(libva)和对应的硬件驱动后端，虽然实际感觉他们在实现上还是有些不同。