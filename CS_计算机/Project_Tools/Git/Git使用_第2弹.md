---
title: Git使用_第2弹
mathjax: false
categories:
  - CS_计算机
  - Project_Tools
  - Git
abbrlink: 2b9af9d8
---
# Git使用_第2弹

接下来正式进入Git的使用部分，这一弹从 `"Pro Git"`的第二章开始

<!--more-->

## 在已存在目录中初始化仓库

如果你有一个尚未进行版本控制的项目目录，想要用Git来控制它，那么首先需要进入该项目目录中。

```shell
$ git init
```

该命令将创建一个名为 `.git`的子目录，这个子目录含有你初始化的Git仓库中所有的必须文件，这些文件是Git仓库的骨干。但是在这个时候，我们仅仅是做了一个初始化的操作，你的项目里的文件还没有被跟踪。

如果在一个已存在文件的文件夹(而非空文件夹)中进行版本控制，你应该开始追踪这些文件并进行初始提交。可以通过 `git add`命令来指定所需的文件来进行追踪，然后执行 `git commit`：

```shell
$ git add *.c
$ git add LICENSE
$ git commit -m 'initial project version'
```

---

## 克隆现有的仓库

如果你想获得一份已经存在了的Git仓库的拷贝，比如说，你想为某个开源项目贡献自己的一份力，这时就要用到 `git clone`命令。
克隆仓库的命令是 `git clone <url>`。比如，要克隆该博客的markdown文件夹，可以用下面的命令：

```shell
$ git clone https://github.com/feipiao594/Self-study-notes.git
```

这会在当前目录下创建一个名为 `"Self-study-notes"` 的目录，并在这个目录下初始化一个 `.git`文件夹， 从远程仓库拉取下所有数据放入 `.git`文件夹，然后从中读取最新版本的文件的拷贝。如果你进入到这个新建的文件夹，你会发现所有的项目文件已经在里面了，准备就绪等待后续的开发和使用。
如果你想在克隆远程仓库的时候，自定义本地仓库的名字，你可以通过额外的参数指定新的目录名：

```shell
$ git clone https://github.com/feipiao594/Self-study-notes.git dailyNotes
```

这会执行与上一条命令相同的操作，但目标目录名变为了 `dailyNotes`。
Git 支持多种数据传输协议。 上面的例子使用的是 `https://`协议，不过你也可以使用 `git://`协议或者使用
SSH传输协议，比如 `user@server:path/to/repo.git`。我们会 `"在服务器上搭建Git"`将会介绍所有这些协议在服务器端如何配置使用，以及各种方式之间的利弊。

---

## 记录每次更新到仓库

现在我们的机器上有了一个真实项目的Git仓库，并从这个仓库中检出了所有文件的工作副本。通常，你会对这些文件做些修改，每当完成了一个阶段的目标，想要将记录下它时，就将它提交到仓库。
请记住，你工作目录下的每一个文件都不外乎这两种状态：**已跟踪**或**未跟踪**。已跟踪的文件是指那些被纳入了版本控制的文件，在上一次快照中有它们的记录，在工作一段时间后，它们的状态可能是未修改，已修改或已放入暂存区。简而言之，已跟踪的文件就是Git已经知道的文件。
工作目录中除已跟踪文件外的其它所有文件都属于未跟踪文件，它们既不存在于上次快照的记录中，也没有被放入暂存区。初次克隆某个仓库的时候，工作目录中的所有文件都属于已跟踪文件，并处于未修改状态，因为Git刚刚检出了它们，而你尚未编辑过它们。
编辑过某些文件之后，由于自上次提交后你对它们做了修改，Git将它们标记为已修改文件。在工作时，你可以选择性地将这些修改过的文件放入暂存区，然后提交所有已暂存的修改，如此反复。
下图展示了文件的状态变化周期
<img src="/images/Git使用_第二弹_图1.png" width="100%" height="100%">

## 一些基本操作

下面是一些基本的操作

### 检查当前文件状态

