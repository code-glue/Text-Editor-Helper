@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0
set ThisFileNameNoExt=%~n0
set Arg1=%1
set Arg2=%2

REM echo.DEBUG ThisFileName='%ThisFileName%'
REM echo.DEBUG ThisFileNameNoExt='%ThisFileNameNoExt%'
REM echo.DEBUG Arg1='%Arg1%'
REM echo.DEBUG Arg2='%Arg2%'

if not defined Arg1 goto NoArgs
if defined Arg2 goto TooManyArgs

set Arg1NoQuotes=%Arg1:"=%
REM echo.DEBUG Arg1NoQuotes='%Arg1NoQuotes%'

if not defined Arg1NoQuotes call :BadArg & goto ExitPause
set Arg1NoSpaces=%Arg1NoQuotes: =%
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
if "!Arg1NoSpaces!" == "/?" goto HelpArg

set Extension=.%Arg1NoQuotes%
REM echo.DEBUG Extension='%Extension%'

goto GetExtension


:NoArgs
REM echo.DEBUG :NoArgs %*
call :PrintHeader


:UserEnterExtension
REM Prompt the user for the file extension. On error, reset and try again.
REM echo.DEBUG :UserEnterExtension %*
call :SetErrorLevel 0
set /p Arg1="Enter file extension [Ctrl+C to exit]: "
if %ErrorLevel% neq 0 set "Arg1=" & goto UserEnterExtension

REM echo.DEBUG Arg1='%Arg1%'
if not defined Arg1 goto UserEnterExtension

set Arg1NoQuotes=%Arg1:"=%
REM echo.DEBUG Arg1NoQuotes='%Arg1NoQuotes%'
if not defined Arg1NoQuotes goto UserEnterExtension

set Arg1NoSpaces=%Arg1NoQuotes: =%
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
if not defined Arg1NoSpaces goto UserEnterExtension
if "!Arg1NoSpaces!" == "/?" call :BadArg & goto ExitPause

call :Trim Arg1Trimmed %Arg1%
REM echo.DEBUG Arg1Trimmed='%Arg1Trimmed%'

set Arg1NoQuotes=%Arg1Trimmed:"=%
REM echo.DEBUG Arg1NoQuotes='%Arg1NoQuotes%'
if not defined Arg1NoQuotes call :BadArg & goto ExitPause

set Extension=.%Arg1NoQuotes%
REM echo.DEBUG Extension='%Extension%'

goto GetExtension


:GetExtension
REM echo.DEBUG :GetExtension %*
REM echo.DEBUG Extension='%Extension%'

for /f "tokens=*" %%a in ("!Extension!") do (
    set "Extension=%%~xa"
)

REM echo.DEBUG Extension='%Extension%'

if not defined Extension call :BadArg & goto ExitPause
if "!Extension!" == "." call :BadArg & goto ExitPause

goto RegisterTextExt


:RegisterTextExt
REM echo.DEBUG :RegisterTextExt %*
REM echo.DEBUG Extension='%Extension%'

set RegKeyHkcuClasses=HKEY_CURRENT_USER\Software\Classes

REM Register the extension as a text file.
set RegKey=%RegKeyHkcuClasses%\%Extension%
reg add "%RegKey%" /v "PerceivedType" /d "text" /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: '!RegKey!' & goto ExitPause
echo.Registered "%Extension%" as a text file extension.
set ExitCode=0

goto ExitPause


:Trim
REM Trims leading and trailing whitespace.
SetLocal EnableDelayedExpansion
REM echo.DEBUG :Trim %*
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do EndLocal & set %1=%%b
exit /b


:SetErrorLevel
REM echo.DEBUG :SetErrorLevel %*
exit /b %1


:TooManyArgs
REM echo.DEBUG :TooManyArgs %*
echo>&2.Too many arguments.
goto :Usage


:BadArg
REM echo.DEBUG :BadArg %*
echo>&2.Invalid extension: "%Arg1NoQuotes%"
exit /b 1


:HelpArg
REM echo.DEBUG :HelpArg %*


:Usage
call :PrintHeader
echo.Usage:
echo.  %ThisFileNameNoExt% [[.]Extension]
echo.
echo.    Extension    File extension to register, optionally prefixed by "."
echo.                 If excluded, user is prompted for the file extension.
echo.
echo.Examples:
echo.  C:\^>%ThisFileNameNoExt%
echo.    Prompts for the file extension.
echo.
echo.  C:\^>%ThisFileNameNoExt% sln
echo.    Registers the file extension ".sln" as a text file.
echo.
echo.  C:\^>%ThisFileNameNoExt% .sln
echo.    Registers the file extension ".sln" as a text file.

goto Exit


:PrintHeader
echo.
echo.Description:
echo.  Registers the specified file extension as a text file so it may be
echo.  easily opened in any text editor.
echo.
exit /b 1


:CheckAdmin
net session >nul 2>&1
exit /b %ErrorLevel%


:ExitPause
REM Pause if this script was not run from a command line.
REM echo.DEBUG :ExitPause ExitCode=%ExitCode%
if %ExitCode% neq 0 (
    call :CheckAdmin
    if !ErrorLevel! neq 0 echo>&2.Try running this script as Administrator.
)
set CmdCmdLineNoQuotes=!CmdCmdLine:"=!
set CmdCmdLineNoFileName=!CmdCmdLineNoQuotes:%ThisFileName%=!
if /i "!CmdCmdLineNoQuotes!" == "!CmdCmdLineNoFileName!" goto Exit
echo.
pause


:Exit
REM echo.DEBUG :Exit ExitCode=%ExitCode%
@%ComSpec% /c exit %ExitCode% >nul
