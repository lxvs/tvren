@echo off
@setlocal EnableDelayedExpansion
chcp 65001 >nul
set dryrun=
set dh=
set dt=
set pfx=
set sfx=
set fl=
set sf=
set st=
set xf=
set xt=
set pattern=
set "flagd=-d"
set "flagh=-h"
set ext=
set version=0.4.0
set update=2023-08-27
set website=https://github.com/lxvs/tvren
:parse_args
if %1. == . goto end_parse_args
if "%~1" == "/?" goto help
set "sw=%~1"
shift
if "%sw:~0,1%" NEQ "-" if "%sw:~0,1%" NEQ "/" (
    if not defined pattern (
        set "pattern=%sw%"
    ) else (
        >&2 echo error: invalid argument: %sw%
        exit /b 1
    )
    goto parse_args
)
set "sw=%sw:~1%"
if "%sw%" == "?" goto help
if /i "%sw%" == "h" goto help
if /i "%sw%" == "help" goto help
if /i "%sw%" == "usage" goto help
if /i "%sw%" == "v" goto show_version
if /i "%sw%" == "version" goto show_version
if /i "%sw%" == "n" (
    set dryrun=1
    goto parse_args
)
if /i "%sw%" == "dh" (
    set "dh=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "dehead" (
    set "dh=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "dt" (
    set "dt=%~1"
    shift
    goto parse_args
)
if /i "%sw%" == "detail" (
    set "dt=%~1"
    shift
    goto parse_args
)
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
if /i "%sw%" == "d" (
    set "flagd=d"
    goto parse_args
)
if /i "%sw%" == "nod" (
    set "flagd=-d"
    goto parse_args
)
if /i "%sw%" == "hidden" (
    set "flagh=h"
    goto parse_args
)
if /i "%sw%" == "nohidden" (
    set "flagh=-h"
    goto parse_args
)
if /i "%sw%" == "ext" (
    set ext=1
    goto parse_args
)
if /i "%sw%" == "noext" (
    set ext=0
    goto parse_args
)
if /i "%sw%" == "-" (goto double_dash)
>&2 echo error: invalid switch "%sw%"
exit /b 1
:double_dash
if %1. == . (goto end_parse_args)
if %2. NEQ . (
    >&2 echo error: too many arguments
    exit /b 1
)
if defined pattern (
    >&2 echo error: invalid argument: %~1
    exit /b 1
)
set "pattern=%~1"
:end_parse_args

if not defined ext if "%flagd%" == "d" set ext=1

if not defined dh if not defined dt if not defined pfx if not defined sfx if not defined sf if not defined xt goto noop

if defined ext (
    if defined xf goto ext_and_xf
    goto end_xf
)

if not defined xf goto end_xf
if "%xf:~0,1%" NEQ "." set "xf=.%xf%"
:end_xf
if not defined xt goto end_xt
if "%xt:~0,1%" NEQ "." set "xt=.%xt%"
:end_xt

for /f "tokens=*" %%i in ('dir /b /a-s%flagd%%flagh% /on "%pattern%"') do (
    if defined ext (call:DoIt "%%~nxi") else (call:DoIt "%%~ni" "%%~xi")
)
exit /b

:DoIt
set "org=%~1%~2"
set "fn=%~1"
if "%fn%" == "" exit /b 1
set "ex=%~2"

if not defined dh (goto skip_dh)
set "fn=!fn:*%dh%=!"
:skip_dh

if not defined dt (goto skip_dt)
set "dt_head=!fn:*%dt%=!"
if "%dt_head%" == "%fn%" (goto skip_dt)
if "%dt_head%" == "" (goto skip_dt)
set "fn=!fn:%dt_head%=!"
:skip_dt

if not defined sf goto skip_sf
if "%sf:~0,1%" NEQ "~" (
    set "fn=!fn:%sf%=%st%!"
) else (
    >&2 echo warning: Cannot substitute from a string starting with "~" due to the Windows batch script limitions.
)
:skip_sf

if not defined xt goto skip_xt
if not defined xf (
    set "ex=%xt%"
) else if "%ex%" == "%xf%" (
    set "ex=%xt%"
)
:skip_xt

if defined pfx set "fn=%pfx%%fn%"
if defined sfx set "fn=%fn%%sfx%"
if "%org%" == "%fn%%ex%" exit /b
if /i "%org%" == "%fn%%ex%" (goto case_only)
if exist "%fn%%ex%" (
    >&2 echo !org!  --^>  !fn!%ex%  : error: target file already exists
    exit /b 1
)
if defined dryrun (
    echo !org!  --^>  !fn!%ex%  : dry run
    exit /b 0
)
set error_msg=
for /f "delims=" %%i in ('ren "%org%" "%fn%%ex%" 2^>^&1 1^>nul') do (
    set "error_msg=!error_msg!%%~i "
)
if "%error_msg%" == "" (
    echo !org!  --^>  !fn!%ex%
) else (
    >&2 echo !org!  --^>  !fn!%ex%  : error: %error_msg%
)
exit /b
:case_only
if defined dryrun (
    echo !org!  --^>  !fn!%ex%  : dry run
    exit /b 0
)
set rand=%RANDOM%
ren "%org%" "%org%.%rand%.tvren.tmp" 2>nul || (
    >&2 echo !org!  --^>  !fn!%ex%  : error: `%org%.%rand%.tvren.tmp' exists
    exit /b 1
)
set error_msg=
for /f "delims=" %%i in ('ren "%org%.%rand%.tvren.tmp" "%fn%%ex%" 2^>^&1 1^>nul') do (
    set "error_msg=!error_msg!%%~i "
)
if "%error_msg%" == "" (
    echo !org!  --^>  !fn!%ex%
) else (
    ren "%org%.%rand%.tvren.tmp" "%org%" 2>nul
    >&2 echo !org!  --^>  !fn!%ex%  : error: %error_msg%
)
exit /b

:help
@call:show_version
@echo;
@echo usage: tvren [FLAGS ...]
@echo              [-dh DEHEAD] [-dt DETAIL]
@echo              [-p PREFIX] [-s SUFFIX]
@echo              [-sf SFROM [-st STO] ]
@echo              [ [-xf XFROM] -xt XTO]
@echo;
@echo It will execute some operations in the following sequence:
@echo;
@echo  - Remove the part before, and including, the first occurrence of DEHEAD in filenames in current folder
@echo  - Remove the part after, and NOT including, the first occurrence of DETAIL in filenames in current folder
@echo  - Subtitute SFROM with STO in filenames ^(not including file extension^) in current folder
@echo  - If both XFROM and XTO are specified, change extensions of files that with extension XFROM in current folder
@echo    to XTO
@echo  - If XTO is specified without XFROM, change extensions of all files that has an extension in current folder to
@echo    XTO
@echo;
@echo flags:
@echo     -n          dry run
@echo     -d          operate against directories instead of files; this implies -ext
@echo     -hidden     operate against hidden files or directories only
@echo     -ext        treat extension name as part of file name
@echo;
@echo Prefix "no" to a flag means negate. For example, use -d and -noext together to operate against directories only, but
@echo treat directories as having extension names.
exit /b

:noop
@echo no operation
exit /b

:ext_and_xf
>&2 echo error: -xf cannot be used with -ext
exit /b 1

:show_version
@echo tvren %version% ^(%update%^)
@echo %website%
exit /b
