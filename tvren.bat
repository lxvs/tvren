@echo off
@setlocal EnableDelayedExpansion
chcp 65001 >nul
set pfx=
set sfx=
set ext=
set fl=
set sf=
set st=
set xf=
set xt=
:parse_args
if "%~1" == "" goto end_parse_args
set "sw=%~1"
shift
if "%sw:~0,1%" NEQ "/" (
    echo haha
    goto parse_args
)
set "sw=%sw:~1%"
if "%sw%" == "?" goto help
if /i "%sw%" == "h" goto help
if /i "%sw%" == "help" goto help
if /i "%sw%" == "usage" goto help
if /i "%sw%" == "p" (
    set "pfx=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "prefix" (
    set "pfx=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "s" (
    set "sfx=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "suffix" (
    set "sfx=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "ext" (
    set "ext=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "sf" (
    set "sf=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "st" (
    set "st=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "xf" (
    set "xf=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "xt" (
    set "xt=%~1"
    shift
    goto parse_args
)
>&2 echo error: invalid switch "%sw%"
>&2 call:help
exit /b 1
:end_parse_args

if not defined ext goto end_ext
if "%ext:~0,1%" NEQ "." set "ext=.%ext%"
set "ext=*%ext%"
:end_ext
if not defined xf goto end_xf
if "%xf:~0,1%" NEQ "." set "xf=.%xf%"
:end_xf
if not defined xt goto end_xt
if "%xt:~0,1%" NEQ "." set "xt=.%xt%"
:end_xt

for /f "tokens=*" %%i in ('dir /b /a-d /on %ext%') do (
    set "fn=%%~ni"
    set "ex=%%~xi"
    if "!fn!" NEQ "" if "!ex!" NEQ "" (
        if defined sf (
            if "%sf:~0,1%" NEQ "~" (
                set "fn=!fn:%sf%=%st%!"
            ) else (
                >&2 echo warning: Cannot substitute from a string starting with "~" due to the Windows batch script limitions.
            )
        )
        if defined xt (
            if not defined xf (
                set "ex=%xt%"
            ) else if "!ex!" == "%xf%" (
                set "ex=%xt%"
            )
        )
        if defined pfx set "fn=%pfx%!fn!"
        if defined sfx set "fn=!fn!%sfx%"
        ren "%%~i" "!fn!!ex!"
    )
)
exit /b

:help
