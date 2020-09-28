@rem New Jupyter Project.bat
@rem
@rem Copyright (c) 2019 Bundesanstalt für Materialforschung und -prüfung (BAM).
@rem Subject to the MIT license.
@rem
@rem This file is part of 'Jupyter Git Scripts' ( <url> ).
@rem Easy setup of a GIT-enabled Jupyter notebook.
@rem
@rem Creates a blank Jupyter project in a folder the user is asked for.
@rem Sets up GIT with Jupyter notebook filtering (nbstripout) in that folder.
@rem Adds a copy of the notebook template 'New Project Notebook.ipynb' from config folder.
@rem Adds preconfigured GIT submodules as well.
@rem Expects a config file 'config\local.conf' relative to this scripts location
@rem with the following content (without leading 'rem '):

@rem NewProjectOrigin=https://<your GIT server>/%USERNAME%
@rem NewProjectSubMods=https://<your GIT server>/<some subdir>/jupyter_analysis_tools.git

@echo off
setlocal DisableDelayedExpansion EnableExtensions

set scriptpath=%~dp0
set scriptpath=%scriptpath:~0,-1%
pushd "%scriptpath%"

rem Parse the config file
set configpath=%scriptpath%\config\local.conf
rem echo "configpath: '%configpath%'"
if not exist "%configpath%" (
    echo Config file 'config\local.conf' does not exist, using defaults.
    cd config
    copy local.conf.default local.conf
)
for /f "usebackq eol=# delims=" %%x in ("%configpath%") do (
    rem echo "x: '%%x'"
    call set %%x
)

:: Check for the system requirements first
:: ---------------------------------------

:: Check for Git being installed, first check expected location
:: test some candidate directories, faster than searching ...
for /d %%I in ("C:\Program Files" ^
               "%LOCALAPPDATA%\Programs" ^
    ) do if exist %%~I\Git (
        set gitcmd=%%~I\Git\bin\git.exe
    )
if not exist "%gitcmd%" (
    echo [de]
    echo   Git wurde nicht gefunden! Bitte zunaechst 'Git for Windows' und
    echo   TortoiseGit installieren und dieses Skript erneut ausfuehren.
    echo [en]
    echo   Git was not found, please install 'Git for Windows' and TortoiseGit
    echo   first and run this script again.
    goto :end
)
call :getParentPath gitpath "%gitcmd%"
echo Git was FOUND:      '%gitcmd%'

python -V > nul 2>&1
if %errorlevel% NEQ 0 (
    echo   Python was not found, is not in PATH!
    echo   Please, first run 'Anaconda Update Script.bat' in %scriptpath%.
    goto :end
)

echo.
echo [de] Richte das Projektverzeichnis ein ...
echo [en] Setting up the project folder ...

:: asking the user for a project directory
set "psCommand="^
    Add-Type -AssemblyName System.Windows.Forms;^
    $browser = New-Object System.Windows.Forms.FolderBrowserDialog;^
    $browser.Description = '[de] Bei Bedarf bitte ein Jupyter-Projektverzeichnis waehlen.'+^
                            [Environment]::NewLine+^
                           '[en] If needed, please select a jupyter project folder.';^
    $browser.SelectedPath = '%workdir%';^
    if ($browser.ShowDialog() -eq 'OK') { Write-Host $browser.SelectedPath; } ""
:: for testing
:: echo %psCommand%
:: powershell -sta %psCommand%

for /f "usebackq delims=" %%I in (`powershell -sta %psCommand%`) do set "prjdir=%%I"
:: check for the user aborted the folder selection dialog
if "%prjdir%" == ""     exit /b
if not exist "%prjdir%" exit /b
echo     ^=^> '%prjdir%'

:: add Git to the PATH
set PATH=%gitpath%;%PATH%
cd /d "%prjdir%"
:: Check if there is a repository already, init it if not
set gitcfg=.git\config
if not exist "%prjdir%\%gitcfg%" (
    echo [de] Dieses Verzeichnis ist kein GIT-Repositorium, initialisiere es ...
    echo [en] This directory is not a GIT repository, initializing ...
    git init
    :: set user and name defaults
    setlocal EnableDelayedExpansion
    call :getFullnameEmail email fullname
    echo "Name ^& Email: '!fullname!' '!email!'"
    git config user.name "!fullname!"
    git config user.email "!email!"
    ::git config --list
    git commit -m "Initial Commit" --allow-empty
    :: configure default remote
    call :getDirname dirname "%prjdir%"
    call :replaceIllegalGitChars dirname
    call :toLower dirname
    if not "%NewProjectOrigin%"=="" (
        git remote add origin "%NewProjectOrigin%/!dirname!.git"
        git remote -v
    )
    setlocal DisableDelayedExpansion
)

:: install nbstripout in the current repo,
:: the current path should be a Git repo by now ...
::python -m nbstripout --install --attributes .gitattributes
::git config filter.nbstripout.clean "python -m nbstripout -t | dos2unix"
::git config diff.ipynb.textconv "sh -c 'python -m nbstripout -t \"$0\" | dos2unix'

:: basic config of GIT repo for Jupyter
echo .ipynb_checkpoints > .gitignore
echo __pycache__ >> .gitignore
::echo *.ipynb -text >> .gitattributes
::echo *.ASC   -text >> .gitattributes

