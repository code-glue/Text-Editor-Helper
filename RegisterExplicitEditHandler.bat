@echo off

:: %License%


SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0
set ThisFileNameNoExt=%~n0
set Arg1=%1
set Arg2=%2
set Arg3=%3

REM echo.DEBUG ThisFileName='%ThisFileName%'
REM echo.DEBUG ThisFileNameNoExt='%ThisFileNameNoExt%'
REM echo.DEBUG Arg1='%Arg1%'
REM echo.DEBUG Arg2='%Arg2%'
REM echo.DEBUG Arg3='%Arg3%'

if not defined Arg1 goto NoArgs
if not defined Arg2 goto OneArg
if defined Arg3 goto TooManyArgs

set Arg1NoQuotes=%Arg1:"=%
REM echo.DEBUG Arg1NoQuotes='%Arg1NoQuotes%'
if defined Arg1NoQuotes set "Arg1NoSpaces=%Arg1NoQuotes: =%"
if not defined Arg1NoSpaces call :BadArg & goto ExitPause
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
if "!Arg1NoSpaces!" == "/?" goto HelpArg

if not defined Arg2 goto GetFilePathAndProgId

set Arg2NoQuotes=%Arg2:"=%
REM echo.DEBUG Arg2NoQuotes='%Arg2NoQuotes%'
if defined Arg2NoQuotes set "Arg2NoSpaces=%Arg2NoQuotes: =%"
REM echo.DEBUG Arg2NoSpaces='%Arg2NoSpaces%'
if not defined Arg2NoSpaces set "Arg2NoQuotes="

goto GetFilePathAndProgId


:NoArgs
REM echo.DEBUG :NoArgs %*
call :PrintHeader


:UserEnterFilePath
REM Prompt the user for the file path. If empty, reset and try again.
REM echo.DEBUG :UserEnterFilePath %*
call :SetErrorLevel 0
set /p Arg1="Enter file path to .exe file [Ctrl+C to exit]: "
if %ErrorLevel% neq 0 set "Arg1=" & goto UserEnterFilePath

REM echo.DEBUG Arg1='%Arg1%'
if not defined Arg1 goto UserEnterFilePath

set Arg1NoQuotes=%Arg1:"=%
REM echo.DEBUG Arg1NoQuotes='%Arg1NoQuotes%'
if not defined Arg1NoQuotes goto UserEnterProgId

set Arg1NoSpaces=%Arg1NoQuotes: =%
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
if not defined Arg1NoSpaces goto UserEnterFilePath

goto UserEnterProgId


:UserEnterProgId
REM Prompt the user for the program ID. If empty, skip.
REM echo.DEBUG :UserEnterProgId %*
call :SetErrorLevel 0
set /p Arg2="Enter program ID. [Ctrl+C to exit]: "
if %ErrorLevel% neq 0 set "Arg2=" & goto UserEnterProgId

REM echo.DEBUG Arg2='%Arg2%'
if not defined Arg2 goto UserEnterProgId

REM Remove quotes
set Arg2NoQuotes=%Arg2:"=%
REM echo.DEBUG Arg2NoQuotes='%Arg2NoQuotes%'
if not defined Arg2NoQuotes goto UserEnterProgId

set Arg2NoSpaces=%Arg2NoQuotes: =%
REM echo.DEBUG Arg2NoSpaces='%Arg2NoSpaces%'
if not defined Arg2NoSpaces goto UserEnterProgId
if "!Arg2NoSpaces!" == "/?" call :BadArg & goto ExitPause

goto GetFilePathAndProgId


:GetFilePathAndProgId
REM echo.DEBUG :GetFilePathAndProgId %*
for /f "tokens=*" %%a in ("%Arg1NoQuotes%") do (
    set "FilePath=%%~fa"
)

if not defined FilePath call :BadArg & goto ExitPause

REM echo.DEBUG FilePath='%FilePath%'

call :Trim ProgId %Arg2NoQuotes%
REM echo.DEBUG ProgId='%ProgId%'
if not defined ProgId call :BadProgId & goto ExitPause

reg query "HKCR\%ProgId%" /ve >nul 2>&1
if %ErrorLevel% neq 0 call :ProgIdNotFound & goto ExitPause

if exist "%FilePath%" (2>nul pushd "%FilePath%" && (popd) || goto RegisterApp)
call :FileNotFound
goto ExitPause


:RegisterApp
REM echo.DEBUG :RegisterApp %*
REM echo.DEBUG FilePath='%FilePath%'
REM echo.DEBUG ProgId='%ProgId%'

REM Register the app as the handler for the "edit" verb.
set RegKey=HKEY_CURRENT_USER\Software\Classes\%ProgId%\shell\edit\command
reg add "%RegKey%" /ve /d "\"%FilePath%\" \"%%1\"" /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: '!RegKey!' & goto ExitPause

echo.Registered "%FilePath%" as the Edit handler for ProgID "%ProgId%"
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


:OneArg
REM echo.DEBUG :OneArg %*
echo>&2.Not enough arguments.
goto :Usage


:TooManyArgs
REM echo.DEBUG :TooManyArgs %*
echo>&2.Too many arguments.
goto :Usage


:BadArg
REM echo.DEBUG :BadArg %*
echo>&2.Invalid file path: "%Arg1NoQuotes%"
exit /b 1


:BadProgId
REM echo.DEBUG :BadProgId %*
echo>&2.Invalid program ID: "%Arg2NoQuotes%"
exit /b 1


:FileNotFound
REM echo.DEBUG :FileNotFound %*
echo>&2.File not found: "%FilePath%"
exit /b 1


:ProgIdNotFound
REM echo.DEBUG :ProgIdNotFound %*
echo>&2.ProgID not found: "%ProgId%"
exit /b 1


:HelpArg
REM echo.DEBUG :HelpArg %*


:Usage
call :PrintHeader
echo.Usage:
echo.  %ThisFileNameNoExt% [FilePath ProgID]
echo.
echo.    FilePath     Path to the application.
echo.                 If excluded, user is prompted for the path and program ID.
echo.    ProgID       The program ID whose Edit handler will be set.
echo.                 This must be an existing program ID.
echo.
echo.Examples:
echo.  C:\^>%ThisFileNameNoExt%
echo.    Prompts for the application path and the program ID.
echo.
echo.  C:\^>%ThisFileNameNoExt% "C:\apps\NotePad++\notepad++.exe" "batfile"
echo.    Registers Notepad++ as the Edit handler for the batfile program ID.
echo.    In most cases this represents .bat (batch) files.
echo.
echo.  C:\^>%FileName% "C:\apps\NotePad++\notepad++.exe" JSFile
echo.    Registers Notepad++ as the Edit handler for the JSFile program ID.
echo.    In most cases this represents .js (javascript) files.

goto Exit


:PrintHeader
echo.
echo.Description:
echo.  Registers the specified program as the Edit handler for the specified program ID.
echo.
exit /b 1


:ExitPause
REM Pause if this script was not run from a command line.
REM echo.DEBUG :ExitPause ExitCode=%ExitCode%
set CmdCmdLineNoQuotes=!CmdCmdLine:"=!
set CmdCmdLineNoFileName=!CmdCmdLineNoQuotes:%ThisFileName%=!
if /i "!CmdCmdLineNoQuotes!" == "!CmdCmdLineNoFileName!" goto Exit
echo.
pause


:Exit
REM echo.DEBUG :Exit ExitCode=%ExitCode%
@%ComSpec% /c exit %ExitCode% >nul
