# 说明
这里是博客同步更新的GitHub仓库
博客链接：https://feipiao594.github.io

我当前一共有两个文件夹，一个存放的是这个仓库，下面称为**note文件夹**，另一个是博客的，下面称为**blog文件夹**，由于每次写note都要手动复制，让我这个懒人很不舒服，于是写了个批处理文件，即在仓库中的`qblog.bat`

>注意，博客名中尽量不要含有空格等字符
## Python提交脚本使用方法
等待完成

## 批处理使用方法(DEPRECATED)

> WARNING: 该批处理已处于废弃状态

### 放置并修改批处理文件
将`qblog.bat`置于note文件夹下
请根据实际你note根目录与博客的文件(注意是要source文件夹的位置)**绝对地址**修改两个bat的变量设置
note文件夹中不会读取README.md，除此以外均会与blog位置判断是否修改，并覆盖，如果删除note文件夹下内容，对应的blog内也会删除，防止直接误操作blog导致崩坏(笑)
注意note文件夹下的images文件夹名字**必须是images**，该文件夹将直接与hexo中的images文件夹对应

### 批处理使用
qblog使用方法如下
1. `qblog -n <相对路径>`
    在相对路径下生成example.md新markdown文件，并在example.md中写好样例头
    注意这里的相对路径开头不包含`.\`
    相对路径样例`Mathematic\Calculus_on_manifolds`
    在vscode里可以通过对资源管理器中的文件夹右键，选择“复制相对路径”获得
2. `qblog -s`
    快速将文件搬运，生成博客，并检查，并打开本地服务器
3. `qblog -d`
    快速将文件搬运，生成博客，并检查，并推送到github服务器
4. `qblog -sd`
    单独推送当前已经移动的博客到github服务器
5. `qblog -ss`
    单独推送当前已经移动的博客并打开本地服务器
6. `qblog -c`
    将当前文件夹git commit，附带信息为上传时间
7. `qblog -p`
    将当前文件夹git push
8. `qblog -r`
    更新当前文件夹里的内容和博客文件夹同步，只同步同名文件，**如果存在文件未被同步将会报waring**，主要用于递归调用检查，**不推荐使用者直接使用该参数**
9. `qblog -m`
    只进行移动生成博客与检查，不进行打开服务器等操作，即`qblog -s`或`qblog -d`去掉`hexo s`或者`hexo d`这一步操作

这里是md文件需要加入的样例头
```
---
title: NoteName
mathjax: false
categories:
- First-level catalog
- Second-level catalog
---
```

顺带一提，`.gitignore`中存放了未提交的本地加密博客文件夹名字，对于这个文件夹，其中新建文件需要在原来的文件夹下创建，并且手动搬运到这个未提交的文件夹中