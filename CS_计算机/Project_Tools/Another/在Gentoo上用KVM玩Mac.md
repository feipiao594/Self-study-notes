---
title: 在Gentoo上用KVM玩Mac
mathjax: false
categories:
  - CS_计算机
  - Project_Tools
  - Another
abbrlink: ebefb94c
date: 2024-11-19 10:32:33
---

# 在Gentoo上用KVM玩Mac
看起来大家都很喜欢 Mac，于是乎我也搞了一个虚拟机装 Mac，在这里记录一下安装过程希望能帮到大家

<!--more-->

## 前言

发现有些学弟学妹们买了 Mac，有些学长也全换了 Mac 搞开发，而我们的项目却常常由于缺少 Mac 导致适配不了这些设备，最后我还是启动了一个黑苹果

说起来这次装过 Mac 虚拟机之后，我基本上什么系统都装的七七八八了。之前因为学校学习用的各种专有软件也使用了很多虚拟机，最后让我在同学之中多了“虚拟机大神”的称号，这下是真的能算是对装虚拟机有不少经验了。

## 安装
我们使用到的项目是 OSX-KVM (https://github.com/kholia/OSX-KVM)
官方的仓库只写了对 Ubuntu 的支持，但基本上只要变动一下第一步安装的各种包就能解决问题
安装你所需的软件，此处略去了对 kernel 的要求，详情请自行查询 Gentoo Wiki

```bash
sudo emerge --ask --verbose 
        net-analyzer/openbsd-netcat \ 
        app-emulation/libguestfs \
        app-emulation/virt-manager \
        app-text/tesseract \
        app-emulation/qemu \
        app-misc/screen \
        sys-apps/net-tools \
        app-arch/p7zip
```

注意上述没有包含 `vim` `git` `wget` 这种极其常用的软件包，以及一些软件需要 unmask 操作

对于 `qemu` 需要注意加上 `usbredir` 和 `spice` USE flags

> **NOTE**: net-analyzer/openbsd-netcat 该包需要解决一些依赖问题，因为其和原有的 netcat 包不能共存，方法是 unemerge 原来的 netcat，参考 emerge 的报错即可

顺带一提，关于 ArchLinux 在被关闭的 pr 中有需要安装包的相关说明 (https://github.com/kholia/OSX-KVM/pull/232/files)

```bash
cd ~
git clone --depth 1 --recursive https://github.com/kholia/OSX-KVM.git
cd OSX-KVM

sudo modprobe kvm; echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs

sudo cp kvm.conf /etc/modprobe.d/kvm.conf  # for intel boxes only
sudo cp kvm_amd.conf /etc/modprobe.d/kvm.conf  # for amd boxes only

sudo usermod -aG kvm $(whoami)
sudo usermod -aG libvirt $(whoami)
sudo usermod -aG input $(whoami) # these 3 commands need reboot
```

使用它的 python 脚本下载 Mac 官方镜像

> **WARNING**: 经过实际测试 MacOS 13 官方推荐的版本是可用的，但 MacOS 14 15 不可用，即使在 python 文件中有标出能下载

```bash
./fetch-macOS-v2.py
```

输入以下两条指令创建 MacOS 所使用的虚拟磁盘
```bash
qemu-img create -f qcow2 mac_hdd_ng.img 256G

qemu-img convert BaseSystem.dmg -O raw BaseSystem.img

# for distribution with `dmg2img`, you can use command below
# dmg2img -i BaseSystem.dmg BaseSystem.img
```

是时候启动了
```bash
./OpenCore-Boot.sh
```

## 进入系统
首先启动 Install 的盘，将 256GB 大小的盘格式化为 APLS 文件系统，并安装，安装过程中涉及好几次重启，请注意别把自动重启当成出错了

## 添加到 `virt-manager` 中
在做完了上面的这些操作之后我们要把虚拟机加入到 virt-manager 中进行管理
```bash
sed "s/CHANGEME/$USER/g" macOS-libvirt-Catalina.xml > macOS.xml
virt-xml-validate macOS.xml
virsh --connect qemu:///system define macOS.xml
```

注意这里有一个很坑的地方，你需要手动删除配置文件中的两个东西才能正常启动，如下图，一个是此处的串口，一个是 `qemu-ga`

<img src="/images/在Gentoo上用KVM玩Mac_图1.png" width="100%" height="100%">

> **NOTE**: 由于我的独立显卡属于N卡，显卡直通缺少驱动，无法进行，所以这边我们就此略过

**这是我已经安装完成的 Mac**
<img src="/images/在Gentoo上用KVM玩Mac_图2.png" width="100%" height="100%">