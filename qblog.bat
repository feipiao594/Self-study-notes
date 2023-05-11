@echo off
chcp 65001
setlocal enabledelayedexpansion

set "blogtarget=C:\daily\Blog\source"
set "source=C:\daily\Self-study-notes"

IF "%1"=="-s" (
    call:func
    cd "%blogtarget%\.."
    npx hexo clean
    cd "%blogtarget%\.."
    npx hexo generate
    cd "%blogtarget%\.."
    npx hexo server
) ELSE IF "%1"=="-d" (
    call:func
    cd "%blogtarget%\.."
    npx hexo clean
    cd "%blogtarget%\.."
    npx hexo generate
    cd "%blogtarget%\.."
    npx hexo deploy
) ELSE IF "%1"=="-p" (
    git add *
    git commit -m "%date:~3% %time:~0,5% Daily reading experience" 
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
        echo ^<^^!--more--^>>> "%2\example.md"
        exit 0
    ) ELSE (
    echo "ERROR: %2 not exist."
    )
) ELSE (
  echo "ERROR: Incorrect parameter list."
)

EXIT /B 0


:func
set index=0
set flag=0
for /f "tokens=* delims=" %%a in ('dir /b /a-d "%blogtarget%\_posts\*.md"') do (
    set "filesA[!index!]=%%a"
    set /a index+=1
)

for /r "%source%" %%a in (*.md) do (
    set "filename=%%~nxa"
    set "flag=0"
    for /l %%i in (0,1,%index%-1) do (
        if defined filesA[%%i] (
            if /i "!filesA[%%i]!"=="!filename!" (
                set "filesA[%%i]=NOTE:NOTHING"
                set "flag=1"
            )
        )
    )
    echo %%a| findstr "README.md" >nul && (
        echo %%a is README.md,skip.
    ) || (
        if "!flag!"=="1" (
            fc "%%a" "%blogtarget%\_posts\!filename!" >nul && echo %%~nxa same with target,skip ||(
                    copy "%%a" "%blogtarget%\_posts\"
                    echo %%a copy to %blogtarget%\_posts\
                )
        ) else (
            copy "%%a" "%blogtarget%\_posts\"
            echo %%a copy to %blogtarget%\_posts\
        )
    )
)

for /l %%i in (0,1,%index%-1) do (
    if defined filesA[%%i] (
        if "!filesA[%%i]!" neq "NOTE:NOTHING" (
            echo %blogtarget%\_posts\!filesA[%%i]! deleted
            del %blogtarget%\_posts\!filesA[%%i]!
        )
    )
)

set index=0
for /f "tokens=* delims=" %%a in ('dir /b /a-d "%blogtarget%\images\*.*"') do (
    set "filesB[!index!]=%%a"
    set /a index+=1
)

for /r "%source%\images" %%a in (*.*) do (
    set "filename=%%~nxa"
    set "flag=0"
    for /l %%i in (0,1,%index%-1) do (
        if defined filesB[%%i] (
            if /i "!filesB[%%i]!"=="!filename!" (
                set "filesB[%%i]=NOTE:NOTHING"
                set "flag=1"
            )
        )
    )
    if "!flag!"=="1" (
        fc "%%a" "%blogtarget%\images\!filename!" >nul && echo %%~nxa same with target,skip ||(
                copy "%%a" "%blogtarget%\images\"
                echo %%a copy to %blogtarget%\images\
            )
    ) else (
        copy "%%a" "%blogtarget%\images\"
        echo %%a copy to %blogtarget%\images\
    )
)

for /l %%i in (0,1,%index%-1) do (
    if defined filesB[%%i] (
        if "!filesB[%%i]!" neq "NOTE:NOTHING" (
            echo %blogtarget%\images\!filesB[%%i]! deleted
            del %blogtarget%\images\!filesB[%%i]!
        )
    )
)
goto:eof