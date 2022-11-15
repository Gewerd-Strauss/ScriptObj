; from RaptorX https://github.com/RaptorX/ScriptObj/blob/master/ScriptObj.ahk
/**
 * ============================================================================ *
 * @Author           : RaptorX <graptorx@gmail.com>
 * @Script Name      : Script Object
 * @Script Version   : 0.26.3
 * @Homepage         :
 *
 * @Creation Date    : November 09, 2020
 * @Modification Date: October 04, 2022
 * @Modification G.S.: 08.2022
 ; @Description Modification G.S.:
    - Load()-method always returns false if File
	  passed to parameter "INI_File" does not exist
    - Load()-method always returns -1 if File
	  passed to parameter "INI_File" does not contain
	  any values
	- Load()-method can be set up to not warn in
	  case of a missing ini-file.
	- added field for GitHub-link, a Forum-link 
	  and a credits-field, as well as a template 
	  to quickly copy out into new scripts
	  Contains methods for saving and loading 
	  config-files containing an array - 
	  basically an integration of Wolf_II's
	  WriteIni/ReadIni with some adjustments
	  added Update()-functionality for non-zipped
	  remote files so that one can update a 
	  A_ScriptFullPath-contained script from 
	  f.e. GH.
	- Reworked the Update()-Method with help of 
	  u/anonymous1184.
	- Added filter to not engange Update-method 
	  if vfile contains the words "REPOSITORY_NAME" 
	  or "BRANCH_NAME", indicating a template has
	  not been adjusted yet - or is not intended to
	- added autoformatting for ingesting credits via
	  the "CreditsRaw"-continuation-section in the 
	  template below
								
 * 
 * @Description      :
 * -------------------
 * This is an object used to have a few common functions between scripts
 * Those are functions and variables related to basic script information,
 * upgrade and configuration.
 *
 * ============================================================================ *
 */
; scriptName   (opt) - Name of the script which will be
; 		                     shown as the title of the window and the main header
; 		version      (opt) - Script Version in SimVer format, a "v"
; 		                     will be added automatically to this value
; 		author       (opt) - Name of the author of the script
; 		credits 	 (opt) - Name of credited people
; 		creditslink  (opt) - Link to credited file, if any
; 		crtdate		 (opt) - Date of creation
; 		moddate		 (opt) - Date of modification
; 		homepagetext (opt) - Display text for the script website
; 		homepagelink (opt) - Href link to that points to the scripts
; 		                     website (for pretty links and utm campaing codes)
; 		ghlink 		 (opt) - GitHubLink
; 		ghtext 		 (opt) - GitHubtext
; 		forumlink    (opt) - forumlink to the scripts forum page
; 		forumtext    (opt) - forumtext 
; 		donateLink   (opt) - Link to a donation site
; 		email        (opt) - Developer email

; /Template_Start
/*
for creditsRaw, use "/" in the "URL"-field when the snippet is not published yet (e.g. for code you've written yourself and not published yet)
space author, SnippetNameX and URLX out by spaces or tabs, and remember to include "-" inbetween both fields
when 2+ snippets are located at the same url, concatenate them with "|" and treat them as a single one when putting together the URL's descriptor string
finally, make sure toingest 'CreditsRaw' into the 'credits'-field of the template below.
*/
; CreditsRaw=
; (LTRIM
; author1   -		 snippetName1		   		  			-	URL1
; Gewerd S, original by RaptorX -  						    - https://github.com/Gewerd-Strauss/ScriptObj/blob/master/ScriptObj.ahk, https://github.com/RaptorX/ScriptObj/blob/master/ScriptObj.ahk
; Gewerd Strauss		- scriptObject						-	/
; )
; FileGetTime, ModDate,%A_ScriptFullPath%,M
; FileGetTime, CrtDate,%A_ScriptFullPath%,C
; CrtDate:=SubStr(CrtDate,7,  2) "." SubStr(CrtDate,5,2) "." SubStr(CrtDate,1,4)
; ModDate:=SubStr(ModDate,7,  2) "." SubStr(ModDate,5,2) "." SubStr(ModDate,1,4)
; global script := {   base         : script
;                     ,name         : regexreplace(A_ScriptName, "\.\w+")
;                     ,version      : FileOpen(A_ScriptDir "\version.ini","r").Read()
;                     ,author       : "Gewerd Strauss"
; 					,authorID	  : "Laptop-C"
; 					,authorlink   : ""
;                     ,email        : ""
;                     ,credits      : CreditsRaw
; 					,creditslink  : ""
;                     ,crtdate      : CrtDate
;                     ,moddate      : ModDate
;                     ,homepagetext : ""
;                     ,homepagelink : ""
;                     ,ghtext 	  : "GH-Repo"
;                     ,ghlink       : "https://github.com/Gewerd-Strauss/REPOSITORY_NAME"
;                     ,doctext	  : ""
;                     ,doclink	  : ""
;                     ,forumtext	  : ""
;                     ,forumlink	  : ""
;                     ,donateLink	  : ""
;                     ,resfolder    : A_ScriptDir "\res"
;                     ,iconfile	  : ""
;					  ,reqInternet: false
; 					,rfile  	  : "https://github.com/Gewerd-Strauss/REPOSITORY_NAME/archive/refs/heads/BRANCH_NAME.zip"
; 					,vfile_raw	  : "https://raw.githubusercontent.com/Gewerd-Strauss/REPOSITORY_NAME/BRANCH_NAME/version.ini" 
; 					,vfile 		  : "https://raw.githubusercontent.com/Gewerd-Strauss/REPOSITORY_NAME/BRANCH_NAME/version.ini" 
; 					,vfile_local  : A_ScriptDir "\version.ini" 
;					,DataFolder:	A_ScriptDir ""
;                     ,config:		[]
; 					,configfile   : A_ScriptDir "\INI-Files\" regexreplace(A_ScriptName, "\.\w+") ".ini"
;                     ,configfolder : A_ScriptDir "\INI-Files"}
/*	
	; For throwing errors via script.debug
	script.Error:={	 Level		:""
					,Label		:""
					,Message	:""	
					,Error		:""		
					,Vars:		:[]
					,AddInfo:	:""}
	if script.error
		script.Debug(script.error.Level,script.error.Label,script.error.Message,script.error.AddInfo,script.error.Vars)
*/
; script.Load()
; , script.Update(,,,,,)  ;; DO NOT ACTIVATE THISLINE UNTIL YOU DUMBO HAS FIXED THE DAMN METHOD. God damn it.
; /Template_End
class script
{
	static DBG_NONE     := 0
	      ,DBG_ERRORS   := 1
	      ,DBG_WARNINGS := 2
	      ,DBG_VERBOSE  := 3

