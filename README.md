# 说明
这里是博客同步更新的GitHub仓库
博客链接：https://feipiao594.github.io

我当前一共有两个文件夹，一个存放的是这个仓库，下面称为**note文件夹**，另一个是博客的，下面称为**blog文件夹**，由于每次写note都要手动复制，让我这个懒人很不舒服，于是写了个批处理文件，即在仓库中的`qblog.bat`

使用方法如下
将`qblog.bat`置于note文件夹下
请根据实际你note根目录与博客的文件(注意是要source文件夹的位置)**绝对地址**修改两个bat的变量设置
note文件夹中不会读取README.md，除此以外均会与blog位置判断是否修改，并覆盖，如果删除note文件夹下内容，对应的blog内也会删除，防止直接误操作blog导致崩坏(笑)
注意note文件夹下的images文件夹名字**必须是images**，该文件夹将直接与hexo中的images文件夹对应

qblog使用方法如下
1. `qblog -n <相对路径>`
    在相对路径下生成example.md新markdown文件，并在example.md中写好样例头
    注意这里的相对路径开头不包含`.\`
    相对路径样例`Mathematic\Calculus_on_manifolds`
    在vscode里可以通过对资源管理器中的文件夹右键，选择“复制相对路径”获得
2. `qblog -d`
    推送当前所有博客到github服务器
3. `qblog -s`
    推送当前所有博客并打开本地服务器
4. `qblog -c`
    将当前文件夹git commit，附带信息为上传时间
5. `qblog -p`
    即git push

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