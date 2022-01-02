@echo off
@setlocal EnableDelayedExpansion
chcp 65001 >nul
set dryrun=
set pfx=
set sfx=
set fl=
set sf=
set st=
set xf=
set xt=
set pattern=
:parse_args
if "%~1" == "" goto end_parse_args
if "%~1" == "/?" goto help
set "sw=%~1"
shift
if "%sw:~0,1%" NEQ "-" (
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
if /i "%sw%" == "n" (
    set dryrun=1
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
>&2 echo error: invalid switch "%sw%"
exit /b 1
:end_parse_args

if not defined pfx if not defined sfx if not defined sf if not defined xt (
    >&2 echo no operation
    exit /b
)

if not defined xf goto end_xf
if "%xf:~0,1%" NEQ "." set "xf=.%xf%"
:end_xf
if not defined xt goto end_xt
if "%xt:~0,1%" NEQ "." set "xt=.%xt%"
:end_xt

for /f "tokens=*" %%i in ('dir /b /a-d-h-s /on %pattern%') do (
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
        if "%%~i" NEQ "!fn!!ex!" if exist "!fn!!ex!" (
            >&2 echo error: !fn!!ex! already exists
        ) else if defined dryrun (
            @echo %%~i  ++^>  !fn!!ex!
        ) else (
            @echo %%~i  --^>  !fn!!ex!
            ren "%%~i" "!fn!!ex!"
        )
    )
)
exit /b

:help
@echo usage: tvren [-p {prefix}] [-s {suffix}] [-sf {sfrom}] [-st {sto}] [ [-xf {xfrom}] -xt {xto}]
@echo;
@echo  - Subtitute {sfrom} with {sto} in filenames ^(not including file extension^) in current folder
@echo  - If both {xfrom} and {xto} are specified, change extensions of files that with extension {xfrom} in current folder
@echo    to {xto}
@echo  - If {xto} is specified without {xfrom}, change extensions of all files that has an extension in current folder to
@echo    {xto}
exit /b