可以用 `git status`命令查看哪些文件处于什么状态。

### 跟踪新文件

使用命令 `git add`开始跟踪一个文件。所以，要跟踪 `README`文件，运行：

```shell
$ git add README
```

此时再运行 `git status`命令，会看到 `README`文件已被跟踪，并处于暂存状态：

```shell
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
   new file: README
```

只要在 `Changes to be committed`这行下面的，就说明是已暂存状态。如果此时提交，那么该文件在你运
行 `git add`时的版本将被留存在后续的历史记录中。`git add`命令使用**文件或目录的路径**作为参数；如果参数是**目录的路径**，该命令将**递归**地跟踪该目录下的**所有文件**。

### 暂存已修改的文件

如果你修改了一个名为 `CONTRIBUTING.md`的已被跟踪的文件，然后运行 `git status`命令,，此时文件 `CONTRIBUTING.md`出现在 `Changes not staged for commit`这行下面，说明已跟踪文件的内容发生了变化，但还没有放到暂存区。要暂存这次更新，需要运行 `git add`命令。

> 注意 `git add`这是个多功能命令：可以用它开始**跟踪新文件**，或者把**已跟踪**的文件放到**暂存区**，还能用于**合并时把**有**冲突**的文件**标记**为**已解决**状态等。

如果你运行 `git add`命令后再一次修改 `CONTRIBUTING.md`文件，你就会发现现在 `CONTRIBUTING.md`文件同时出现在暂存区和非暂存区。

### 状态简览

可以在 `git status`后面添加 `-s`或者 `--short`参数即使用 `git status -s`命令或 `git status --short`命令，你将得到一种格式更为紧凑的输出。

```bash
$ git status -s
  M README
  MM Rakefile
  A lib/git.rb
  M lib/simplegit.rb
  ?? LICENSE.txt
```

新添加的未跟踪文件前面有 `??`标记，新添加到暂存区中的文件前面有 `A`标记，修改过的文件前面有 `M`标记。输出中有两栏，左栏指明了暂存区的状态，右栏指明了工作区的状态。例如，上面的状态报告显示：`README`文件在工作区已修改但尚未暂存，而 `lib/simplegit.rb`文件已修改且已暂存。`Rakefile`文件已修改，暂存后又作了修改，因此该文件的修改中既有已暂存的部分，又有未暂存的部分。

### 忽略文件

一般我们总会有些文件无需纳入Git的管理，也不希望它们总出现在未跟踪文件列表。通常都是些自动生成的文件，比如日志文件，或者编译过程中创建的临时文件等。在这种情况下，我们可以在项目根目录下创建一个名为 `.gitignore`的文件，列出要忽略的文件的模式。
要养成一开始就为你的新仓库设置好 `.gitignore`文件的习惯，以免将来误提交这类无用的文件。
文件 `.gitignore`的格式规范如下：

- 所有空行或者以 `#`开头的行都会被Git忽略。
- 可以使用标准的**glob模式匹配**，它会递归地应用在整个工作区中。
- 匹配模式可以以 `(/)`开头防止递归。
- 匹配模式可以以 `(/)`结尾指定目录。
- 要忽略指定模式以外的文件或目录，可以在模式前加上叹号 `(!)`取反。

所谓的glob模式是指**shell**所使用的**简化了的正则表达式**。 星号 `(*)`匹配零个或多个任意字符；`[abc]`匹配
任何一个列在方括号中的字符 (这个例子要么匹配一个a，要么匹配一个b，要么匹配一个 c)； 问号 `(?)`只
匹配一个任意字符；如果在方括号中使用短划线分隔两个字符， 表示所有在这两个字符范围内的都可以匹配
(比如 `[0-9]`表示匹配所有0到9的数字)。 使用两个星号 `(**)`表示匹配任意中间目录，比如 `a/**/z`可以匹配 `a/z`、`a/b/z`或 `a/b/c/z`等。

### 查看已暂存和未暂存的修改

