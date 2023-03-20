---
title: CMake的使用
mathjax: false
categories:
- ComputerScience
- Tools&Basics
---
# CMake的使用

**Feipiao**前段时间在做csapp的lab使用到了linux，最近把linux虚拟机换成了wsl，在vscode下进行 **code & study**
对于在vscode上，或者直接就是在linux内进行开发，使用make这种编译配置工具就跑不了了。
在这样的情况下，使用cmake进行**跨平台**的高级编译配置也就免不了了。
<!--more-->
## HelloWorld
我们先用单文件的helloworld练练手，首先创建一个文件为main.cpp
```C++
#include <iostream>
int main(){
    std::cout<<"Hello world"<<std::endl;
}
```
再创建一个CMakeLists.txt的文本文件注意这个文本文件的名字大小写是**敏感**的，在这个文本文件当中，我们就会进行cmake的书写与使用
CMakeLists.txt 的语法比较简单，由**命令、注释和空格**组成，其中命令是**不区分**大小写的

在这个文件中输入几个重要的，每个CMakeLists.txt都不可或缺的指令：
```
# CMake 最低版本号要求
cmake_minimum_required (VERSION 2.8)
# 项目名称信息
project (Helloworld)
# 指定生成目标的名字
add_executable(main main.cpp)
```

以“#”开头的为**注释**
运行cmake需要输入`cmake .`这里的`.`是指在当前文件夹内进行搜索CMakeLists.txt，执行完成后，会生成Makefile文件，再运行make就可以进行编译了。

## 更深一步，对于多个源文件
如果在当前文件夹下再创建一个cpp文件和头文件
```C++
/*---myfun.cpp---*/
int myfun(int a,int b){
    return a+b;
}
/*---myfun.h---*/
int myfun(int,int);
```
我们可以在原来的CMakeList.txt中的`add_executable`命令后面加上一个文件名，改为`add_executable(main main.cpp myfun.cpp)`，但显然这样一个一个加东西也不是个事，所以更省事的方法是使用`aux_source_directory`命令，该命令会查找指定目录下的所有源文件，然后将结果存进指定变量名。其语法如下：
```
aux_source_directory(<dir> <variable>)
```
这个命令会把dir下所有源文件统合，把名称存进variable这个位置的变量中，如下例：
```
# CMake 最低版本号要求
cmake_minimum_required (VERSION 2.8)
# 项目信息
project (Helloworld)
# 查找当前目录下的所有源文件
# 并将名称保存到 DIR_SRCS 变量
aux_source_directory(. DIR_SRCS)
# 指定生成目标
add_executable(main ${DIR_SRCS})
```

对于复杂的文件结构，有如下俩条指令
```
# 添加 dir 子目录
add_subdirectory(dir)
# 添加链接库
target_link_libraries(main myfun)
```
前者会使得dir子目录下的CMakeList.txt会一并处理，后者将指出main需要myfun的链接库

而在子目录中可以使用
```
#生成myfun链接库
add_library (myfun <choice> <filename>)
```
其中`<choice>`为`STATIC`则为静态链接库，`SHARDED`则为动态链接库

## 更多的重要指令
对于**Feipiao**来说，暂时只要能编译运行就行了，所以我们并不需要完成非常多的事情，因此这就到这里就可以结束了
有些指令还需要进行补充
```
# 支持cpp14
set(CMAKE_CXX_STANDARD 14)

```