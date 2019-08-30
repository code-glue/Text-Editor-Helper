@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0
set ThisFileNameNoExt=%~n0
set ProgIdsPath=%~dp0ProgIdsWithEditHandler.txt
set RegisterEditHandler=%~dp0RegisterExplicitEditHandler.bat
set Arg1=%~1
set Arg2=%2

REM echo.DEBUG ThisFileName='%ThisFileName%'
REM echo.DEBUG ThisFileNameNoExt='%ThisFileNameNoExt%'
REM echo.DEBUG ProgIdsPath='%ProgIdsPath%'
REM echo.DEBUG RegisterEditHandler='%RegisterEditHandler%'
REM echo.DEBUG Arg1='%Arg1%'
REM echo.DEBUG Arg2='%Arg2%'

if not defined Arg1 goto NoArgs
if "!Arg1!" == "/?" goto HelpArg
if defined Arg2 goto TooManyArgs

REM Make sure the progId list "ProgIdsWithEditHandler.txt" sits parallel to this script.
if exist "%ProgIdsPath%" (2>nul pushd "%ProgIdsPath%" && (popd) || goto GetFilePath)
echo>&2.File not found: "%ProgIdsPath%"
goto ExitPause


:NoArgs
REM echo.DEBUG :NoArgs %*
call :PrintHeader


:UserEnterFilePath
REM Prompt the user for the file path. If empty, reset and try again.
REM echo.DEBUG :UserEnterFilePath %*
call :SetErrorLevel 0
set /p Arg1="Enter path to Edit handler [Ctrl+C to exit]: "
if %ErrorLevel% neq 0 set "Arg1=" & goto UserEnterFilePath

REM echo.DEBUG Arg1='%Arg1%'
if not defined Arg1 goto UserEnterFilePath

set Arg1NoSpaces=%Arg1: =%
REM echo.DEBUG Arg1NoSpaces='%Arg1NoSpaces%'
if not defined Arg1NoSpaces goto UserEnterFilePath

goto GetFilePath


:GetFilePath
REM echo.DEBUG :GetFilePath %*

for /f "tokens=*" %%a in ("%Arg1%") do set "FilePath=%%~fa"
if not defined FilePath call :BadArg & goto ExitPause
REM echo.DEBUG FilePath='%FilePath%'

if exist "%FilePath%" (2>nul pushd "%FilePath%" && (popd) || goto RegisterApp)
call :FileNotFound
goto ExitPause


:RegisterApp
REM echo.DEBUG :RegisterApp %*
REM echo.DEBUG FilePath='%FilePath%'
set ExitCode=0
call :SetErrorLevel 0

echo.
echo.Registering "%FilePath%" as the Edit handler for the following program IDs:
echo.
for /f "usebackq eol=' tokens=*" %%a in ("%ProgIdsPath%") do (
    <nul set /p =%%a 
    call "%RegisterEditHandler%" "%FilePath%" "%%a" >nul
    if !ErrorLevel! neq 0 set "ExitCode=1"
)
echo.
goto ExitPause


:SetErrorLevel
REM echo.DEBUG :SetErrorLevel %*
exit /b %1


:TooManyArgs
REM echo.DEBUG :TooManyArgs %*
echo>&2.Too many arguments.
goto :Usage


:BadArg
REM echo.DEBUG :BadArg %*
echo>&2.Invalid file path: "%Arg1%"
exit /b 1


:FileNotFound
REM echo.DEBUG :FileNotFound %*
echo>&2.File not found: "%FilePath%"
exit /b 1


:HelpArg
REM echo.DEBUG :HelpArg %*


:Usage
echo.
echo.Description:
echo.  Registers the specified program as the "Edit" handler for all the program IDS below.
echo.
echo.Program IDs:
for /f "usebackq eol=' tokens=*" %%a in ("%ProgIdsPath%") do set "AllExts=!AllExts!%%a "

echo.  %AllExts%
echo.
echo.Usage:
echo.  %ThisFileNameNoExt% [FilePath]
echo.
echo.    FilePath     Path to the application.
echo.                 If excluded, user is prompted for the application path.
echo.
echo.Examples:
echo.  C:\^>%ThisFileNameNoExt%
echo.    Prompts for the application path.
echo.
echo.  C:\^>%ThisFileNameNoExt% "C:\apps\NotePad++\notepad++.exe"
echo.    Registers Notepad++ as the "Edit" handler for all the listed program IDs.

goto Exit


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
