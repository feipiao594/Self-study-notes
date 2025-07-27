---
title: CelesteMiaoNet自建群服教程
mathjax: false
categories:
  - CS_计算机
  - Project_Tools
  - Another
abbrlink: 75894d10
date: 2025-03-01 21:27:59
---

# CelesteMiaoNet自建群服教程
> 本教程能够帮助你自建喵服群服，此教程发布时间为2025.3.1，请注意教程的时效性

<!--more-->

## 前置条件
你需要对基本的服务器运维有一些了解，本教程不负责教学服务器基本运维，可以自行搜寻资料
你需要有一台 Windows 为系统的设备用来编译喵服(Linux/MacOS 可能亦可，但 Windows 能保证可行)
其次你需要一个拥有公网IP的服务器，你可以选择常见的云服务器 ECS 

## 下载 .NET 编译工具
前往微软官方，选择合适的 .NET 版本下载 **SDK**
https://dotnet.microsoft.com/zh-cn/download/dotnet

注意 Everest 使用的版本是 .NET 7.0，尽管目前这已经是一个不被支持的版本，但你可以仍然可以使用它

选取 `x64` ，即可开始下载
<img src="/images/CelesteMiaoNet自建群服教程_图1.png" width="100%" height="100%">

下载完毕后，直接运行就可以安装编译工具

## 下载喵服仓库
到喵服 Github 官网
https://github.com/CelesteNyaServer/CelesteNet

直接下载项目 zip 或使用 `git` 工具下载

```bash
git clone https://github.com/CelesteNyaServer/CelesteNet.git
```

**注意这个项目要求你把项目文件夹置于 Celeste 的 Mods 文件夹下**

## 编译喵服服务器

```
cd CelesteNet
dotnet build -c Release
```

如果运行没有报错，这时你应该能够在 `./CelesteNet.Server/bin/Debug/net7.0/*` 看见一个已经完整编译好的服务器，比如，目录下有 `CelesteNet.Server.exe`

## 部署
将上面的 `./CelesteNet.Server/bin/Debug/net7.0/*` 中 net7.0 这个文件夹压缩，并上传到你的服务器

如果服务器是 Windows 系统，你可以直接运行 `CelesteNet.Server.exe`

如果服务器是 Linux/MacOS 系统，请重复 `下载 .NET 编译工具` 这一步骤，注意选择对应系统与架构的 .NET 安装，你也可以直接使用包管理
安装完毕后你只需要使用如下指令即可轻松打开服务器

```bash
dotnet ./CelesteNet.Server.dll
```

> 对于 Linux 你也可以参考微软官方的教程
> https://learn.microsoft.com/zh-cn/dotnet/core/install/linux
> 注意 Debian 源内的包只支持 amd64 架构，如果你的服务器是其他架构，比如我的树莓派是 arm64，请使用手动安装方法

## 其他
1. 服务器的配置文件存在于 `./ModuleConfigs` 里，比如 `./ModuleConfigs/CelesteNetServer.ChatModule.yaml` 你可以添加一些进服时显示的信息，如下图

<img src="/images/CelesteMiaoNet自建群服教程_图2.jpg" width="100%" height="100%">

2. 服务器默认开放端口号为 17230

# 参考资料
1. [喵服仓库] https://github.com/CelesteNyaServer/CelesteNet
2. [官服仓库] https://github.com/0x0ade/CelesteNet