想知道具体修改了什么地方，可以用 `git diff`命令。 稍后我们会详细介绍 `git diff`，你通常可能会用它来回答这两个问题：**当前做的哪些更新尚未暂存？有哪些更新已暂存并准备好下次提交**？ 虽然 `git status`已经通过在相应栏下列出文件名的方式回答了这个问题，但 `git diff`能通过文件补丁的格式更加具体地显示哪些行发生了改变。

不加参数直接输入 `git diff`可以比较工作目录中当前文件和暂存区域快照之间的差异。 也就是修改之后还没有暂存起来的变化内容。
若要查看已暂存的将要添加到下次提交里的内容，可以用 `git diff --staged`命令。 这条命令将比对已暂存文件与最后一次提交的文件差异

请注意，`git diff`本身只显示尚未暂存的改动，而不是自上次提交以来所做的所有改动。 所以有时候你一下子暂存了所有更新过的文件，运行 `git diff`后却什么也没有，就是这个原因。

用 `git diff --cached`查看已经暂存起来的变化(`--staged`和 `--cached`是同义词)

### 提交更新

现在的暂存区已经准备就绪，可以提交了。 在此之前，请务必确认还有什么已修改或新建的文件还没有 `git add`过，否则提交的时候不会记录这些尚未暂存的变化。这些已修改但未暂存的文件只会保留在本地磁盘。所以，每次准备提交前，先用 `git status`看下，你所需要的文件是不是都已暂存起来了，然后再运行提交命令

```shell
$ git commit
```

这样会启动你选择的文本编辑器(在很多IDE中，通常是vim)来输入提交说明。
你也可以在 `commit`命令后添加 `-m`选项，将提交信息与命令放在同一行

### 跳过使用暂存区域

尽管使用暂存区域的方式可以精心准备要提交的细节，但有时候这么做略显繁琐。Git提供了一个跳过使用暂存区域的方式， 只要在提交的时候，给 `git commit`加上 `-a`选项，Git就会自动把**所有已经跟踪过**的文件**暂存**起来**一并提交**，从而跳过 `git add`步骤

### 移除文件

要从Git中移除某个文件，就必须要从已跟踪文件清单中移除(确切地说，是从暂存区域移除)，然后提交。
可以用 `git rm`命令完成此项工作，并连带从工作目录中删除指定的文件，这样以后就不会出现在未跟踪文件清单中了。

### 移动文件

要在 Git 中对文件改名，可以这么做：

```shell
$ git mv file_from file_to
```

```shell
$ git mv README.md README
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)
  renamed: README.md -> README
```

运行 `git mv`就相当于运行了下面三条命令：

```shell
$ mv README.md README
$ git rm README.md
$ git add README
```

如此分开操作，Git也会意识到这是一次重命名，所以不管何种方式结果都一样。 两者唯一的区别在于，`git mv`是一条命令而非三条命令，直接使用 `git mv`方便得多。不过在使用其他工具重命名文件时，记得在提交前 `git rm`删除旧文件名，再 `git add`添加新文件名。

### 查看提交历史

在提交了若干更新，又或者克隆了某个项目之后，你也许想回顾下提交历史。完成这个任务最简单而又有效的工具是 `git log`命令。

<img src="/images/Git使用_第二弹_图2.png" width="100%" height="100%">
<img src="/images/Git使用_第二弹_图3.png" width="100%" height="100%">

### 撤消操作

```shell
$ git commit --amend
```

这个命令会将**暂存区**中的文件提交。如果自上次提交以来你还未做任何修改(例如，在上次提交后马上执行了此命令)，那么快照会保持不变，而你所修改的只是提交信息。
文本编辑器启动后，可以看到之前的提交信息。编辑后保存会覆盖原来的提交信息。

### 取消缓存与撤销修改

观察下面这段，可以看到下面叙述两个指令连用的效果