:: add common submodule
for %%m in (%NewProjectSubMods%) do (
    if not "%%m"=="" (
        echo Adding submodule '%%m'
        git submodule add      %%m
    )
)
git submodule init
:: hide repository and meta data files
::attrib +h .gitattributes
attrib +h .gitignore
if exist .gitmodules ( attrib +h .gitmodules )
if exist .ipynb_checkpoints ( attrib +h .ipynb_checkpoints )
::git add ".gitignore" ".gitattributes"
git add ".gitignore"
:: add more files
call :getDirname dirname "%prjdir%"
set newnb=%prjdir%\%dirname%.ipynb
echo New NB: "%newnb%"
copy "%scriptpath%\config\New Project Notebook.ipynb" "%newnb%"
(
:: Replace the title in the notebook, keep unix line endings \n
setlocal enableDelayedExpansion
:: get user name and email for the notebook
for /F "tokens=*" %%I in ('git config user.name') do set "fullname=%%I"
for /F "tokens=*" %%I in ('git config user.email') do set "email=%%I"
set NL=^


python -c "import codecs; nb='' !NL!with codecs.open(r'%newnb%', 'r', encoding='utf-8') as fd: !NL!    nb = fd.read().replace(u'Some meaningful title', u'%dirname%').replace('&lt;full name&gt;', u'%fullname%').replace('&lt;email&gt;@&lt;provider&gt;.de', u'%email%') !NL!with codecs.open(r'%newnb%', 'w', encoding='utf-8') as fd: !NL!    fd.write(nb)"
setlocal DisableDelayedExpansion
)
:: copy some meta data place holders to the project folder
mkdir "%prjdir%\info"
copy "%scriptpath%\config\info\avatar-generic.png" "%prjdir%\info"
git add info *.ipynb
:: commit only if there are changes in the repo
git diff-index --quiet HEAD -- && goto :commitDone
git commit -m "Jupyter project created"

:commitDone
echo.
echo [de] Repositorium erfolgreich eingerichtet.
echo [en] Repository set up successfully.

start "" "%newnb%"

goto :end
:getFullnameEmail <emailVar> <fullnameVar>
:: Searching Active Directory for full name and Email address
:: returning 'Full Name <email@address>', useful for GIT config
(
    set "psCommand="^
        $objDomain = New-Object System.DirectoryServices.DirectoryEntry; ^
        $objSearcher = New-Object System.DirectoryServices.DirectorySearcher; ^
        $objSearcher.SearchRoot = $objDomain; ^
        $objSearcher.PageSize = 1000; ^
        $strFilter = '^(^&^(objectCategory=User^)^(CN=ibressle^)^)'; ^
        $objSearcher.Filter = $strFilter; ^
        $objSearcher.SearchScope = 'Subtree'; ^
        $colProplist = 'displayname', 'mail'; ^
        foreach ^($i in $colPropList^) { ^
            $objSearcher.PropertiesToLoad.Add^($i^) ^> $null; ^
        }; ^
        Try { $colResults = $objSearcher.FindAll^(^); } Catch { ^
            $sysuser = [System.Security.Principal.WindowsIdentity]::GetCurrent^(^).name.split^('\'^); ^
            [string]$out = [string]::Format^('{1}@{0},{1}', ^
                            $sysuser[0], $sysuser[1]^); ^
            Write-Host $out; ^
            return; ^
        }; ^
        foreach ^($objResult in $colResults^) { ^
            $dispname = $objResult.Properties.displayname.Split^(','^); ^
            [string]$out = [string]::join^(',', ^
                [string]$objResult.Properties.mail, ^
                $dispname[1].Trim^(^), $dispname[0].Trim^(^)^); ^
            Write-Host $out; ^
        };""
    for /f "usebackq tokens=1,2,3 delims=," %%I in (
        `powershell -sta !psCommand!`) do (
        set "%~1=%%I"
        if "%%K" == "" ( set "%~2=%%J" :: avoid trailing whitespace
        ) else (         set "%~2=%%J %%K" )
    )
    exit /b
)
:: determines the numerical Windows version, use it like this:
:: > call :getOSver
:: > echo os ver: %osver%
:getOSver
(
    for /f "tokens=4" %%a in ('ver') do set "osver=%%a"
    for /f "delims=." %%a in ("%num%") do set "osver=%%a"
    exit /b
)
:toLower <varname>
(
    set "_UCASE=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    set "_LCASE=abcdefghijklmnopqrstuvwxyz"
    for /l %%a in (0,1,25) do (
       call set "_FROM=%%_UCASE:~%%a,1%%
       call set "_TO=%%_LCASE:~%%a,1%%
       call set "%~1=%%%~1:!_FROM!=!_TO!%%
    )
    exit /b
)
:replaceIllegalGitChars <varname>
(
    ::echo replaceIllegalGitChars '!%~1!'
    set "%~1=!%~1: =_!"
    set "%~1=!%~1:+=_!"
    set "%~1=!%~1:/=_!"
    set "%~1=!%~1:^^=_!"
    set "%~1=!%~1:(=_!"
    set "%~1=!%~1:)=_!"
    set "%~1=!%~1:[=_!"
    set "%~1=!%~1:]=_!"
    set "%~1=!%~1:^~=_!"
    exit /b
)
:getParentPath <resultVar> <pathVar>
(
    set "%~1=%~dp2"
    exit /b
)
:getDirname <resultVar> <pathVar>
(
    set "%~1=%~n2"
    exit /b
)

:end
popd
timeout 120
