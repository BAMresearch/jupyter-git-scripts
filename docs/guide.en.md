# english
## Versioning with GIT

- A very good introduction [What is version control?](https://www.atlassian.com/git/tutorials/what-is-version-control) can be found at Atlassian who offer software and servers for Git as well but their services are not used here.
- [A complete book about Git](https://git-scm.com/book) is even available free of charge.

### General Terms, Glossary

- **Project**:  
  A folder with GIT version control, containing one or more Jupyter notebooks,
  Python source code files and supplementary files.
- **Clone**:  
  Downloading the project from the remote repository for the first time.
  The full history of changes will be copied as well.
- **Commit**:  
  The posting of marked (*staged*) changes including a short description, timestamp and username are added automatically. User name and email address can be stored centrally or individually for each repository.

### Using TortoiseGit

<style>
	img[alt=TortoiseGit_KontextMenu] {
	  width: 200px; margin: 0 1em 1em 1em;
	  border: none; background: none;
	  float: right;
	}
</style>
![TortoiseGit_KontextMenu][3]

> TortoiseGit is a graphical [Git][1] revision control client for Windows. 
(See also [Wikipedia][2])

Since [Git][1] is a file-level version control program, [TortoiseGit][2] adds additional context menu options for files and directories under Windows

TortoiseGit can be used independently of Jupyter(Lab) for any git repository on Windows. It integrates itself into the explorer context menu and performs file-level operations, much like the corresponding Git command line commands.

[1]: https://en.wikipedia.org/wiki/Git
[2]: https://en.wikipedia.org/wiki/TortoiseGit
[3]: img/tgit_context_menu.png "TortoiseGit Context Menu"

#### Instructions and Introductions

Online already exist numerous (video-)instructions and support, therefore we only refer to them here:
- [Video tutorial about the basic use of TortoiseGit](https://www.youtube.com/watch?v=_ZTPLrhLu-I)

#### *Clone* - First download of an existing project

<style>
	img[alt=GithubCloneMenu] {
	  width: 400px; margin: 0 1em 1em 1em;
	  border: none; background: none;
	  float: right; }
	img[alt=WinContextClone] {
	  width: 200px; margin: 0 1em 1em 1em;
	  border: none; background: none;
	  float: right; }
	img[alt=TGitDialogClone] {
	  width: 400px; margin: 1em 1em 1em 1em;
	  border: none; background: none;
	   }
	img[alt=TGitSuccessClone] {
	  width: 350px; margin: 0 1em 1em 1em;
	  border: none; background: none;
	  float: right; }
	ol li p { padding-bottom: 1em; }
	.section { clear: both; }
</style>
![GithubCloneMenu][20]

1. Visit the website with the git repository, e.g. [a project on github.com][21]. There click on the **Code** button which opens the menu with the address that can be used to *clone* the project (see screenshot). By clicking the ![clipboard][22] icon next to the address, the address is copied to the clipboard.
2. ![WinContextClone][23] Use Windows Explorer to navigate to the row folder and right click to open the context menu and select the *Git Clone...* option.
3. Enter the HTTPS address of the project in the **URL** field. It should already be entered if the address has already been copied to the clipboard (previous point 2). ![TGitDialogClone][24] 
4. ![TGitSuccessClone][25] After confirming the dialog with **OK**, the project is downloaded and at the end a text window with status information and the message **Success** in blue font appears. The window can now be closed with the **Close** button.

[20]: img/github_clone_menu.png "Github Clone Menu"
[21]: https://github.com/BAMresearch/jupyter-integration
[22]: img/clipboard.png "clipboard icon"
[23]: img/context_menu_clone.png "context menu for clone"
[24]: img/tgit_clone_dialog.png "TortoiseGit dialog clone"
[25]: img/tgit_success_clone.png "TortoiseGit clone successful"

#### Further basic steps

##### *Add* - add files, track their changes

1. **Right click on the file** -> **TortoiseGit** -> select **Add…**. After that a window with a short overview of the selected files appears, which should be confirmed with **OK**. Finally a small window appears which confirms the successful adding.
2. The file is now marked with a blue plus symbol, i.e. it is marked for the next **Commit** but not yet uploaded to the server (in the so-called **Staging** area).

1. **Rechts-Klick auf die Datei** -> **TortoiseGit** -> **Add…** auswählen. Darauf folgend erscheint ein Fenster mit einer kurzen Übersicht der ausgewählten Dateien, die mit **OK** bestätigt wird. Abschließend erscheint ein kleines Fenster, welches das erfolgreiche Hinzufügen bestätigt.
2. Die Datei ist nun mit einem blauen Plus-Symbol markiert, d.h. sie ist für den nächsten **Commit** vorgemerkt aber noch nicht auf den Server geladen (im sog. **Staging**-Bereich).

##### *Commit* - Post changes

1. Open the context menu of the versioned folder (right-click) and select **Git Commit -> "master"…**.
2. The first time you run it, an error occurs because the username and email address are not yet set, but both are required for each commit. Confirm here and enter and save your own name and email address.
3. In the following step, a window appears with a summary of the changes to be posted in the lower area and a text field for the description of these changes in the upper area. Please enter a short and meaningful description of the changes you made.
4. The file is now marked with a green checkmark, i.e. it is booked in the history, but still not uploaded to the server or synchronized.

##### *Push* - Update the server (first time to new project)

1. Select in the context menu of the folder: **TortoiseGit**->**Push…**
2. Leave the default settings in the following dialog and check **Set upstream/track remote branch** to set the current **master** branch as default for all further actions.
3. Confirm with **OK**.

##### Synchronize with the server (every other time)

1. Select **Git Sync...** in the context menu of the folder.
2. First load possible changes from the server using **Pull**.
3. If this was successful, upload your changes to the server using **Push**.

## JupyterLab with Version Control
### Requirements

- Git and TortoiseGit (GUI)
- Anaconda providing the Python environment

### Installing GIT
<style>
	img[alt=IconGitTGit] {
	  width: 100px; margin: 0 1em 1em 1em;
	  border: none; background: none;
	  float: right; }
</style>

1. ![IconGitTGit](img/icon_git+tgit.png) **Option**  
  A corporate internal *software portal* provides Git and TortoiseGit or a combined package of the two.
2. **Option**  
  Download and install Git from the [project website](https://git-scm.com/download/win) manually.
   - Additionally, the graphical user interface [TortoiseGit](https://tortoisegit.org/download/) can be installed. However, this requires administrator privileges.

### Installing the Python environment *Anaconda*

1. Download the Anaconda-Package for Windows, 64 bit, from the [Anaconda website](https://www.anaconda.com/products/individual#Downloads)
    - If the virus scanner blocks some installation scripts (*.bat files) in the following, install an older version of Anaconda, e.g. from [Oct. 2019](https://repo.anaconda.com/archive/Anaconda2-2019.10-Windows-x86_64.exe), and then update, for example via the *Anaconda Navigator*.
2. Start the setup by double-clicking the file.
3. Confirm the license agreement with mit **I Agree**.
4. Install for the current user only be selecting **Just Me**.
5. Keep the default destination folder for the installation and confirm with **Next >**
6. Leave other options at their default values and complete the installation.

### Setting up Git support for JupyterLab

1. Download a [repository of helper scripts from GitHub](https://github.com/BAMresearch/jupyter-integration), [for example with *TortoiseGit*](#clone-first-download-of-an-existing-project)
2. Double click on the file **Anaconda Update Script.bat** and let it run. It does several things and does not require admin rights:
    - It updates the Anaconda Python distribution and creates a log file of the process next to the location of the scripts (*ComputerName.log*).
    - It registers the Jupyter-Notebook file extension .ipynb, so that a double click on such files starts JupyterLab and opens the notebook.
    - It installs extensions for interactive widgets (*ipywidgets*) in JupyterLab and installs nodeJS, which is required for this.
    - Last but not least, it installs the extension *jupyterlab_git*, which adds an integrated user interface for Git to JupyterLab.

### Links to learning material

#### Jupyter Lab/Notebook
- [Easily digestible videos for getting started in the JupyterLab](https://www.youtube.com/watch?v=7wfPqAyYADY)
- [And there are more!](https://www.youtube.com/results?search_query=jupyterlab)

#### Python
- [There are several free(!) books introducing the Python programming language](https://pythonbooks.org/free-books/)
- [The official Python Tutorial](https://docs.python.org/3/tutorial/index.html)
- [A online platform for trying it out](https://jupyter.org/try)  
  (Just in case Anaconda is not installed or does not work.)

#### Markdown
- [The Markdown Syntax explained concisely](https://commonmark.org/help/tutorial/index.html)
