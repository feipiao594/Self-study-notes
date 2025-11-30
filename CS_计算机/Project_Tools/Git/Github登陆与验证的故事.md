---
title: Github登陆与验证的故事
mathjax: false
categories:
  - CS_计算机
  - Project_Tools
  - Git
abbrlink: 5ef186e7
date: 2025-11-30 15:34:50
---

# Github登陆与验证的故事
最近一次给我的 Gentoo 滚包的时候，发现了一个很神奇的问题，特此来写一篇博客

<!--more-->

## 问题阐述
更新元数据到 steam 的时候，突然开始问我要用户名和密码了
```
>>> Syncing repository 'steam-overlay' into '/var/db/repos/steam-overlay'...
/usr/sbin/git fetch origin --depth 1
Username for 'https://github.com':
```

还记得很久之前，我一开始学习使用 git 的时候，到发生这个事情之前，我一直都是在这个登陆上瞎搞搞就成功的，但是此次发生这样的错误，我实在是受不了了。`steam-overlay` 提供了 `proton` 这样的基础设施，我必须修好它。

## 解决问题的开篇
实质上这个问题是好几个事情的叠加，我此次滚包距离上次滚包已经是有两个月之久了，最后变动的包一共有 684 项，总体编译并更新时长超过了 11 个小时。
首先我们知道，Github 其实在很久之前就不允许使用用户名+密码这种比较弱的身份验证方式登陆了，你必须在 Github 上创建 PAT(personal access token) 来验证你的身份，具体的创建方式在官方文档里有提供
https://githubdocs.cn/en/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens

注意上述方式只支持 https 的登陆，ssh 不能使用 PAT 进行登陆，而 Github 也给出了这个 PAT 具体是怎么使用的

<img src="/images/Github登陆与验证的故事_图1.png" width="100%" height="100%">

可以看到，默认的 Git 只支持使用 username 和 password 进行认证。让我们来细细讨论一下 git 的认证模式

## git 认证机制

> 注:下面讨论的对象全部都是官方的 Git CLI，不讨论第三方的 git 实现

其实官方的 Git CLI 并不是自己实现各种 HTTP 认证机制的，而是调用了 `libcurl` 来处理 HTTP 连接、握手、认证等底层细节。使用 `libcurl` 你只需要像下面这样设置 username 和 password

```c
CURL *curl = curl_easy_init();
if (curl) {
    curl_easy_setopt(curl, CURLOPT_URL, "https://example.com/repo.git");

    // Git 就是这么做的:把从 credential helper 拿到的字段设置进去
    curl_easy_setopt(curl, CURLOPT_USERNAME, "myuser");
    curl_easy_setopt(curl, CURLOPT_PASSWORD, "mypassword");

    // 默认情况 libcurl 根据服务器实际支持情况自动选择认证方式
    CURLcode res = curl_easy_perform(curl);
    curl_easy_cleanup(curl);
}
```

但大家都知道，验证方式可不是只有 username + password 这样一种模式，那么如果服务器问你要 token-only 的协商模式怎么办？
让我们来看看 git 实现了什么，搜索 `curl_easy_setopt`:
https://github.com/search?q=repo%3Agit%2Fgit%20curl_easy_setopt&type=code

你会发现，其实 git 只给 libcurl 传了 username + password，那么在这种情况下，其实如果服务器真问你要 token-only，是属于 `libcurl` 在只有 username + password 下无法处理的情况，那么库也只能给你返回一个错误了

**(结论 1) 所以其实 git 支持的模式就是，libcurl 在拥有 username + password 时能正常工作的那几个认证模式，其中最典型的就是 basic，其他都是在此基础上的安全性修正。**
所以在这种情况下，绝大部分 git 仓库在 http(s)下，既然反正都要使用用户名密码了，那么把密码当 token 也是一种合适的行为了

## VSCode 怎么做的？
在通过各种途径:比如 **Git Pro**、Git 源代码、LLM 搜索的情况下了解了这些，我立马意识到一个问题:
是啊，我现在也许可以解决当下的问题了，但是有一个破绽我还是不能理解，我常用的 VSCode 提供了 GUI 模式的 git 仓库操作能力，我为什么最近在 VSCode 底下的提交行为并没有出现问题，偏偏是滚包的时候出问题了？

