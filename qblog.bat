@echo off
chcp 65001
SET dest=C:\daily\Blog
IF "%1"=="-s" (
    cd "%dest%"
    .\MoveNote2Blog.bat&&hexo clean&&hexo g&&hexo s
) ELSE IF "%1"=="-d" (
    cd "%dest%"
    .\MoveNote2Blog.bat&&hexo clean&&hexo g&&hexo d
) ELSE IF "%1"=="-n" (
    IF EXIST "%2" (
        echo %2| findstr : >nul && (
            echo ERROR: Please enter a relative address instead of an absolute address,exit.&exit 1;
        )
        if exist %2\ (echo Creating file under %2) else echo ERROR: %2 is a file,not folder,exit.&exit 2 
        echo ---> "%2\example.md"
        echo title: NoteName>> "%2\example.md"
        echo mathjax: false>> "%2\example.md"
        echo categories:>> "%2\example.md"
        set remain=%2
        set remain=%2
        :loop
            for /f "tokens=1* delims=\" %%a in ("%remain%") do (
	        echo - %%a>> "%2\example.md"
	        set remain=%%b
        )
        if defined remain goto :loop
        echo --->> "%2\example.md"
        echo.>> "%2\example.md"
        echo.>> "%2\example.md"
        echo # Content>> "%2\example.md"
        echo.>> "%2\example.md"
        echo.>> "%2\example.md"
        echo.>> "%2\example.md"
        echo ^<!--more--^>>> "%2\example.md"
        exit 0
    ) ELSE (
    echo "ERROR: %2 not exist."
    )
) ELSE (
  echo "ERROR: Incorrect parameter list."
)

