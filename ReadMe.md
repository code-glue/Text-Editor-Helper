# Text-Editor-Helper

## 1. When you want the option to "Edit" files as plain text in addition to "Opening" them.
![Edit Menu](demo/EditMenu.png?raw=true "Edit Menu")

## 2. When you want the option to use your favorite portable text editor.
![Open With Menu](demo/OpenWith.png?raw=true "Open With Menu")
___
### For example, in addition to opening an HTML file in your browser, you can also edit the file in Notepad++.
___
**Notes:**
* Does not change your default text editor or any default applications.
* Affects only the current user.
* Administrative privileges are not required.
___
## Scripts:
### RegisterTextFileExt.bat
Registers the specified file extension as a text file. This adds the "Edit" option to the file's context menu and adds the list of all registered text editors to the "Open with" menu.
___
**Usage:**

    RegisterTextFileExt [[.]Extension]

      Extension    File extension to register, optionally prefixed by "."
                   If excluded, user is prompted for the file extension.

    Examples:
      C:\>RegisterTextFileExt
        Prompts for the file extension.

      C:\>RegisterTextFileExt sln
        Registers the file extension ".sln" as a text file.

      C:\>RegisterTextFileExt .sln
        Registers the file extension ".sln" as a text file.
**Demo:**

![Before and After Demo](demo/TextFileExtBeforeAfter.gif?raw=true "Before and After Demo")
___
### RegisterTextFileExtForAll.bat
Registers all of the file extensions below as text files. This adds the "Edit" option to the file's context menu and adds the list of all registered text editors to the "Open with" menu.

**File extensions:**
.a .ada .adb .addin .ads .ahk .ammo .ans .arena .as .asc .ascx .asm .asp .aspx .asx .atr .au3 .aut .aux .axl .bas .bash .bash_login .bash_logout .bash_profile .bashrc .bat .bcp .bhc .bib .body .bot .bowerrc .bsh .c .camera .cbd .cbl .cc .cdb .cdc .cfg .cfm .cgi .clj .cljs .cljx .clojure .cls .cmake .cmd .cnf .cob .code-workspace .coffee .conf .config .cpp .cs .csa .csdl .cshtml .csproj .css .csv .csx .ctl .cue .cxx .d .dbs .def .defs .dfm .dic .diff .diz .dob .docbook .dockerfile .dos .dot .dotsettings .dpk .dpr .dsm .dsp .dsr .dsw .dtd .editorconfig .edmx .edn .efx .ent .ext .eyaml .eyml .f .f2k .f90 .f95 .faq .filters .fky .for .frames .frm .fs .fsi .fsscript .fsx .g2skin .gametype .gemspec .generate .git .gitattributes .gitconfig .gitignore .gitmodules .go .gore .gradle .gsc .h .handlebars .hbs .hh .hpp .hs .hta .htd .htm .html .htt .hud .hxa .hxc .hxk .hxt .hxx .i .ibq .ics .idl .idq .idx .il .iml .impacts .inc .inf .ini .inl .instance .inview .inx .isl .iss .itcl .item .jade .jav .java .js .jscsrc .jse .jsfl .jshintrc .jshtm .json .jsp .jsx .kci .kix .kml .las .less .lgn .lhs .linq .lisp .litcoffee .log .lsp .lst .lua .m .m3u .mak .makefile .map .mapcycle .markdown .master .material .md .mdoc .mdown .mdtext .mdtxt .mdwn .menu .miscents .mission .mjs .mk .mkd .mkdn .ml .mli .ms .msl .mx .name .nav .nfo .npc .npmignor .nsh .nsi .nt .objectives .odh .odl .outfitting .pag .pas .patch .php .php3 .php4 .phtml .pl .pl6 .player .pln .plx .pm .pm6 .pod .poses .pp .prc .pro .profile .properties .props .ps .ps1 .psd1 .psgi .psm1 .py .pyproj .pyw .q3asm .qe4 .r .rb .rbw .rc .rc2 .rct .rdf .recent .reg .rej .resx .rgs .rhistory .rmd .rprofile .rs .rt .rul .s .sample .scc .scm .script .scss .ses .settings .sf .sh .shader .shfbproj .shock .shtm .shtml .sif .skl .sln .sma .smd .sml .sol .sp .spb .spec .sps .sql .ss .ssdl .st .str .sty .stype .sun .sv .svg .svgz .svh .t .tab .targets .tcl .tdl .teams .terrain .tex .theme .thy .tlh .tli .toc .tpl .trg .ts .tsx .tt .ttinclude .tui .tuo .txt .udf .udt .url .user .usr .v .vb .vbe .vbproj .vbs .vcproj .vcs .vcxproj .vdproj .vh .vhd .vhdl .viw .voice .vscontent .vsdir .vsprops .vspscc .vsscc .vssettings .vssscc .vstdir .vstheme .vsz .vxml .wml .wnt .wpn .wri .wsdl .wsf .wtx .wxi .wxl .wxs .xaml .xbap .xhtml .xlf .xliff .xml .xrc .xsd .xsl .xslt .xsml .xul .yaml .yml .zsh

