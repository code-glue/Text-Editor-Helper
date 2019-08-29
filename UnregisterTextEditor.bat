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
if defined Arg1NoQuotes set "Arg1NoSpaces=%Arg1NoQuotes: =%"
if not defined Arg1NoSpaces call :BadArg & goto ExitPause
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
if "!Arg1NoSpaces!" == "/?" goto HelpArg

goto GetProgId


:NoArgs
REM echo.DEBUG :NoArgs %*
call :PrintHeader


:UserEnterProgId
REM Prompt the user for the program ID. If empty, reset and try again.
REM echo.DEBUG :UserEnterProgId %*
call :SetErrorLevel 0
set /p Arg1="Enter program ID [Ctrl+C to exit]: "
if %ErrorLevel% neq 0 set "Arg1=" & goto UserEnterProgId

REM echo.DEBUG Arg1='%Arg1%'
if not defined Arg1 goto UserEnterProgId

set Arg1NoQuotes=%Arg1:"=%
REM echo.DEBUG Arg1NoQuotes='%Arg1NoQuotes%'
if not defined Arg1NoQuotes goto UserEnterProgId

set Arg1NoSpaces=%Arg1NoQuotes: =%
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
if not defined Arg1NoSpaces goto UserEnterProgId
if "!Arg1NoSpaces!" == "/?" call :BadArg & goto ExitPause

goto GetProgId


:GetProgId
REM echo.DEBUG :GetProgId %*

call :Trim ProgId %Arg1NoQuotes%
REM echo.DEBUG ProgId='%ProgId%'

if not defined ProgId call ::BadArg & goto ExitPause

for /f "tokens=*" %%a in ("%ProgId%") do (
    REM echo.DEBUG nxa="%%~nxa"
    if /i not "%%~nxa" == "!ProgId!" call :BadArg & goto ExitPause
    set "Extension=%%~xa"
    REM echo.DEBUG Extension='!Extension!'
    if not defined Extension set "Extension=.exe"
    set "ProgId=%%~na!Extension!"
    REM echo.DEBUG Extension='!Extension!'
    REM echo.DEBUG ProgId='!ProgId!'
)
if "!ProgId!" == ".exe" call :BadArg & goto ExitPause

call :Trim ProgId %ProgId%

goto UnregisterApp


:UnregisterApp
REM echo.DEBUG :UnregisterApp %*
REM echo.DEBUG ProgId='%ProgId%'

set RegKeyHkcuClasses=HKEY_CURRENT_USER\Software\Classes
set RegKeyAppPaths=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\%ProgId%
set ExitCode=0
set IsRegistered=0

REM Unregister the text editor as an application using its program ID.
call :SetErrorLevel 0
set RegKey=%RegKeyHkcuClasses%\Applications\%ProgId%
reg query "%RegKey%" /ve >nul 2>&1
if %ErrorLevel% equ 0 (
    set "IsRegistered=1"
    REM echo.DEBUG Deleting "!RegKey!"
    reg delete "!RegKey!" /f >nul
    if !ErrorLevel! neq 0 echo>&2.Registry key: "!RegKey!" & set "ExitCode=1"
)

REM Unregister the text editor from the "Open with" list for files with no extension.
call :SetErrorLevel 0
set RegKey=%RegKeyHkcuClasses%\*\OpenWithList\%ProgId%
reg query "%RegKey%" /ve >nul 2>&1
if %ErrorLevel% equ 0 (
    set "IsRegistered=1"
    REM echo.DEBUG Deleting "!RegKey!"
    reg delete "!RegKey!" /f >nul
    if !ErrorLevel! neq 0 echo>&2.Registry key: "!RegKey!" & set "ExitCode=1"
)

REM Unregister the text editor from the "Open with" list for text files.
call :SetErrorLevel 0
set RegKey=%RegKeyHkcuClasses%\SystemFileAssociations\text\OpenWithList\%ProgId%
reg query "%RegKey%" /ve >nul 2>&1
if %ErrorLevel% equ 0 (
    set "IsRegistered=1"
    REM echo.DEBUG Deleting "!RegKey!"
    reg delete "!RegKey!" /f >nul
    if !ErrorLevel! neq 0 echo>&2.Registry key: "!RegKey!" & set "ExitCode=1"
)

REM Unregister the the app path of text editor.
call :SetErrorLevel 0
set RegKey=%RegKeyAppPaths%
reg query "%RegKey%" /ve >nul 2>&1
if %ErrorLevel% equ 0 (
    set "IsRegistered=1"
    REM echo.DEBUG Deleting "!RegKey!"
    reg delete "!RegKey!" /f >nul
    if !ErrorLevel! neq 0 echo>&2.Registry key: "!RegKey!" & set "ExitCode=1"
)

if %IsRegistered% equ 0 echo.ProgID "%ProgId%" is not a registered application. & goto ExitPause
echo.Unregistered application with ProgID: "%ProgId%"

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
echo>&2.Invalid program ID: "%Arg1NoQuotes%"
exit /b 1


:HelpArg
REM echo.DEBUG :HelpArg %*


:Usage
call :PrintHeader
echo.Usage:
echo.  %ThisFileNameNoExt% [ProgId[.exe]]
echo.
echo.    ProgId    Program ID of the text editor (usually its file name), optionally
echo.              followed by ".exe".
echo.              If no extension is entered, ".exe" is appended.
echo.              If excluded, user is prompted for the program ID.
echo.
echo.Examples:
echo.  C:\^>%ThisFileNameNoExt%
echo.    Prompts for the program ID of the text editor.
echo.
echo.  C:\^>%ThisFileNameNoExt% "notepad++.exe"
echo.    Unregisters Notepad++ as a text editor using ProgID "notepad++.exe".
echo.
echo.  C:\^>%ThisFileNameNoExt% npp
echo.    Unregisters Notepad++ as a text editor using ProgID "npp.exe".

goto Exit


:PrintHeader
echo.
echo.Description:
echo.  Unregisters a text editor application using the specified program ID.
echo.  The program ID is usually the text editor's file name.
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
