@echo off
@setlocal
@REM TV Shows Rename Script
@REM https://lxvs.net/tvren
@REM 2021-01-16

set pfx=
set sfx=
set ext=
set fl=
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
if /i "%sw%" == "prefix" (
    set "pfx=%~1"
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
>&2 echo error: invalid switch "%sw%"
>&2 call:help
exit /b 1
:end_parse_args

if "%ext%" == "" goto end_ext
if "%ext:~0,1%" NEQ "." set "ext=.%ext%"
set "ext=*%ext%"
:end_ext

for /f "tokens=*" %%i in ('dir /b /a-d /on %ext%') do (
    if defined pfx ren "%%~i" "%pfx%%%~i"
)
exit /b

set "oPre="
set "mPre=Yes.Minister."
set "oSuf="
set "mSuf="
set /a season=1
if "%1" NEQ "" set /a season=%1
set /a ep=0
if "%2" NEQ "" set /a ep=%2-1
if "%3" NEQ "" @echo on
:loop
set /a ep+=1
if %season% LSS 10 set strS=0%season%
if %ep% LSS 10 set strE=0%ep%
if exist "%oPre%S%strS%E%strE%%oSuf%.%ext%" (ren "%oPre%S%strS%E%strE%%oSuf%.%ext%" "%mPre%%season%x%strE%%mSuf%.%ext%") else (if %ep% GTR 1 (set /a season+=1) & (set /a ep=0) else goto END)
goto loop
:END
if "%3" NEQ "" pause

:help