**Usage:**

    RegisterTextFileExtForAll <No Parameters>
___
### RegisterTextEditor.bat
Registers the specified program as a text editor and adds it to the "Open with" list for text files and for files with no extension.

**Usage:**

    RegisterTextEditor [FilePath [ProgID[.exe]]]

    FilePath     Path to the text editor.
                 If excluded, user is prompted for the path and program ID.
    ProgID       The internal name used to register the text editor, optionally
                 followed by ".exe". If excluded, the file's name will be used.
                 If no extension is entered, ".exe" is appended.
    Examples:
      C:\>RegisterTextEditor
        Prompts for the path to the text editor.

      C:\>RegisterTextEditor "C:\apps\NotePad++\notepad++.exe"
        Registers Notepad++ as a text editor using the ProgID "notepad++.exe".

      C:\>RegisterTextEditor "C:\apps\NotePad++\notepad++.exe" npp
        Registers Notepad++ as a text editor using the ProgID "npp.exe".
___
### UnregisterTextEditor.bat
Unregisters a text editor application using the specified program ID. The program ID is usually the text editor's file name.

**Usage:**

    UnregisterTextEditor [ProgID[.exe]]

    ProgID    Program ID of the text editor (usually its file name), optionally
              followed by ".exe".
              If excluded, user is prompted for the program ID.
              If no extension is entered, ".exe" is appended.

    Examples:
      C:\>UnregisterTextEditor
        Prompts for the program ID of the text editor.

      C:\>UnregisterTextEditor "notepad++.exe"
        Unregisters Notepad++ as a text editor using ProgID "notepad++.exe".

      C:\>UnregisterTextEditor npp
        Unregisters Notepad++ as a text editor using ProgID "npp.exe".
___
### RegisterDefaultTextEditHandler.bat
Registers the specified program as the default "Edit" handler for text files and adds it to the "Open with" list for text files and for files with no extension.

**Usage:**

    RegisterDefaultTextEditHandler [FilePath [ProgID[.exe]]]

      FilePath     Path to the text editor.
                   If excluded, user is prompted for the path and program ID.
      ProgID       The internal name used to register the text editor, optionally
                   followed by ".exe". If excluded, the file's name will be used.
                   If no extension is entered, ".exe" is appended.

    Examples:
      C:\>RegisterDefaultTextEditHandler
        Prompts for the path to the text editor.

      C:\>RegisterDefaultTextEditHandler "C:\apps\NotePad++\notepad++.exe"
        Registers Notepad++ as a text editor using the ProgID "notepad++.exe".

      C:\> "C:\apps\NotePad++\notepad++.exe" npp
        Registers Notepad++ as a text editor using the ProgID "npp.exe".
___
### RegisterExplicitEditHandler.bat
Registers the specified program as the "Edit" handler for the specified program ID.

**Note:**

* Some program IDs already have an explicit "Edit" handler (e.g. *Notepad.exe*) already defined in the registry (as opposed to having a default handler for all text files).
* To change the handler, one must overwrite the existing value.


**Usage:**

    RegisterExplicitEditHandler [FilePath ProgID]

      FilePath     Path to the application.
                   If excluded, user is prompted for the path and program ID.
      ProgID       The program ID whose "Edit" handler will be set.
                   This must be an existing program ID.

    Examples:
      C:\>RegisterExplicitEditHandler
        Prompts for the application path and the program ID.

      C:\>RegisterExplicitEditHandler "C:\apps\NotePad++\notepad++.exe" "batfile"
        Registers Notepad++ as the "Edit" handler for the "batfile" program ID.
        In most cases this represents .bat (batch) files.

      C:\>RegisterExplicitEditHandler "C:\apps\NotePad++\notepad++.exe" JSFile
        Registers Notepad++ as the "Edit" handler for the "JSFile" program ID.
        In most cases this represents .js (javascript) files.
___
### RegisterExplicitEditHandlerForAll.bat
Registers the specified program as the "Edit" handler for all the program IDs below.

**Note:**

* Some program IDs already have an explicit "Edit" handler (e.g. *Notepad.exe*) already defined in the registry (as opposed to having a default handler for all text files).
* To change the handler, one must overwrite the existing value.

**Program IDs:**
batfile cmdfile htafile JSFile JSEFile regfile themefile VBEFile VBSFile Windows.XamlDocument
 Windows.Xbap WSFFile
**Usage:**

    RegisterExplicitEditHandlerForAll [FilePath]

      FilePath     Path to the application.
                   If excluded, user is prompted for the application path.

    Examples:
      C:\>RegisterExplicitEditHandlerForAll
        Prompts for the application path.

      C:\>RegisterExplicitEditHandlerForAll "C:\apps\NotePad++\notepad++.exe"
        Registers Notepad++ as the "Edit" handler for all the listed program IDs.