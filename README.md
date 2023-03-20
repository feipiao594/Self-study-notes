# 说明
这里是博客同步更新的GitHub仓库
博客链接：https://feipiao594.github.io

我当前一共有两个文件夹，一个存放的是这个仓库，下面称为**note文件夹**，另一个是博客的，下面称为**blog文件夹**，由于每次写note都要手动复制，让我这个懒人很不舒服，于是写了**两个**批处理文件，在仓库中的`qblog.bat`是其中一个

使用方法如下
将`qblog.bat`置于note文件夹下，同时在blog文件夹下放置`MoveNote2Blog.bat`，这个文件在本篇文档中没有，内容在本md最后，如果要使用请自行创建文件，其作用是将note文件夹下所有`*.md`放进`_post`文件夹，请根据实际你note与博客的文件绝对地址修改两个bat的变量设置

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

`MoveNote2Blog.bat`内容
```
@echo off

set source=C:\daily\Self-study-notes
set readme_name=\README.md
set dest=C:\daily\Blog\source

del %dest%\_posts\*.md
del /q %dest%\images\*
echo from %dest% deleted last "move"

for /r "%source%" %%i in (*.md) do ( 
    echo %%i| findstr %readme_name% >nul && (
        echo %%i is README.md,skip.
    ) || (
        copy "%%i" "%dest%\_posts"
        echo %%i move to %dest%\_posts
    )
)

for /r "%source%\images" %%i in (*.*) do ( 
    copy "%%i" "%dest%\images"
    echo %%i move to %dest%\images
)

```