@rem Anaconda Update Script.bat
@rem
@rem Copyright (c) 2019 Bundesanstalt für Materialforschung und -prüfung (BAM).
@rem Subject to the MIT license.
@rem
@rem This file is part of 'Jupyter Git Scripts' ( <url> ).
@rem Updates the Anaconda Python distribution and sets up Jupyter with GIT.

@echo off
:: stackoverflow.com/questions/20484151/redirecting-output-from-within-batch-file
set logfile=%~dp0%~n0 (%COMPUTERNAME%).log
echo Configuring Anaconda,
echo progress messages are written to
echo   %logfile%
echo for reference in case of errors.
echo It may take 5-10 min, depending on the computer ...
echo.
call :sub > "%logfile%" 2>&1
set startln=0
:: has to work for UNC network paths as well as on the drive
for /F "delims=: tokens=*" %%I in ('find /v /c "" "%logfile%"') do for %%A in (%%~I) do (
	set "startln=%%A"
)
set /a startln=%startln%-18
::echo startln='%startln%'
if %startln% leq 0 set startln=0
more /c /e +%startln% < "%logfile%"
timeout 30
goto :end

:sub
:: the actual script starts here
setlocal DisableDelayedExpansion EnableExtensions

set scriptpath=%~dp0
set scriptpath=%scriptpath:~0,-1%
pushd "%scriptpath%"

:: Check for the system requirements first
:: ---------------------------------------
set "startTime=%time: =0%"
echo Starting update on %DATE%, %TIME%

:: Check for Git being installed, first check expected location
:: test some candidate directories, faster than searching ...
for /d %%I in ("C:\Program Files" ^
               "%LOCALAPPDATA%\Programs" ^
    ) do if exist %%~I\Git (
        set gitcmd=%%~I\Git\bin\git.exe
    )
if not exist "%gitcmd%" (
    echo [de]
    echo   Git wurde nicht gefunden! Bitte zunaechst 'Git und TortoiseGit' aus
    echo   dem Software Portal installieren und dieses Skript erneut ausfuehren.
    echo [en]
    echo   Git was not found, please install 'Git and TortoiseGit' from the
    echo   Software Portal first and run this script again.
) else (
    echo Git was FOUND:      '%gitcmd%'

    echo.
    echo [de] Konfiguriere globale GIT-Einstellungen ...
    echo [en] Configure global GIT settings ...
    @echo ON

    :: do not auto convert line endings, bad for data files
    "%gitcmd%" config --global core.autocrlf false
    "%gitcmd%" config core.whitespace cr-at-eol

    :: configure TortoiseGit context menu entries
    reg add HKCU\Software\TortoiseGit /f /v ContextMenuEntries /t REG_DWORD /d 0x3641e
    reg add HKCU\Software\TortoiseGit /f /v ContextMenuEntrieshigh /t REG_DWORD /d 0x220
    :: add GIT to users PATH if not already there
    call :getParentPath gitpath "%gitcmd%"
    call :addToPATH "%gitpath:~0,-1%"
)

echo.

:: Check for Anaconda Python environment being installed
:: test some candidate directories, faster than searching ...
for /d %%I in ("%USERPROFILE%" ^
               "%LOCALAPPDATA%\Continuum" ^
               "%ALLUSERSPROFILE%" ^
    ) do if exist %%~I\anaconda3 (
        set anapath=%%~I\anaconda3
    )
set condapath=%anapath%\Library\bin\conda.bat
rem in current versions of Anaconda: %anapath%\condabin\conda.bat
if not exist "%condapath%" (
    echo MISSING Anaconda:   '%condapath%'
    echo [de]
    echo   Die Anaconda Python Distribution wurde nicht gefunden! 
    echo   Bitte zunaechst Anaconda ^(Python 3, 64 bit^) mit Standard-
    echo   einstellungen installieren und dieses Skript erneut ausfuehren.
    echo [en]
    echo   The Anaconda Python Distribution was not found!
    echo   Please install Anaconda ^(Python 3, 64 bit^) with default settings
    echo   first and run this script again.
    start https://www.anaconda.com/download/
    goto :end
)
echo Anaconda was FOUND: '%condapath%'
set pycmd=%anapath%\python.exe
echo Using Python at:    '%pycmd%'
set pipcmd=%anapath%\Scripts\pip.exe
set juplabext=%anapath%\Scripts\jupyter-labextension.exe
set jupsrvext=%anapath%\Scripts\jupyter-serverextension.exe
set jupnbext=%anapath%\Scripts\jupyter-nbextension.exe
set jupcontrib=%anapath%\Scripts\jupyter-contrib.exe
set jupkernspec=%anapath%\Scripts\jupyter-kernelspec.exe
call :addToPATH "%anapath%"

echo.
echo [de] Pruefe ^& aktualisiere erforderliche Python-Module ...
echo [en] Checking ^& updating required Python modules ...
echo.

