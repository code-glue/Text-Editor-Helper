@echo off

SetLocal EnableDelayedExpansion

set ExitCode=1
set ThisFileName=%~nx0
set ThisFileNameNoExt=%~n0
set FileExtensionsPath=%~dp0TextFileExtensions.txt
set RegisterTextFileExtension=%~dp0RegisterTextFileExt.bat
set Arg1=%1

REM echo.DEBUG ThisFileName='%ThisFileName%'
REM echo.DEBUG ThisFileNameNoExt='%ThisFileNameNoExt%'
REM echo.DEBUG FileExtensionsPath='%FileExtensionsPath%'
REM echo.DEBUG RegisterTextFileExtension='%RegisterTextFileExtension%'
REM echo.DEBUG Arg1='%Arg1%'

if defined Arg1 goto HelpArg

REM Make sure the list of text file extensions "TextFileExtensions.txt" sits parallel to this script.
if exist "%FileExtensionsPath%" (2>nul pushd "%FileExtensionsPath%" && (popd) || goto RegisterTextExtensions)
echo>&2.File not found: "%FileExtensionsPath%"
goto ExitPause


:RegisterTextExtensions
REM echo.DEBUG :RegisterTextExtensions %*
set ExitCode=0

call :CheckAdmin
if %ErrorLevel% equ 0 (set "IsAdmin=1") else (set "IsAdmin=0")
REM echo.DEBUG :IsAdmin=%IsAdmin%


echo.
echo.Registering the following file extensions as text files:
echo.
for /f "usebackq eol=' tokens=*" %%a in ("%FileExtensionsPath%") do (
    <nul set /p =.%%a 
    call "%RegisterTextFileExtension%" "%%a" >nul
    if !ErrorLevel! neq 0 (
        set ExitCode=1
        if !IsAdmin! equ 0 goto ExitPause
    )
)
echo.
echo.

goto ExitPause


:HelpArg
REM echo.DEBUG :HelpArg %*


:Usage
echo.
echo.Description:
echo.  Registers all of the file extensions below as text files. This adds the "Edit"
echo.  option to the file's context menu and adds the list of all registered text
echo.  editors to the "Open with" menu.
echo.
echo.File extensions:
for /f "usebackq eol=' tokens=*" %%a in ("%FileExtensionsPath%") do (
    set AllExts=!AllExts!.%%a 
)

echo.  %AllExts%
echo.
echo.Usage:
echo.  %ThisFileNameNoExt% ^<No Parameters^>
echo.

goto Exit


:CheckAdmin
net session >nul 2>&1
exit /b %ErrorLevel%


:ExitPause
REM Pause if this script was not run from a command line.
set CmdCmdLineNoQuotes=!CmdCmdLine:"=!
set CmdCmdLineNoFileName=!CmdCmdLineNoQuotes:%ThisFileName%=!
if "!CmdCmdLineNoQuotes!" == "!CmdCmdLineNoFileName!" goto Exit
REM echo.DEBUG :ExitPause ExitCode=%ExitCode%
echo.
pause


:Exit
REM echo.DEBUG :Exit ExitCode=%ExitCode%
@%ComSpec% /c exit %ExitCode% >nul
