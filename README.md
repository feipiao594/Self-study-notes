# 说明
这里是博客同步更新的GitHub仓库
博客链接：https://feipiao594.github.io

我当前一共有两个文件夹，一个存放的是这个仓库，下面称为**note文件夹**，另一个是博客的，下面称为**blog文件夹**，由于每次写note都要手动复制，让我这个懒人很不舒服，于是写了个处理脚本，即在仓库中的`qblog`

>注意，博客名中尽量不要含有空格等字符
## Python提交脚本使用方法
**English:**
```
Usage: qblog [-f | -m | -r | -s | -d | -Ss | -Sd | -c | -p | -C | -h | -g]
Options:
  -n: draft a new posts.
  -f: change config.
  -m: move files.
  -r: renew files.
  -s: move files, clean and generate, renew files, start server.
  -d: move files, clean and generate, renew files, deploy.
  -Ss: single start server.
  -Sd: single deploy.
  -c: clean and generate.
  -p: git commit and push.
  -C: check categorys.
  -h: help.
  -g <file>: change file header.
```

**Chinese:**
```
使用方法: qblog [-f | -m | -r | -s | -d | -Ss | -Sd | -c | -p | -C | -h | -g]
选项：
  -n: 新建一篇草稿。
  -f: 修改配置文件。
  -m: 移动文件。
  -r: 更新文件。
  -s: 移动文件、清理并生成、更新文件、启动服务器。
  -d: 移动文件、清理并生成、更新文件、部署。
  -Ss: 单独启动服务器。
  -Sd: 单独部署。
  -c: 清理并生成。
  -p: Git 提交并推送。
  -C: 检查分类。
  -h: 展示该帮助文档。
  -g <file>: 改变文件的信息头
```
### config.yaml
共有三个词条，其中 `log_state` 为日志等级
- log_state: 1
- blog_target: your/blog/src
- source: your/notesrc

在你使用 `qblog` 前必须先用 `qblog -f` 生成配置文件


## 批处理使用方法(DEPRECATED)

> WARNING: 该批处理已处于废弃状态, 仍然保留在 `CS_计算机/Project_Tools/Another/qblog.bat`

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

$Smooth = \text{max\_iter} + 1 - \frac{\log(\log(z_n)/\log(R))}{\log(2)}$

$1 - \frac{\log(\log(z_n)/\log(R))}{\log(2)} > 0$