rem Uninstall obsolete packages from earlier development
call :uninstallModuleWithPip nbopen
rem remove problematic package resulting in VS140COMNTOOLS (VS not found) error
call %condapath% remove -y vs2015_win-64
rem Remove obsolete entries
reg delete HKCU\Software\Classes /f /v Jupyter.nbopen
reg delete HKCU\Software\Classes /f /v .ipynb

:: associating Python files with Anaconda
reg add HKCU\Software\Classes\.py  /f /ve /d Python.File
reg add HKCU\Software\Classes\.py  /f /v "Content Type" /d "text/plain"
rem reg add HKCU\Software\Classes\.pyc /f /ve /d Python.CompiledFile
rem reg add HKCU\Software\Classes\.pyd /f /ve /d Python.Extension
rem reg add HKCU\Software\Classes\.pyo /f /ve /d Python.CompiledFile
rem reg add HKCU\Software\Classes\.pyw /f /ve /d Python.NoConFile
rem reg add HKCU\Software\Classes\.pyw /f /v "Content Type" /d "text/plain"
rem reg add HKCU\Software\Classes\.pyz /f /ve /d Python.ArchiveFile
rem reg add HKCU\Software\Classes\.pyz /f /v "Content Type" /d "application/x-zip-compressed"
rem reg add HKCU\Software\Classes\.pyzw /f /ve /d Python.NoConArchiveFile
rem reg add HKCU\Software\Classes\.pyzw /f /v "Content Type" /d "application/x-zip-compressed"
reg add HKCU\Software\Classes\.ipynb /f /ve /d Jupyter.Notebook
reg add HKCU\Software\Classes\.ipynb /f /v "Content Type" /d "application/x-ipynb+json"
reg add HKCU\Software\Classes\.ipynb /f /v "PerceivedType" /d "document"

reg add HKCU\Software\Classes\Python.File\shell\open\command      /f /ve /d "\"%anapath%\python.exe\" \"%anapath%\cwp.py\" \"%anapath%\" cmd \"start /wait cmd /c\" pushd %%W & python \"%%L\" "
rem reg add HKCU\Software\Classes\Python.File\shellex\DropHandler /f /ve
reg add HKCU\Software\Classes\Jupyter.Notebook\shell\open\command /f /ve /d "\"%anapath%\pythonw.exe\" \"%anapath%\cwp.py\" \"%anapath%\" \"%anapath%\python.exe\" \"%anapath%\Scripts\jupyter-lab-script.py\" \"%%L\""

rem Test for internet connectivity
ping -n 2 -w 2000 pythonhosted.org | find "ytes="
if %ERRORLEVEL% NEQ 0 (
    echo No internet connectivity, skipping package updates/installation!
    goto :end
)

rem Connected to the Internet now
call :removeNode1013
echo Upgrading conda and pip ...
call :upgradeConda
call :upgradePip2
echo Installing/Updating additional packages ...
call %condapath% install -y --no-channel-priority h5py gitpython ipywidgets
rem regular anaconda packages get updated by previous update --all
call %condapath% install -y -c conda-forge nodejs nbstripout lmfit jupyter_contrib_nbextensions
call %condapath% update -y --no-channel-priority -c conda-forge nodejs nbstripout lmfit jupyter_contrib_nbextensions
call :installModuleWithPip msgpack cite2c winshell

rem Set Jupyter extensions regardless of connectivity
call :installJupyterExtensions codefolding/main equation-numbering/main freeze/main toggle_all_line_numbers/main execute_time/ExecuteTime hide_input/main collapsible_headings/main toc2/main

rem Jupyter lab extensions
rem call :installNodeJS
call :installJLabWidgets
rem Git extension (does not work properly with submodules)
call :installJLabGit

rem Jupyter Lab extensions
rem Templates
:: pip install jupyterlab_templates
:: jupyter labextension install jupyterlab_templates
:: jupyter serverextension enable --py jupyterlab_templates
rem install our own template
:: python -c "import jupyterlab_templates, glob, os, shutil; j=os.path.join; p=j(os.path.dirname(jupyterlab_templates.__file__), 'templates'); [os.remove(fn) for fn in glob.glob(j(p, '*.ipynb'))]; fn=j(os.path.expanduser('~'), 'Desktop', 'Our Jupyter Template.ipynb'); if os.path.isfile(fn): shutil.copy(fn, p);"

rem optional packages
:: jupyter labextension install jupyterlab-spreadsheet
:: conda install -y flake8
:: jupyter labextension install jupyterlab-flake8

:: jupyter labextension enable jupyterlab-spreadsheet jupyterlab-flake8

