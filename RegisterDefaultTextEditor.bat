@echo off

:: %License%


SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0
set ThisFileNameNoExt=%~n0
set Arg1=%1
set Arg2=%~2
set Arg3=%3

REM echo.DEBUG ThisFileName='%ThisFileName%'
REM echo.DEBUG ThisFileNameNoExt='%ThisFileNameNoExt%'
REM echo.DEBUG Arg1='%Arg1%'
REM echo.DEBUG Arg2='%Arg2%'
REM echo.DEBUG Arg3='%Arg3%'

if not defined Arg1 goto NoArgs
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
set /p Arg2="Enter program ID. Leave blank to use the file name [Ctrl+C to exit]: "
if %ErrorLevel% neq 0 set "Arg2=" & goto GetFilePathAndProgId
REM echo.DEBUG Arg2='%Arg2%'

REM Remove quotes
set Arg2NoQuotes=%Arg2:"=%
REM echo.DEBUG Arg2NoQuotes='%Arg2NoQuotes%'
if not defined Arg2NoQuotes goto UserEnterProgId

set Arg2NoSpaces=%Arg2NoQuotes: =%
REM echo.DEBUG Arg2NoSpaces='%Arg2NoSpaces%'
if not defined Arg2NoSpaces goto UserEnterProgId

goto GetFilePathAndProgId


:GetFilePathAndProgId
REM echo.DEBUG :GetFilePathAndProgId %*
for /f "tokens=*" %%a in ("%Arg1NoQuotes%") do (
    set "FilePath=%%~fa"
    set "DefaultProgId=%%~nxa"
    set "Extension=%%~xa"
    if not defined Extension set "DefaultProgId=%%~na.exe"
)

if not defined FilePath call :BadArg & goto ExitPause

REM echo.DEBUG FilePath='%FilePath%'
REM echo.DEBUG DefaultProgId='%DefaultProgId%'

call :GetProgId
if %ErrorLevel% neq 0 call :BadProgId & goto ExitPause
if not defined ProgId set "ProgId=%DefaultProgId%"
REM echo.DEBUG ProgId='%ProgId%'

if exist "%FilePath%" (2>nul pushd "%FilePath%" && (popd) || goto RegisterApp)
call :FileNotFound
goto ExitPause


:GetProgId
REM echo.DEBUG :GetProgId %*

if not defined Arg2NoQuotes exit /b 0
call :Trim ProgId %Arg2NoQuotes%
REM echo.DEBUG ProgId='%ProgId%'

if not defined ProgId exit /b 0

for /f "tokens=*" %%a in ("%ProgId%") do (
    set "TempProgId=%%~nxa"
    REM echo.DEBUG TempProgId='!TempProgId!'
    if /i "!TempProgId!" == "!ProgId!" (set "TempProgId=%%~na") else (set "TempProgId=")
    if defined TempProgId set "Extension=%%~xa"
    if not defined Extension set "Extension=.exe"
    set "ProgId=!TempProgId!!Extension!"
    REM echo.DEBUG Extension='!Extension!'
    REM echo.DEBUG TempProgId='!TempProgId!'
)

REM echo.DEBUG ProgId='!ProgId!'
if "!ProgId!" == ".exe" set "ProgId=" & exit /b 1
call :Trim ProgId %ProgId%
exit /b 0


:RegisterApp
REM echo.DEBUG :RegisterApp %*
REM echo.DEBUG FilePath='%FilePath%'
REM echo.DEBUG ProgId='%ProgId%'

set RegKeyHkcuClasses=HKEY_CURRENT_USER\Software\Classes
set RegKeyAppPaths=HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\%ProgId%
set ExitCode=0

REM Register the text editor as an application for the "edit" verb.
set RegKey=%RegKeyHkcuClasses%\Applications\%ProgId%\shell\edit\command
reg add "%RegKey%" /ve /d "\"%FilePath%\" \"%%1\"" /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: '!RegKey!' & set "ExitCode=1"

REM Register the text editor as an application for the "open" verb.
set RegKey=%RegKeyHkcuClasses%\Applications\%ProgId%\shell\open\command
reg add "%RegKey%" /ve /d "\"%FilePath%\" \"%%1\"" /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: '!RegKey!' & set "ExitCode=1"

REM Register the text editor to the "Open with" list for files with no extension.
set RegKey=%RegKeyHkcuClasses%\*\OpenWithList\%ProgId%
reg add "%RegKey%" /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: '!RegKey!' & set "ExitCode=1"

REM Register the text editor to the "Open with" list for text files.
set RegKey=%RegKeyHkcuClasses%\SystemFileAssociations\text\OpenWithList\%ProgId%
reg add "%RegKey%" /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: '!RegKey!' & set "ExitCode=1"

REM Register the text editor as the default for the "edit" verb.
set RegKey=%RegKeyHkcuClasses%\SystemFileAssociations\text\shell\edit\command
reg add "%RegKey%" /ve /d "\"%FilePath%\" \"%%1\"" /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: '!RegKey!' & set "ExitCode=1"

REM Register the text editor as the default for the "open" verb.
set RegKey=%RegKeyHkcuClasses%\SystemFileAssociations\text\shell\open\command
reg add "%RegKey%" /ve /d "\"%FilePath%\" \"%%1\"" /f >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: '!RegKey!' & set "ExitCode=1"

REM Register the the app path of text editor.
set RegKey=%RegKeyAppPaths%
reg add "%RegKey%" /f /ve /d "%FilePath%" >nul
if %ErrorLevel% neq 0 echo>&2.Registry key: "!RegKey!" & set "ExitCode=1"

echo.Registered default text editor: "%FilePath%" using ProgID: "%ProgId%"

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


:HelpArg
REM echo.DEBUG :HelpArg %*


:Usage
call :PrintHeader
echo.Usage:
echo.  %ThisFileNameNoExt% [FilePath [ProgID[.exe]]]
echo.
echo.    FilePath     Path to the text editor.
echo.                 If excluded, user is prompted for the path and program ID.
echo.    ProgID       The internal name used to register the text editor, optionally
echo.                 followed by ".exe". If excluded, the file's name will be used.
echo.                 If no extension is entered, ".exe" is appended.
echo.
echo.Examples:
echo.  C:\^>%ThisFileNameNoExt%
echo.    Prompts for the path to the text editor.
echo.
echo.  C:\^>%ThisFileNameNoExt% "C:\apps\NotePad++\notepad++.exe"
echo.    Registers Notepad++ as a text editor using the ProgID "notepad++.exe".
echo.
echo.  C:\^>%FileName% "C:\apps\NotePad++\notepad++.exe" npp
echo.    Registers Notepad++ as a text editor using the ProgID "npp.exe".

goto Exit


:PrintHeader
echo.
echo.Description:
echo.  Registers the specified program as the default Edit handler for text files
echo.  and adds it to the "Open with" list for text files and for files with no
echo.  extension.
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