```shell
$ git add *

$ git status

On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)
  renamed: README.md -> README
  modified: CONTRIBUTING.md

$ git reset HEAD CONTRIBUTING.md

Unstaged changes after reset:
M CONTRIBUTING.md

$ git status

On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)
  renamed: README.md -> README
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working
directory)
  modified: CONTRIBUTING.md

$ git checkout -- CONTRIBUTING.md

$ git status

On branch master
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)
  renamed: README.md -> README
```

#### 取消暂存的文件

在你输入 `git status`后，在 `“Changes to be committed”`文字正下方，提示使用 `git reset HEAD <file>...`来取消**暂存**。

#### 撤消对文件的修改

同理，`git status`也会提示使用 `git checkout -- <file>...`来对未暂存区域中文件进行撤销修改，将它还原成上次提
交时的样子

### 查看远程仓库

如果想查看你已经配置的远程仓库服务器，可以运行 `git remote`命令。它会列出你指定的每一个远程服务器的简写。 如果你已经克隆了自己的仓库，那么至少应该能看到 `origin`——这是Git给你克隆的仓库服务器的默认名字
你也可以指定选项 `-v`，会显示需要读写远程仓库使用的Git保存的简写与其对应的URL。

我们在之前的章节中已经提到并展示了 `git clone`命令是如何自行添加远程仓库的， 不过这里将告诉你如何自
己来添加它。 运行 `git remote add <shortname> <url>`添加一个新的远程Git仓库，同时指定一个方便
使用的简写：

```shell
$ git remote
origin
$ git remote add pb https://github.com/paulboone/ticgit
$ git remote -v
origin https://github.com/schacon/ticgit (fetch)
origin https://github.com/schacon/ticgit (push)
pb https://github.com/paulboone/ticgit (fetch)
pb https://github.com/paulboone/ticgit (push)
```

现在你可以在命令行中使用字符串 `pb`来代替整个URL。例如，如果你想拉取 `Paul`的仓库中有但你没有的信息，可以运行 `git fetch pb`：

```shell
$ git fetch pb
remote: Counting objects: 43, done.
remote: Compressing objects: 100% (36/36), done.
remote: Total 43 (delta 10), reused 31 (delta 5)
Unpacking objects: 100% (43/43), done.
From https://github.com/paulboone/ticgit
 * [new branch] master -> pb/master
 * [new branch] ticgit -> pb/ticgit
```

现在Paul的 `master`分支可以在本地通过 `pb/master`访问到——你可以将它合并到自己的某个分支中， 或者如果你想要查看它的话，可以检出一个指向该点的本地分支。

### 从远程仓库中抓取与拉取

就如刚才所见，从远程仓库中获得数据，可以执行：

```shell
$ git fetch <remote>
```

这个命令会访问远程仓库，从中拉取所有你还没有的数据。执行完成后，你将会拥有那个远程仓库中所有分支的引用，可以随时合并或查看。如果你使用clone命令克隆了一个仓库，命令会自动将其添加为远程仓库并默认以 `“origin”`为简写。所以，`git fetch origin`会抓取克隆(或上一次抓取)后新推送的所有工作。必须注意 `git fetch`命令只会将数据下载到你的本地仓库，它并**不会自动合并或修改**你当前的工作。当准备好时你必须手动将其合并入你的工作。
如果你的当前分支设置了跟踪远程分支，那么可以用 `git pull`命令来**自动抓取**后**合并**该远程分支到当前分支。这或许是个更加简单舒服的工作流程。默认情况下，`git clone`命令会自动设置本地 `master`分支跟踪克隆的远程仓库的 `master`分支(或其它名字的默认分支)。 运行 `git pull`通常会从最初克隆的服务器上抓取数据并自动尝试合并到当前所在的分支。

### 推送到远程仓库

当你想分享你的项目时，必须将其推送到上游。这个命令很简单：`git push <remote> <branch>`。当你想要将 `master`分支推送到 `origin`(再次说明，克隆时通常会自动帮你设置好那两个名字)， 那么运行这个命令就可以将你所做的备份到服务器：

```shell
$ git push origin master
```