AI 给我了一个结果，因为有所谓 GCM([git credential manager](https://github.com/git-ecosystem/git-credential-manager)) 存在，他说这个工具是通过设置如下选项进行配置 git 的 credential.helper 来起作用的
```bash
git config credential.helper
```

credential.helper 是 git 的一个凭证管理子系统，用于在“git 想要 username/password 时”，提供这些凭证，或者把它们保存下来。
其实工作原理就是 git 在做一些远程操作的时候就传给他们一些信息，要他们返还的一组 username + password 来登陆，而 git 本身并不负责这些

也就是说如果他们不存在那 git 应该每次 push/clone 操作都会问你讨要用户名密码

如果这条指令能够返回 `manager-core` 那么就说明我在使用 gcm 了
是...是么？AI 说的话我只能相信 50%，在我的电脑上这行指令成功返回了 `cache`

这是何意，cache 就只是把密码暂存在内存里几分钟，但我 VSCode 在我装完它这一年，基本在登陆后从不会再怎么多登陆，我甚至不知道怎么退出登陆(笑)

于是在实践下我发现了一些东西，`feipiao-study-record` 是我新建的一个私有库，在 vscode 的聚合终端和外部的 konsole 中完全不一样

<img src="/images/Github登陆与验证的故事_图2.jpg" width="100%" height="100%">

而且在我把 credential.helper 置空后，vscode 这边仍然可以工作。

这肯定是环境变量在起作用了，搜索了一下 vscode 聚合终端下面的环境变量，锚定了下面几个

```bash
> env | grep -i askpass
VSCODE_GIT_ASKPASS_NODE=/opt/vscode/code
SSH_ASKPASS=/usr/bin/ksshaskpass
GIT_ASKPASS=/opt/vscode/resources/app/extensions/git/dist/askpass.sh
VSCODE_GIT_ASKPASS_EXTRA_ARGS=
VSCODE_GIT_ASKPASS_MAIN=/opt/vscode/resources/app/extensions/git/dist/askpass-main.js
```

描述他们的[官方文档](https://git-scm.com/docs/gitcredentials)如下:

<img src="/images/Github登陆与验证的故事_图3.png" width="100%" height="100%">

他们这几个环境变量其实是一个朴素的 credential.helper，单纯只是一个 cli 进程，git 从标准 IO 传递并获取他们存取的用户名密码

**(结论 2)** 而这边的 `GIT_ASKPASS` 赫然就是 vscode 的东西，原来是用这种方式侵入并提供了认证服务啊，所有 vscode 的登陆窗口，vscode 里方便的认证，都来自于此，vscode 负责替你与 github 产生交互，最终生成一个 username + password 给 git，git 在这个会话的基础上进行与 github git 仓库的远程操作

使用以下命令可以删去这个环境变量，此时 vscode 和外部的 konsole 效果就一致了
```bash
env -u GIT_ASKPASS git clone <your-repo-https-url>
```

但是还是报错，直接报错，也没问我要，在给 GIT 打上 TRACE 环境变量后，从 log 里看到是 `SSH_ASKPASS` 在干坏事，我从来没有调整过 kde 的 `kwallet`，里面存储的从来就是一个错误的 token，所以这下就寄掉了。调整一下就可以工作了。

## GCM 去哪了
可以看到啊，在 github 的 settings - application 里有相关的允许的认证客户端的信息，vscode 插件的认证次数要远多于 gcm (我这边按照 Recently Used 排序了)

<img src="/images/Github登陆与验证的故事_图4.png" width="100%" height="100%">

但 GCM 这个东西确实存在啊。其实它是绑定在 windows 的 git 安装包的，所以 windows 用户其实一上来就使用了最现代的认证模式，它会拉起一个浏览器页面让你登陆
所以在 windows 上执行刚刚的我返回 `cache` 的指令，你们大概率会得到 `manager-core` 或者 `manager`

而如果 gcm 存在，那这些环境变量就不需要考虑了

## 总结
1. 官方 git cli 只在远程请求的时候问你要 username + password，支持的 http(s) 的认证模式就是，它所依赖的 libcurl 在拥有 username + password 时能正常工作的那几个认证模式，其中最典型的就是 basic，其他都是在此基础上的安全性修正。
2. 官方 git cli 可以从别的地方读入 username + password，有 credential.helper 和 askpass 系环境变量两种，其中前者优先级更高，详情请看上方标注出的官方文档
3. vscode 通过设置 GIT_ASKPASS 与其自身的内置插件来实现 github 登陆

## 建议
完全使用 GCM 来统一登陆手段，全局配置 credential.helper 为 GCM 会让 vscode 的认证 hook 失效，因为其实质上只是在调用 git，而 git 负责决定认证信息来源。

## 番外
### 事件一
2025-10-30 时，Gentoo 官方的 Github Organization 踢掉了所有第三方源，包括一些比较有名的，比如 steam-overlay、gentoo-zh
这也导致了上述滚包的时候产生的 github 认证问题不只是上述的这个问题，可能是 github 服务器认为这是一个属于 Gentoo 官方的 Github Organization 的私有仓库，问我要 token 来了
而我很久没滚包了，没看见 gentoo 社区里的新闻www

### 事件二
在查看 Pro Git 这本书的时候，我发现关于传输协议这段的描述
https://git-scm.com/book/en/v2/Git-Internals-Transfer-Protocols

中文版会把 The Dumb Protocol 翻译成哑协议，在我印象里 dumb 是愚蠢的意思，而且这边就两个协议，另一个叫 The Smart Protocol

我一开始以为是某种中国人的含蓄（
一搜发现 dumb 还真有哑的意思，而且排在愚蠢前，那到底是谁比较愚蠢自不必多说了 qwq

<img src="/images/Github登陆与验证的故事_图5.png" width="100%" height="100%">

我还是觉得这是中国人的含蓄