	static name       := ""
        ,version      := ""
        ,author       := ""
		,authorID	  := ""
        ,authorlink   := ""
        ,email        := ""
        ,credits      := ""
        ,creditslink  := ""°
        ,crtdate      := ""
        ,moddate      := ""
        ,homepagetext := ""
        ,homepagelink := ""
        ,ghtext 	  := ""
        ,ghlink       := ""
        ,doctext	  := ""
        ,doclink	  := ""
        ,forumtext	  := ""
        ,forumlink	  := ""
        ,donateLink   := ""
        ,resfolder    := ""
        ,iconfile     := ""
		,vfile_local  := ""
		,vfile_remote := ""
        ,config       := ""
        ,configfile   := ""
        ,configfolder := ""
		,icon         := ""
		,systemID     := ""
		,dbgFile      := ""
		,rfile		  := ""
		,vfile		  := ""
		,dbgLevel     := this.DBG_NONE
		,versionScObj := "0.21.3"


	/**
		Function: Update
		Checks for the current script version
		Downloads the remote version information
		Compares and automatically downloads the new script file and reloads the script.

		Parameters:
		vfile - Version File
		        Remote version file to be validated against.
		rfile - Remote File
		        Script file to be downloaded and installed if a new version is found.
		        Should be a zip file that w°ll be unzipped by the function

		Notes:
		The versioning file should only contain a version string and nothing else.
		The matching will be performed against a SemVer format and only the three
		major components will be taken into account.

		e.g. '1.0.0'

		For more information about SemVer and its specs click here: <https://semver.org/>
	*/
	Update(vfile:="", rfile:="",bSilentCheck:=false,Backup:=true,DataOnly:=false)
	{
		; Error Codes
		static ERR_INVALIDVFILE := 1
			,ERR_INVALIDRFILE       := 2
			,ERR_NOCONNECT          := 3
			,ERR_NORESPONSE         := 4
			,ERR_INVALIDVER         := 5
			,ERR_CURRENTVER         := 6
			,ERR_MSGTIMEOUT         := 7
			,ERR_USRCANCEL          := 8
		vfile:=(vfile=="")?this.vfile:vfile
		,rfile:=(rfile=="")?this.rfile:rfile
		if RegexMatch(vfile,"\d+") || RegexMatch(rfile,"\d+")	 ;; allow skipping of the routine by simply returning here
			return
		; Error Codes
		if (vfile="") 											;; disregard empty vfiles
			return
		if (!regexmatch(vfile, "^((?:http(?:s)?|ftp):\/\/)?((?:[a-z0-9_\-]+\.)+.*$)"))
			exception({code: ERR_INVALIDVFILE, msg: "Invalid URL`n`nThe version file parameter must point to a 	valid URL."})
		if  (regexmatch(vfile, "(REPOSITORY_NAME|BRANCH_NAME)"))
			Return												;; let's not throw an error when this happens because fixing it is irrelevant to development in 95% of all cases

		; This function expects a ZIP file
		if (!regexmatch(rfile, "\.zip"))
			exception({code: ERR_INVALIDRFILE, msg: "Invalid Zip`n`nThe remote file parameter must point to a zip file."})

		; Check if we are connected to the internet
		http := comobjcreate("WinHttp.WinHttpRequest.5.1")
		, http.Open("GET", "https://www.google.com", true)
		, http.Send()
		try
			http.WaitForResponse(1)
		catch e
		{
			bScriptObj_IsConnected:=ScriptObj_IsConnected()
			if !bScriptObj_IsConnected && !this.reqInternet && (this.reqInternet!="") ;; if internet not required - just abort update checl
			{ ;; TODO: replace with msgbox-query asking to start script or not - 
				ttip_ScriptObj(script.name ": No internet connection established - aborting update check. Continuing Script Execution",,,,,,,,18)
				return
			}
			if !bScriptObj_IsConnected && this.reqInternet ;; if internet is required - abort script
			{
					gui, +OwnDialogs
					OnMessage(0x44, "OnMsgBoxScriptObj")
					MsgBox 0x11,% this.name " - No internet connection",% "No internet connection could be established. `n`nAs " this.name " requires an active internet connection`, the program will shut down now.`n`n`n`nExiting."
					OnMessage(0x44, "")

					IfMsgBox OK, {
						ExitApp
					} Else IfMsgBox Cancel, {
						reload
					}
					
			}

				
		}
			; throw {code: ERR_NOCONNECT, msg: e.message} ;; TODO: detect if offline
		if (!bSilentCheck)
				Progress, 50, 50/100, % "Checking for updates", % "Updating"

		; Download remote version file
		http.Open("GET", vfile, true)
		http.Send()
		try
			http.WaitForResponse(1)
		catch
		{

		}

		if !(http.responseText)
		{
			Progress, OFF
			try
				throw exception("There was an error trying to download the ZIP file for the update.`n","script.Update()","The server did not respond.")
			Catch, e
				msgbox, 8240,% this.Name " -  No response from server", % e.Message "`n`nCheck again later`, or contact the author/provider. Script will resume normal operation."
		}
		regexmatch(this.version, "\d+\.\d+\.\d+", loVersion)		;; as this.version is not updated automatically, instead read the local version file
		
		; FileRead, loVersion,% A_ScriptDir "\version.ini"
		d:=http.responseText
		regexmatch(http.responseText, "\d+\.\d+\.\d+", remVersion)
		if (!bSilentCheck)
		{
			Progress, 100, 100/100, % "Checking for updates", % "Updating"
			sleep 500 	; allow progress to update
		}
		Progress, OFF

		; Make sure SemVer is used
		if (!loVersion || !remVersion)
		{
			try
				throw exception("Invalid version.`n The update-routine of this script works with SemVer.","script.Update()","For more information refer to the documentation in the file`n" )
			catch, e
				msgbox, 8240,% "Invalid Version", % e.What ":" e.Message "`n`n" e.Extra "'" e.File "'."
		}
		; Compare against current stated version
		ver1 := strsplit(loVersion, ".")
		, ver2 := strsplit(remVersion, ".")
		, bRemoteIsGreater:=[0,0,0]
		, newversion:=false
		for i1,num1 in ver1
		{
			for i2,num2 in ver2
			{
				if (i1 == i2)
				{
					if (num2 > num1)
					{
						bRemoteIsGreater[i1]:=true
						break
					}
					else if (num2 = num1)
						bRemoteIsGreater[i1]:=false
					else if (num2 < num1)
						bRemoteIsGreater[i1]:=-1
				}
			}
		}
		if (!bRemoteIsGreater[1] && !bRemoteIsGreater[2]) ;; denotes in which position (remVersion>loVersion) → 1, (remVersion=loVersion) → 0, (remVersion<loVersion) → -1 
			if (bRemoteIsGreater[3] && bRemoteIsGreater[3]!=-1)
				newversion:=true
		if (bRemoteIsGreater[1] || bRemoteIsGreater[2])
			newversion:=true
		if (bRemoteIsGreater[1]=-1)
			newversion:=false
		if (bRemoteIsGreater[2]=-1) && (bRemoteIsGreater[1]!=1)
			newversion:=false
		if (!newversion)
		{
			if (!bSilentCheck)
				msgbox, 8256, No new version available, You are using the latest version.`n`nScript will continue running.
			return
		}
		else
		{
			; If new version ask user what to do				"C:\Users\CLAUDI~1\AppData\Local\Temp\AHK_LibraryGUI
			; Yes/No | Icon Question | System Modal
			msgbox % 0x4 + 0x20 + 0x1000
				, % "New Update Available"
				, % "There is a new update available for this application.`n"
				. "Do you wish to upgrade to v" remVersion "?"
				, 10	; timeout

			ifmsgbox timeout
			{
				try
					throw exception("The message box timed out.","script.Update()","Script will not be updated.")
				Catch, e
					msgbox, 4144,% this.Name " - " "New Update Available" ,   % e.Message "`nNo user-input received.`n`n" e.Extra "`nResuming normal operation now.`n"
				return
			}
			ifmsgbox no
			{		;; decide if you want to have this or not. 
				; try
				; 	throw exception("The user pressed the cancel button.","script.Update()","Script will not be updated.") ;{code: ERR_USRCANCEL, msg: "The user pressed the cancel button."}
				; catch, e
				; 	msgbox, 4144,% this.Name " - " "New Update Available" ,   % e.Message "`n`n" e.Extra "`nResuming normal operation now.`n"
				return
			}

			; Create temporal dirs
			ghubname := (InStr(rfile, "github") ? regexreplace(a_scriptname, "\..*$") "-latest\" : "")
			filecreatedir % Update_Temp := a_temp "\" regexreplace(a_scriptname, "\..*$")
			filecreatedir % zipDir := Update_Temp "\uzip"

			; ; Create lock file
			; fileappend % a_now, % lockFile := Update_Temp "\lock"

			; Download zip file
			urldownloadtofile % rfile, % file:=Update_Temp "\temp.zip"

			; Extract zip file to temporal folder
			shell := ComObjCreate("Shell.Application")

			; Make backup of current folder
			if !Instr(FileExist(Backup_Temp:= A_Temp "\Backup " regexreplace(a_scriptname, "\..*$") " - " StrReplace(loVersion,".","_")),"D")
				FileCreateDir, % Backup_Temp
			else
			{
				FileDelete, % Backup_Temp
				FileCreateDir, % Backup_Temp
			}
			; Gui +OwnDialogs
			MsgBox 0x34, `% this.Name " - " "New Update Available", Last Chance to abort Update.`n`n(also remove this once you're done debugging the updater)`nDo you want to continue the Update?
			IfMsgBox Yes 
			{
				Err:=CopyFolderAndContainingFiles(A_ScriptDir, Backup_Temp,1) 		;; backup current folder with all containing files to the backup pos. 
				, Err2:=CopyFolderAndContainingFiles(Backup_Temp ,A_ScriptDir,0) 	;; and then copy over the backup into the script folder as well
				, items1 := shell.Namespace(file).Items								;; and copy over any files not contained in a subfolder
				for item_ in items1 
				{

					;; if DataOnly ;; figure out how to detect and skip files based on directory, so that one can skip updating script and settings and so on, and only query the scripts' data-files 
					root := item_.Path
					, items:=shell.Namespace(root).Items
					for item in items
						shell.NameSpace(A_ScriptDir).CopyHere(item, 0x14)
				}
				MsgBox, 0x40040,,Update Finished
				FileRemoveDir, % Backup_Temp,1
				FileRemoveDir, % Update_Temp,1
				reload
			}
			Else IfMsgBox No
			{	; no update, cleanup the previously downloaded files from the tmp
				MsgBox, 0x40040,,Update Aborted
				FileRemoveDir, % Backup_Temp,1
				FileRemoveDir, % Update_Temp,1

			}
			if (err1 || err2)
			{
				;; todo: catch error
			}
		}
		
	}

	
	Autostart(status,UseRegistry:=0)
	{
		/**
		Function: Autostart
		This Adds the current script to the autorun section for the current
		user.

		Parameters:
		status - Autostart status
		         It can be either true or false.
		         Setting it to true would add the registry value.
		         Setting it to false would delete an existing registry value.
		*/
		if (UseRegistry)
		{
			if (status)
			{
				RegWrite, REG_SZ
						, HKCU\SOFTWARE\microsoft\windows\currentversion\run
						, %a_scriptname%
						, %a_scriptfullpath%
			}
			else
				regdelete, HKCU\SOFTWARE\microsoft\windows\currentversion\run
						, %a_scriptname%
		}
		else
		{
			startUpDir:=(A_Startup "\" A_ScriptName " - Shortcut.lnk")
			if (status) ; add to startup
				FileCreateShortcut, % A_ScriptFullPath, % startUpDir
			else
				FileDelete, % startUpDir
		}

		
	}

	
	Splash(img:="", speed:=10, pause:=2)
	{
		/**
		Function: Splash
		Shows a custom image as a splash screen with a simple fading animation

		Parameters:
		img   (opt) - file to be displayed
		speed (opt) - fast the fading animation will be. Higher value is faster.
		pause (opt) - long in seconds the image will be paused after fully displayed.
		*/
		global

			gui, splash: -caption +lastfound +border +alwaysontop +owner
		$hwnd := winexist(), alpha := 0
		winset, transparent, 0

		gui, splash: add, picture, x0 y0 vpicimage, % img
		guicontrolget, picimage, splash:pos
		gui, splash: show, w%picimagew% h%picimageh%

		setbatchlines 3
		loop, 255
		{
			if (alpha >= 255)
				break
			alpha += speed
			winset, transparent, %alpha%
		}

		; pause duration in seconds
		sleep pause * 1000

		loop, 255
		{
			if (alpha <= 0)
				break
			alpha -= speed
			winset, transparent, %alpha%
		}
		setbatchlines -1

		gui, splash:destroy
		return
	}

	
	Debug(level:=1, label:=">", msg:="", AddInfo:="",InvocationLine:="", vars*)
	{
		/**
		Funtion: Debug
		Allows sending conditional debug messages to the debugger and a log file filtered
		by the current debug level set on the object.

		Parameters:
		level - Debug Level, which can be:
		        * this.DBG_NONE
		        * this.DBG_ERRORS
		        * this.DBG_WARNINGS
		        * this.DBG_VERBOSE

		If you set the level for a particular message to *this.DBG_VERBOSE* this message
		wont be shown when the class debug level is set to lower than that (e.g. *this.DBG_WARNINGS*).

		label - Message label, mainly used to show the name of the function or label that triggered the message
		msg   - Arbitrary message that will be displayed on the debugger or logged to the log file
		vars* - Aditional parameters that whill be shown as passed. Useful to show variable contents to the debugger.

		Notes:
		The point of this function is to have all your debug messages added to your script and filter them out
		by just setting the object's dbgLevel variable once, which in turn would disable some types of messages.
		*/

		if !this.dbglevel
			return
		if (InvocationLine!="")
			DebugInvokedOn:="Source Code: Function invoked on line " RegexReplace(InvocationLine,"\D") "`nError invoked in function body of " " on line " Exception("",-1).Line
		for i,var in vars
		{
			if IsObject(var)
				var:=RegExReplace(ScriptObj_Obj2Str(var),"\.\d* = ","")
			varline .= "`n" var
		}
		dbgMessage := label " [invoked on " RegexReplace(InvocationLine,"\D") "]" "`n" DebugInvokedOn "`n>" msg "`n" varline

 		if (level <= this.dbglevel)
			outputdebug % dbgMessage
		else if this.dbgFile
			FileAppend, % dbgMessage, % this.dbgFile
		else
			MsgBox 0x10, % this.Name " - " "Error encountered: " this.Error.Error , % Clipboard:=dbgmessage
			; script.Error:={	 Level		:""
            ;     ,Label		:""
            ;     ,Message	:""	
            ;     ,Error		:""		
            ;     ,Vars		:[]
            ;     ,AddInfo	:""}
		script.ErrorCache[A_Now]:=script.Error
	}

	
	About(scriptName:="", version:="", author:="",credits:="", homepagetext:="", homepagelink:="", donateLink:="", email:="")
	{
		/**
		Function: About
		Shows a quick HTML Window based on the object's variable information

		Parameters:
		scriptName   (opt) - Name of the script which will be
		                     shown as the title of the window and the main header
		version      (opt) - Script Version in SimVer format, a "v"
		                     will be added automatically to this value
		author       (opt) - Name of the author of the script
		credits 	 (opt) - Name of credited people
		ghlink 		 (opt) - GitHubLink
		ghtext 		 (opt) - GitHubtext
		doclink 	 (opt) - DocumentationLink
		doctext 	 (opt) - Documentationtext
		forumlink    (opt) - forumlink
		forumtext    (opt) - forumtext
		homepagetext (opt) - Display text for the script website
		homepagelink (opt) - Href link to that points to the scripts
		                     website (for pretty links and utm campaing codes)
		donateLink   (opt) - Link to a donation site
		email        (opt) - Developer email

		Notes:
		The function will try to infer the paramters if they are blank by checking
		the class variables if provided. This allows you to set all information once
		when instatiating the class, and the about GUI will be filled out automatically.
		*/
		static doc
		scriptName := scriptName ? scriptName : this.name
		, version := version ? version : this.version
		, author := author ? author : this.author
		, credits := credits ? credits : this.credits
		, creditslink := creditslink ? creditslink : RegExReplace(this.creditslink, "http(s)?:\/\/")
		, ghtext := ghtext ? ghtext : RegExReplace(this.ghtext, "http(s)?:\/\/")
		, ghlink := ghlink ? ghlink : RegExReplace(this.ghlink, "http(s)?:\/\/")
		, doctext := doctext ? doctext : RegExReplace(this.doctext, "http(s)?:\/\/")
		, doclink := doclink ? doclink : RegExReplace(this.doclink, "http(s)?:\/\/")
		, forumtext := forumtext ? forumtext : RegExReplace(this.forumtext, "http(s)?:\/\/")
		, forumlink := forumlink ? forumlink : RegExReplace(this.forumlink, "http(s)?:\/\/")
		, homepagetext := homepagetext ? homepagetext : RegExReplace(this.homepagetext, "http(s)?:\/\/")
		, homepagelink := homepagelink ? homepagelink : RegExReplace(this.homepagelink, "http(s)?:\/\/")
		, donateLink := donateLink ? donateLink : RegExReplace(this.donateLink, "http(s)?:\/\/")
		, email := email ? email : this.email
		
 		if (donateLink)
		{
			donateSection =
			(
				<div class="donate">
					<p>If you like this tool please consider <a href="https://%donateLink%">donating</a>.</p>
				</div>
				<hr>
			)
		}

		html =
		(
			<!DOCTYPE html>
			<html lang="en" dir="ltr">
				<head>
					<meta charset="utf-8">
					<meta http-equiv="X-UA-Compatible" content="IE=edge">
					<style media="screen">
						.top {
							text-align:center;
						}
						.top h2 {
							color:#2274A5;
							margin-bottom: 5px;
						}
						.donate {
							color:#E83F6F;
							text-align:center;
							font-weight:bold;
							font-size:small;
							margin: 20px;
						}
						p {
							margin: 0px;
						}
					</style>
				</head>
				<body>
					<div class="top">
						<h2>%scriptName%</h2>
						<p>v%version%</p>
						<hr>
						<p>by %author%</p>
		)
		if ghlink and ghtext
		{
			sTmp=
			(

						<p><a href="https://%ghlink%" target="_blank">%ghtext%</a></p>
			)
			html.=sTmp
		}
		if doclink and doctext
		{
			sTmp=
			(

						<p><a href="https://%doclink%" target="_blank">%doctext%</a></p>
			)
			html.=sTmp
		}
		; Clipboard:=html
		if (creditslink and credits) || IsObject(credits) || RegexMatch(credits,"(?<Author>(\w|)*)(\s*\-\s*)(?<Snippet>(\w|\|)*)\s*\-\s*(?<URL>.*)")
		{
			if RegexMatch(credits,"(?<Author>(\w|)*)(\s*\-\s*)(?<Snippet>(\w|\|)*)\s*\-\s*(?<URL>.*)")
			{
				CreditsLines:=strsplit(credits,"`n")
				Credits:={}
				for k,v in CreditsLines
				{
					if ((InStr(v,"author1") && InStr(v,"snippetName1") && InStr(v,"URL1")) || (InStr(v,"snippetName2|snippetName3")))
						continue
					val:=strsplit(strreplace(v,"`t"," ")," - ")
					Credits[Trim(val.2)]:=Trim(val.1) "|" Trim((strlen(val.3)>5?val.3:""))
				}
			}
			; Clipboard:=html
			if IsObject(credits)  
			{
				if (1<0)
				{

					if (credits.Count()>0)
					{
						CreditsAssembly:="credits for used code:`n"
						for k,v in credits
						{
							if (k="")
								continue
							if (strsplit(v,"|").2="")
								CreditsAssembly.="<p>" k " - " strsplit(v,"|").1 "`n"
							else
								CreditsAssembly.="<p><a href=" """" strsplit(v,"|").2 """" ">" k " - " strsplit(v,"|").1 "</a></p>`n"
						}
						html.=CreditsAssembly
						; Clipboard:=html
					}
				}
				else
				{
					if (credits.Count()>0)
					{
						CreditsAssembly:="credits for used code:`n"
						for Author,v in credits
						{
							if (k="")
								continue
							if (strsplit(v,"|").2="")
								CreditsAssembly.="<p>" Author " - " strsplit(v,"|").1 "`n"
							else
							{
								Name:=strsplit(v,"|").1
								Credit_URL:=strsplit(v,"|").2
								if Instr(Author,",") && Instr(Credit_URL,",")
								{
									tmpAuthors:=""
									AllCurrentAuthors:=strsplit(Author,",")
									for s,w in strsplit(Credit_URL,",")
									{
										currentAuthor:=AllCurrentAuthors[s]
										tmpAuthors.="<a href=" """" w """" ">" trim(currentAuthor) "</a>"
										if (s!=AllCurrentAuthors.MaxIndex())
											tmpAuthors.=", "
									}
									CreditsAssembly.="<p>" tmpAuthors "</p> - " Name "`n" ;; figure out how to force this to be on one line, instead of the mess it is right now.
								}
								else
									CreditsAssembly.="<p><a href=" """" Credit_URL """" ">" Author " - " Name "</a></p>`n"
							}
						}
						html.=CreditsAssembly
						; Clipboard:=html
					}
				}
			}
			else
			{
				sTmp=
				(
							<p>credits: <a href="https://%creditslink%" target="_blank">%credits%</a></p>
							<hr>
				)
				html.=sTmp
			}
			; Clipboard:=html
		}
		if forumlink and forumtext
		{
			sTmp=
			(

						<p><a href="https://%forumlink%" target="_blank">%forumtext%</a></p>
			)
			html.=sTmp
			; Clipboard:=html
		}
		if homepagelink and homepagetext
		{
			sTmp=
			(

						<p><a href="https://%homepagelink%" target="_blank">%homepagetext%</a></p>

			)
			html.=sTmp
			; Clipboard:=html
		}
		sTmp=
		(

								</div>
					%donateSection%
				</body>
			</html>
		)
		html.=sTmp
 		btnxPos := 300/2 - 75/2
		, axHight:=12
		, donateHeight := donateLink ? 6 : 0
		, forumHeight := forumlink ? 1 : 0
		, ghHeight := ghlink ? 1 : 0
		, creditsHeight := creditslink ? 1 : 0
		, creditsHeight+= (credits.Count()>0)?credits.Count()*1.5:0 ; + d:=(credits.Count()>0?2.5:0)
		, homepageHeight := homepagelink ? 1 : 0
		, docHeight := doclink ? 1 : 0
		, axHight+=donateHeight
		, axHight+=forumHeight
		, axHight+=ghHeight
		, axHight+=creditsHeight
		, axHight+=homepageHeight
		, axHight+=docHeight
		if (axHight="")
			axHight:=12
		gui aboutScript:new, +alwaysontop +toolwindow, % "About " this.name
		gui margin, 2
		gui color, white
		gui add, activex, w500 r%axHight% vdoc, htmlFile
		gui add, button, w75 x%btnxPos% gaboutClose, % "&Close"
		doc.write(html)
		gui show, AutoSize
		return

		aboutClose:
		gui aboutScript:destroy
		return
	}

	
	GetLicense()
	{
		/*
		Function: GetLicense
		Parameters:
		Notes:
		*/
		this.systemID := this.GetSystemID()
		cleanName := RegexReplace(A_ScriptName, "\..*$")
		for i,value in ["Type", "License"]
			RegRead, %value%, % "HKCU\SOFTWARE\" cleanName, % value

		if (!License)
		{
			MsgBox, % 0x4 + 0x20
			      , % "No license"
			      , % "Seems like there is no license activated on this computer.`n"
			        . "Do you have a license that you want to activate now?"

			IfMsgBox, Yes
			{
				Gui, license:new
				Gui, add, Text, w160, % "Paste the License Code here"
				Gui, add, Edit, w160 vLicenseNumber
				Gui, add, Button, w75 vTest, % "Save"
				Gui, add, Button, w75 x+10, % "Cancel"
				Gui, show

				saveFunction := Func("licenseButtonSave").bind(this)
				GuiControl, +g, test, % saveFunction
				Exit
			}

			MsgBox, % 0x30
			      , % "Unable to Run"
			      , % "This program cannot run without a license."

			ExitApp, 1
		}

		return {"type"    : Type
		       ,"number"  : License}
	}

	
	SaveLicense(licenseType, licenseNumber)
	{
		/*
		Function: SaveLicense
		Parameters:
		Notes:
		*/
		cleanName := RegexReplace(A_ScriptName, "\..*$")

		Try
		{
			RegWrite, % "REG_SZ"
			        , % "HKCU\SOFTWARE\" cleanName
			        , % "Type", % licenseType

			RegWrite, % "REG_SZ"
			        , % "HKCU\SOFTWARE\" cleanName
			        , % "License", % licenseNumber

			return true
		}
		catch
			return false
	}

	
	IsLicenceValid(licenseType, licenseNumber, URL)
	{
		/*
		Function: IsLicenceValid
		Parameters:
		Notes:
		*/
		res := this.EDDRequest(URL, "check_license", licenseType ,licenseNumber)

		if InStr(res, """license"":""inactive""")
			res := this.EDDRequest(URL, "activate_license", licenseType ,licenseNumber)

		if InStr(res, """license"":""valid""")
			return true
		else
			return false
	}

	GetSystemID()
	{
		wmi := ComObjGet("winmgmts:{impersonationLevel=impersonate}!\\" A_ComputerName "\root\cimv2")
		(wmi.ExecQuery("Select * from Win32_BaseBoard")._newEnum)[Computer]
		return Computer.SerialNumber
	}

	
	EDDRequest(URL, Action, licenseType, licenseNumber)
	{
		/*
		Function: EDDRequest
		Parameters:
		Notes:
		*/
		strQuery := url "?edd_action=" Action
		         .  "&item_id=" licenseType
		         .  "&license=" licenseNumber
		         .  (this.systemID ? "&url=" this.systemID : "")

		try
		{
			http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			, http.Open("GET", strQuery)
			, http.SetRequestHeader("Pragma", "no-cache")
			, http.SetRequestHeader("Cache-Control", "no-cache, no-store")
			, http.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible; Win32)")
			, http.Send()
			, http.WaitForResponse()

			return http.responseText
		}
		catch err
			return err.what ":`n" err.message
	}

/*

	Activate()
	{
		strQuery := this.strEddRootUrl . "?edd_action=activate_license&item_id=" . this.strRequestedProductId . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId
		strJSON := Url2Var(strQuery)
		Diag(A_ThisFunc . " strQuery", strQuery, "")
		Diag(A_ThisFunc . " strJSON", strJSON, "")
		return JSON.parse(strJSON)
	}
	Deactivate()
	{
		Loop, Parse, % "/|", |
		{
			strQuery := this.strEddRootUrl . "?edd_action=deactivate_license&item_id=" . this.strRequestedProductId . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId . A_LoopField
			strJSON := Url2Var(strQuery)
			Diag(A_ThisFunc . " strQuery", strQuery, "")
			Diag(A_ThisFunc . " strJSON", strJSON, "")
			this.oLicense := JSON.parse(strJSON)
			if (this.oLicense.success)
			break	
		}
	}

	GetVersion()
	{
		strQuery := this.strEddRootUrl . "?edd_action=get_version&item_id=" . this.oLicense.item_id . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId
		strJSON := Url2Var(strQuery)
		Diag(A_ThisFunc . " strQuery", strQuery, "")
		Diag(A_ThisFunc . " strJSON", strJSON, "")
		return JSON.parse(strJSON)
	}

	RenewLink()
	{
		strUrl := this.strEddRootUrl . "checkout/?edd_license_key=" . this.strEddLicense . "&download_id=" . this.oLicense.item_id
		Diag(A_ThisFunc . " strUrl", strUrl, "")
		return strUrl
	}

*/

	Load(INI_File:="", bSilentReturn:=0)
	{
		if (INI_File="")
			INI_File:=this.configfile
		Result := []
		, OrigWorkDir:=A_WorkingDir
		if (d_fWriteINI_st_count(INI_File,".ini")>0)
		{
			INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ;; reduce number of ".ini"-patterns to 1
			if (d_fWriteINI_st_count(INI_File,".ini")>0)
				INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ;		 and remove the last instance
		}
			if !FileExist(INI_File ".ini") ;; create new INI_File if not existing
			{
				if !bSilentReturn
					msgbox, 8240,% this.Name " -  No Save File found", % "No save file was found.`nPlease reinitialise settings if possible."
				return false
			}
			SplitPath, INI_File, INI_File_File, INI_File_Dir, INI_File_Ext, INI_File_NNE, INI_File_Drive
			if !Instr(d:=FileExist(INI_File_Dir),"D:")
				FileCreateDir, % INI_File_Dir
			if !FileExist(INI_File_File ".ini") ;; check for ini-file file ending
				FileAppend,, % INI_File ".ini"
			SetWorkingDir, INI-Files
			IniRead, SectionNames, % INI_File ".ini"
			for each, Section in StrSplit(SectionNames, "`n") {
				IniRead, OutputVar_Section, % INI_File ".ini", %Section%
				for each, Haystack in StrSplit(OutputVar_Section, "`n")
				{
					If (Instr(Haystack,"="))
					{
						RegExMatch(Haystack, "(.*?)=(.*)", $)
						, Result[Section, $1] := $2
					}
					else
						Result[Section, Result[Section].MaxIndex()+1]:=Haystack
				}
			}
			if A_WorkingDir!=OrigWorkDir
				SetWorkingDir, %OrigWorkDir%
			this.config:=Result
		return (this.config.Count()?true:-1) ; returns true if this.config contains values. returns -1 otherwhise to distinguish between a missing config file and an empty config file
	}
	Save(INI_File:="")
	{
		if (INI_File="")
			INI_File:=this.configfile
		SplitPath, INI_File, INI_File_File, INI_File_Dir, INI_File_Ext, INI_File_NNE, INI_File_Drive
		if (d_fWriteINI_st_count(INI_File,".ini")>0)
		{
			INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ; reduce number of ".ini"-patterns to 1
			if (d_fWriteINI_st_count(INI_File,".ini")>0)
				INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ; and remove the last instance
		}
		if !Instr(d:=FileExist(INI_File_Dir),"D:")
			FileCreateDir, % INI_File_Dir
		if !FileExist(INI_File_File ".ini") ; check for ini-file file ending
			FileAppend,, % INI_File ".ini"
		for SectionName, Entry in this.config
		{
			Pairs := ""
			for Key, Value in Entry
			{
				WriteInd++
				if !Instr(Pairs,Key "=" Value "`n")
					Pairs .= Key "=" Value "`n"
			}
			IniWrite, %Pairs%, % INI_File ".ini", %SectionName%
		}
 	}
}

d_fWriteINI_st_removeDuplicates(string, delim="`n")
{ ; remove all but the first instance of 'delim' in 'string'
	; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
	/*
		RemoveDuplicates
		Remove any and all consecutive lines. A "line" can be determined by
		the delimiter parameter. Not necessarily just a `r or `n. But perhaps
		you want a | as your "line".

		string = The text or symbols you want to search for and remove.
		delim  = The string which defines a "line".

		example: st_removeDuplicates("aaa|bbb|||ccc||ddd", "|")
		output:  aaa|bbb|ccc|ddd
	*/
	delim:=RegExReplace(delim, "([\\.*?+\[\{|\()^$])", "\$1")
	Return RegExReplace(string, "(" delim ")+", "$1")
}
d_fWriteINI_st_count(string, searchFor="`n")
{ ; count number of occurences of 'searchFor' in 'string'
	; copy of the normal function to avoid conflicts.
	; from StringThings-library by tidbit, Version 2.6 (Fri May 30, 2014)
	/*
		Count
		Counts the number of times a tolken exists in the specified string.

		string    = The string which contains the content you want to count.
		searchFor = What you want to search for and count.

		note: If you're counting lines, you may need to add 1 to the results.

		example: st_count("aaa`nbbb`nccc`nddd", "`n")+1 ; add one to count the last line
		output:  4
	*/
	StringReplace, string, string, %searchFor%, %searchFor%, UseErrorLevel
	return ErrorLevel
}

	




licenseButtonSave(this, CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="")
{
	GuiControlGet, LicenseNumber
	if this.IsLicenceValid(this.eddID, licenseNumber, "https://www.the-automator.com")
	{
		this.SaveLicense(this.eddID, LicenseNumber)
		MsgBox, % 0x30
		      , % "License Saved"
		      , % "The license was applied correctly!`n"
		        . "The program will start now."
		
		Reload
	}
	else
	{
		MsgBox, % 0x10
		      , % "Invalid License"
		      , % "The license you entered is invalid and cannot be activated."

		ExitApp, 1
	}
}
licenseButtonCancel(CtrlHwnd, GuiEvent, EventInfo, ErrLevel:="")
{
	MsgBox, % 0x30
	      , % "Unable to Run"
	      , % "This program cannot run without a license."

	ExitApp, 1
}


CopyFolderAndContainingFiles(SourcePattern, DestinationFolder, DoOverwrite = false)
{
	; Copies all files and folders matching SourcePattern into the folder named DestinationFolder and
	; returns the number of files/folders that could not be copied.
    ; First copy all the files (but not the folders):
    ; FileCopy, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ; ErrorCount := ErrorLevel
    ; Now copy all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
        FileCopyDir, % A_LoopFileFullPath, % DestinationFolder "\" A_LoopFileName , % DoOverwrite
        ErrorCount += ErrorLevel
        if ErrorLevel  ; Report each problem folder by name.
            MsgBox,% "Could not copy " A_LoopFileFullPath " into " DestinationFolder "."
    }
    return ErrorCount
}

ttip_ScriptObj(text:="TTIP: Test",mode:=1,to:=4000,xp:="NaN",yp:="NaN",CoordMode:=-1,to2:=1750,Times:=20,currTip:=20)
{
	/*
		v.0.2.1
		Date: 24 Juli 2021 19:40:56: 
		
		Modes:  
		1: remove tt after "to" milliseconds 
		2: remove tt after "to" milliseconds, but show again after "to2" milliseconds. Then repeat 
		3: not sure anymore what the plan was lol - remove 
		4: shows tooltip slightly offset from current mouse, does not repeat
		5: keep that tt until the function is called again  

		CoordMode:
		-1: Default: currently set behaviour
		1: Screen
		2: Window

		to: 
		Timeout in milliseconds
		
		xp/yp: 
		xPosition and yPosition of tooltip. 
		"NaN": offset by +50/+50 relative to mouse
		IF mode=4, 
		----  Function uses tooltip 20 by default, use parameter
		"currTip" to select a tooltip between 1 and 20. Tooltips are removed and handled
		separately from each other, hence a removal of ttip20 will not remove tt14 

		---
		v.0.2.1
		- added Obj2Str-Conversion via "ScriptObj_Obj2Str()"
		v.0.1.1 
		- Initial build, 	no changelog yet
	
	*/
	
	;if (text="TTIP: Test")
		;m(to)
		cCoordModeTT:=A_CoordModeToolTip
	if (text="") || (text=-1)
		gosub, lScriptObj_TTIP_Removettip
	if IsObject(text)
		text:=ScriptObj_Obj2Str(text)
	static ttip_text
	static lastcall_tip
	static currTip2
	global ttOnOff
	currTip2:=currTip
	cMode:=(CoordMode=1?"Screen":(CoordMode=2?"Window":cCoordModeTT))
	CoordMode, % cMode
	tooltip,

	
	ttip_text:=text
	lUnevenTimers:=false 
	MouseGetPos,xp1,yp1
	if (mode=4) ; set text offset from cursor
	{
		yp:=yp1+15
		xp:=xp1
	}	
	else
	{
		if (xp="NaN")
			xp:=xp1 + 50
		if (yp="NaN")
			yp:=yp1 + 50
	}
	tooltip, % ttip_text,xp,yp,% currTip
	if (mode=1) ; remove after given time
	{
		SetTimer, lScriptObj_TTIP_Removettip, % "-" to
	}
	else if (mode=2) ; remove, but repeatedly show every "to"
	{
		; gosub,  A
		global to_1:=to
		global to2_1:=to2
		global tTimes:=Times
		Settimer,lScriptObj_TTIP_SwitchOnOff,-100
	}
	else if (mode=3)
	{
		lUnevenTimers:=true
		SetTimer, lScriptObj_RpeatedShow, %  to
	}
	else if (mode=5) ; keep until function called again
	{
		
	}
	CoordMode, % cCoordModeTT
	return text
	lScriptObj_TTIP_SwitchOnOff:
	ttOnOff++
	if mod(ttOnOff,2)	
	{
		gosub, lScriptObj_TTIP_Removettip
		sleep, % to_1
	}
	else
	{
		tooltip, % ttip_text,xp,yp,% currTip
		sleep, % to2_1
	}
	if (ttOnOff>=ttimes)
	{
		Settimer, lScriptObj_TTIP_SwitchOnOff, off
		gosub, lScriptObj_TTIP_Removettip
		return
	}
	Settimer, lScriptObj_TTIP_SwitchOnOff, -100
	return

	lScriptObj_RpeatedShow:
	ToolTip, % ttip_text,,, % currTip2
	if lUnevenTimers
		sleep, % to2
	Else
		sleep, % to
	return
	lScriptObj_TTIP_Removettip:
	ToolTip,,,,currTip2
	return
}
ScriptObj_Obj2Str(Obj,FullPath:=1,BottomBlank:=0){
	static String,Blank
	if(FullPath=1)
		String:=FullPath:=Blank:=""
	if(IsObject(Obj)){
		for a,b in Obj{
			if(IsObject(b))
				ScriptObj_Obj2Str(b,FullPath "." a,BottomBlank)
			else{
				if(BottomBlank=0)
					String.=FullPath "." a " = " b "`n"
				else if(b!="")
					String.=FullPath "." a " = " b "`n"
				else
					Blank.=FullPath "." a " =`n"
			}
	}}
	return String Blank
}
ScriptObj_IsConnected(URL="https://autohotkey.com/boards/") {                            	;-- Returns true if there is an available internet connection
	return DllCall("Wininet.dll\InternetCheckConnection", "Str", URL,"UInt", 1, "UInt",0, "UInt")
}
OnMsgBoxScriptObj() {
						DetectHiddenWindows, On
						Process, Exist
						If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
							ControlSetText Button2, Retry
						}
					}