goto :end
:getParentPath <resultVar> <pathVar>
(
    set "%~1=%~dp2"
    goto :eof
)
:addToPATH <absPath>
rem given absPath must be without any trailing backslash
(
	setlocal EnableDelayedExpansion
	:: add given command to the users PATH if not already there
	reg query HKCU\Environment /f Path | findstr /i /c:"%~1" >nul
	if !ERRORLEVEL! NEQ 0 (
		:: git path not set yet, append it to the users PATH
		for /F "tokens=2*" %%I in ('reg query HKCU\Environment /f Path ^| findstr REG_EXPAND_SZ') do (
			reg add HKCU\Environment /f /v Path /t REG_EXPAND_SZ /d "%%J;%~1"
		)
	)
	setlocal DisableDelayedExpansion
	echo Adjusted PATH:
	reg query HKCU\Environment /f Path
    goto :eof
)
:removeNode1013
(
    echo removeNode1013
    setlocal EnableDelayedExpansion
    for /F "tokens=2" %%I in ('conda list nodejs -q ^| findstr /b /v #') do (set "nodever=%%I")
    for /F "delims=. tokens=1,2,3" %%I in ("!nodever!") do (
        if %%I EQU 10 if %%J EQU 13 (
            echo Removing nodejs v10.13 first, it is buggy and can not be installed/upgraded
            call %condapath% remove nodejs -y
        )
    )
    setlocal DisableDelayedExpansion
    goto :eof
)
:installNodeJS
(
    setlocal EnableDelayedExpansion
    where npm >nul 2>nul
    if !ERRORLEVEL! NEQ 0 (
        echo NPM/nodejs not found, installing it first
        call %condapath% install -c conda-forge -y nodejs
    ) else (
        rem Updating nodejs
        call npm install -g npm
        call npm install -g npm
    )
    setlocal DisableDelayedExpansion
    goto :eof
)
:fixInconsistentConda
(
    rem for /f "delims=:= tokens=2,3*" %i in ('%condapath% install fgdfgsdfgdf 2^>^&1 ^| findstr "=="') do ( echo %i;%j;%k )
    goto :eof
)
:installJLabWidgets
(
	rem call %condapath% install -y ipywidgets
	call %juplabext% install @jupyter-widgets/jupyterlab-manager
	call %juplabext% install jupyter-matplotlib
    goto :eof
)
:installJLabGit
(
	call %pycmd% -m pip install --upgrade jupyterlab-git
	call %juplabext% install @jupyterlab/git
	call %jupsrvext% enable --py jupyterlab_git
    goto :eof
)
:upgradeConda
(
    call %condapath% update -y --no-channel-priority --all
    goto :eof
)
:upgradePip2
(
    call %pycmd% -m pip install --upgrade pip
    goto :eof
)
:installModuleWithPip <modName>
(
	for %%I in (%*) do (
		echo.
		echo Checking module '%%I':
		call %pycmd% -m pip install --upgrade %%I
	)
    goto :eof
)
:uninstallModuleWithPip <modName>
(
	for %%I in (%*) do (
		echo.
		echo Uninstalling module '%%I':
		call %pycmd% -m pip uninstall --yes %%I
	)
    goto :eof
)
:installJupyterExtensions
(
    call %jupcontrib% nbextensions install --user
    for %%I in (%*) do (
        echo.
        call %jupnbext% enable %%I
    )
    :: github.com/takluyver/cite2c
    call %pycmd% -m cite2c.install
    :: fix for console window remaining open and restarting on win10
    :: github.com/takluyver/nbopen/issues/54#issuecomment-379711047
	setlocal EnableDelayedExpansion
	for /F "skip=1 tokens=2" %%I in ('%jupkernspec% list') do (
		if exist "%%I" set kernpath=%%I\kernel.json
	)
	echo Updating '!kernpath!'.
	rem Reverting former nbopen patch of python exec in kernel.json
	call %pycmd% -c "fd=open(r'!kernpath!','r'); buf=fd.read().replace('pythonw.exe','python.exe'); fd.close(); fd=open(r'!kernpath!','w'); fd.write(buf); fd.close()"

	setlocal DisableDelayedExpansion
    goto :eof
)

:end
popd
setlocal EnableDelayedExpansion
set "endTime=%time: =0%"
rem Get elapsed time:
set "end=!endTime:%time:~8,1%=%%100)*100+1!"  &  set "start=!startTime:%time:~8,1%=%%100)*100+1!"
set /A "elap=((((10!end:%time:~2,1%=%%100)*60+1!%%100)-((((10!start:%time:~2,1%=%%100)*60+1!%%100)"
rem Convert elapsed time to HH:MM:SS:CC format:
set /A "cc=elap%%100+100,elap/=100,ss=elap%%60+100,elap/=60,mm=elap%%60+100,hh=elap/60+100"

echo Update finished on %DATE%, %TIME% (%hh:~1%%time:~2,1%%mm:~1%%time:~2,1%%ss:~1%%time:~8,1%%cc:~1%)