只有当你有所克隆服务器的写入权限，并且之前没有人推送过时，这条命令才能生效。

### 查看某个远程仓库

如果想要查看某一个远程仓库的更多信息，可以使用 `git remote show <remote>`命令。还可以通过 `git remote show`看到更多的信息

### 远程仓库的重命名与移除
你可以运行 `git remote rename`来修改一个远程仓库的简写名。 例如，想要将 `pb`重命名为 `paul`，可以用 `git remote rename`这样做：
```shell
$ git remote rename pb paul
$ git remote
origin
paul
```
值得注意的是这同样也会修改你所有远程跟踪的分支名字。那些过去引用`pb/master`的现在会引用
`paul/master`。
如果因为一些原因想要移除一个远程仓库——你已经从服务器上搬走了或不再想使用某一个特定的镜像了， 又或
者某一个贡献者不再贡献了——可以使用`git remote remove`或`git remote rm`：
```shell
$ git remote remove paul
$ git remote
origin
```
一旦你使用这种方式删除了一个远程仓库，那么所有和这个远程仓库相关的远程跟踪分支以及配置信息也会一起被删除。

### 打标签
#### 列出标签
在Git中列出已有的标签非常简单，只需要输入`git tag`(可带上可选的`-l`选项`--list`)

#### 创建标签
Git 支持两种标签：轻量标签(lightweight)与附注标签(annotated)。
- 轻量标签很像一个不会改变的分支——它只是某个特定提交的引用。
- 而附注标签是存储在 Git 数据库中的一个完整对象， 它们是可以被校验的，其中包含打标签者的名字、电子邮件地址、日期时间， 此外还有一个标签信息，并且可以使用 GNU Privacy Guard (GPG)签名并验证。通常会建议创建附注标签，这样你可以拥有以上所有信息。但是如果你只是想用一个临时的标签， 或者因为某些原因不想要保存这些信息，那么也可以用轻量标签。

#### 附注标签
在Git中创建附注标签十分简单。 最简单的方式是当你在运行tag命令时指定`-a`选项：
```shell
$ git tag -a v1.4 -m "my version 1.4"
$ git tag
v0.1
v1.3
v1.4
```
`-m`选项指定了一条将会存储在标签中的信息。如果没有为附注标签指定一条信息，Git会启动编辑器要求你输
入信息。
通过使用`git show`命令可以看到标签信息和与之对应的提交信息

#### 后期打标签
假设提交历史是这样的：
```shell
$ git log --pretty=oneline
15027957951b64cf874c3557a0f3547bd83b3ff6 Merge branch 'experiment'
a6b4c97498bd301d84096da251c98a07c7723e65 beginning write support
0d52aaab4479697da7686c15f77a3d64d9165190 one more thing
6d52a271eda8725415634dd79daabbc4d9b6008e Merge branch 'experiment'
0b7434d86859cc7b8c3d5e1dddfed66ff742fcbc added a commit function
4682c3261057305bdd616e23b64b0857d832627b added a todo file
166ae0c4d3f420721acbb115cc33848dfcc2121a started write support
9fceb02d0ae598e95dc970b74767f19372d61af8 updated rakefile
964f16d36dfccde844893cac5b347e7b3d44abbc commit the todo
8a5cbc430f1a9c3d00faaeffd07798508422908a updated readme
```
现在，假设在 v1.2 时你忘记给项目打标签，也就是在 `“updated rakefile”`提交。你可以在之后补上标签。 要在那个提交上打标签，你需要在命令的末尾指定提交的**校验和**(或部分校验和)：
```shell
$ git tag -a v1.2 9fceb02
```

#### 共享标签
默认情况下，`git push`命令并不会传送标签到远程仓库服务器上。在创建完标签后你必须显式地推送标签到
共享服务器上。这个过程就像共享远程分支一样——你可以运行`git push origin <tagname>`。

如果想要一次性推送很多标签，也可以使用带有`--tags`选项的`git push`命令。这将会把所有不在远程仓库服务器上的标签全部传送到那里

