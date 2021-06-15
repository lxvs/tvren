@echo off
@setlocal
@REM TV Shows Rename Script
@REM https://lxvs.net/tvren
@REM 2021-01-16
set ext=rmvb
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