#### 删除标签
要删除掉你本地仓库上的标签，可以使用命令`git tag -d <tagname>`。
注意上述命令并不会从任何远程仓库中移除这个标签，你必须用`git push <remote>
:refs/tags/<tagname>`来更新你的远程仓库

这种操作有两个变体
第一种变体是`git push <remote> :refs/tags/<tagname>`，这种操作的含义是，将冒号前面的空值推送到远程标签名，从而高效地删除它。
第二种更直观的删除远程标签的方式是：
```shell
$ git push origin --delete <tagname>
```

####  检出标签
如果你想查看某个标签所指向的文件版本，可以使用`git checkout`命令， 虽然这会使你的仓库处于“分离头指针(detached HEAD)”的状态——这个状态有些不好的副作用：

```shell
$ git checkout 2.0.0
Note: checking out '2.0.0'.
You are in 'detached HEAD' state. You can look around, make experimental changes and commit them, and you can discard any commits you make in this state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b <new-branch>

HEAD is now at 99ada87... Merge pull request #89 from schacon/appendix-final

$ git checkout 2.0-beta-0.1

Previous HEAD position was 99ada87... Merge pull request #89 from schacon/appendix-final 
HEAD is now at df3f601... add atlas.json and cover image
```
在“分离头指针”状态下，如果你做了某些更改然后提交它们，标签不会发生变化，但你的新提交将不属于任
何分支，并且将无法访问，除非通过确切的提交哈希才能访问。因此，如果你需要进行更改，比如你要修复旧
版本中的错误，那么通常需要创建一个新分支：
```shell
$ git checkout -b version2 v2.0.0
Switched to a new branch 'version2'
```
如果在这之后又进行了一次提交，`version2`分支就会因为这个改动向前移动， 此时它就会和`v2.0.0`标签稍
微有些不同，这时就要当心了。


### Git别名
有一个小技巧可以使你的Git体验更简单、容易、熟悉：别名。我们不会在之后的章节中引用到或假定你使用过它们，但是你大概应该知道如何使用它们。
Git并不会在你输入部分命令时自动推断出你想要的命令。如果不想每次都输入完整的Git命令，可以通过git config文件来轻松地为每一个命令设置一个别名。 这里有一些例子你可以试试：

```shell
$ git config --global alias.co checkout
$ git config --global alias.br branch
$ git config --global alias.ci commit
$ git config --global alias.st status
```

这意味着，当要输入`git commit`时，只需要输入`git ci`。 随着你继续不断地使用 Git，可能也会经常使用其
他命令，所以创建别名时不要犹豫。
在创建你认为应该存在的命令时这个技术会很有用。 例如，为了解决取消暂存文件的易用性问题，可以向 Git 中
添加你自己的取消暂存别名：
```shell
$ git config --global alias.unstage 'reset HEAD --'
```
这会使下面的两个命令等价：
```shell
$ git unstage fileA
$ git reset HEAD -- fileA
```
这样看起来更清楚一些。 通常也会添加一个last命令，像这样：
```shell
$ git config --global alias.last 'log -1 HEAD'
```
这样，可以轻松地看到最后一次提交：

```shell
$ git last
commit 66938dae3329c7aebe598c2246a8e6af90d04646
Author: Josh Goebel <dreamer3@example.com>
Date: Tue Aug 26 19:48:51 2008 +0800
  test for current head
  Signed-off-by: Scott Chacon <schacon@example.com>
```

可以看出，Git只是简单地将别名替换为对应的命令。 然而，你可能想要**执行外部命令**，而不是一个 Git 子命令。如果是那样的话，可以在**命令前面加入`!`符号**。 如果你自己要写一些与Git仓库协作的工具的话，那会很有用。我们现在演示将 git visual 定义为 gitk 的别名：
```shell
$ git config --global alias.visual '!gitk'
```

## 总结
这一章讲了许多东西，但真正的重头戏还没有开始，下一弹，我们将进入分支模型