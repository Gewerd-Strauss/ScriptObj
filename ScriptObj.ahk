; last edited by Gewerd Strauss @ 27.11.2021
; from RaptorX https://github.com/RaptorX/ScriptObj/blob/master/ScriptObj.ahk
/**
 * ============================================================================ *
 * @Author           : RaptorX <graptorx@gmail.com>
 * @Script Name      : Script Object
 * @Script Version   : 0.20.3
 * @Homepage         :
 *
 * @Creation Date    : November 09, 2020
 * @Modification Date: July 02, 2021
 * @Modification G.S.: 06.2022
 ; @Description Modification G.S.: added field for GitHub-link, a Forum-link 
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

; Template
; global script := {base         : script
;                  ,name         : regexreplace(A_ScriptName, "\.\w+")
;                  ,version      : "0.1.0"
;                  ,author       : ""
;                  ,email        : ""
;                  ,credits      : ""
;                  ,creditslink  : ""
;                  ,crtdate      : ""
;                  ,moddate      : ""
;                  ,homepagetext : ""
;                  ,homepagelink : ""
;                  ,ghlink       : ""
;                  ,ghtext 		 : ""
;                  ,doclink      : ""
;                  ,doctext		 : ""
;                  ,forumlink    : ""
;                  ,forumtext	 : ""
;                  ,donateLink   : ""
;                  ,resfolder    : A_ScriptDir "\res"
;                  ,iconfile     : A_ScriptDir "\res\sct.ico"
;                  ,configfile   : A_ScriptDir "\settings.ini"
;                  ,configfolder : A_ScriptDir ""
; 				   }

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
        ,creditslink  := ""
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
		        Should be a zip file that will be unzipped by the function

		Notes:
		The versioning file should only contain a version string and nothing else.
		The matching will be performed against a SemVer format and only the three
		major components will be taken into account.

		e.g. '1.0.0'

		For more information about SemVer and its specs click here: <https://semver.org/>
	*/
	Update(vfile:="", rfile:="",bPointsToZip:=0)
	{
		vfile:=(vfile=="")?this.vfile:vfile
		rfile:=(rfile=="")?this.rfile:rfile
		; Error Codes
		static ERR_INVALIDVFILE := 1
			,ERR_INVALIDRFILE       := 2
			,ERR_NOCONNECT          := 3
			,ERR_NORESPONSE         := 4
			,ERR_INVALIDVER         := 5
			,ERR_CURRENTVER         := 6
			,ERR_MSGTIMEOUT         := 7
			,ERR_USRCANCEL          := 8
		if bPointsToZip
		{ ;; only allow downloading ZIP's
			; A URL is expected in this parameter, we just perform a basic check
			; TODO make a more robust match
			if (!regexmatch(vfile, "^((?:http(?:s)?|ftp):\/\/)?((?:[a-z0-9_\-]+\.)+.*$)"))
				throw {code: ERR_INVALIDVFILE, msg: "Invalid URL`n`nThe version file parameter must point to a 	valid URL."}

			; This function expects a ZIP file
			if (!regexmatch(rfile, "\.zip"))
				throw {code: ERR_INVALIDRFILE, msg: "Invalid Zip`n`nThe remote file parameter must point to a zip file."}

			; Check if we are connected to the internet
			http := comobjcreate("WinHttp.WinHttpRequest.5.1")
			http.Open("GET", "https://www.google.com", true)
			http.Send()
			try
				http.WaitForResponse(1)
			catch e
				throw {code: ERR_NOCONNECT, msg: e.message}

			Progress, 50, 50/100, % "Checking for updates", % "Updating"

			; Download remote version file
			http.Open("GET", vfile, true)
			http.Send(), http.WaitForResponse()

			if !(http.responseText)
			{
				Progress, OFF
				throw {code: ERR_NORESPONSE, msg: "There was an error trying to download the ZIP file.`n"
												. "The server did not respond."}
			}
			regexmatch(this.version, "\d+\.\d+\.\d+", loVersion)
			regexmatch(http.responseText, "\d+\.\d+\.\d+", remVersion)

			Progress, 100, 100/100, % "Checking for updates", % "Updating"
			sleep 500 	; allow progress to update
			Progress, OFF

			; Make sure SemVer is used
			if (!loVersion || !remVersion)
				throw {code: ERR_INVALIDVER, msg: "Invalid version.`nThis function works with SemVer. "
												. "For more information refer to the documentation in the function"}

			; Compare against current stated version
			ver1 := strsplit(loVersion, ".")
			ver2 := strsplit(remVersion, ".")

			for i1,num1 in ver1
			{
				for i2,num2 in ver2
				{
					if (newversion)
						break

					if (i1 == i2)
						if (num2 > num1)
						{
							newversion := true
							break
						}
						else
							newversion := false
				}
			}

			if (!newversion)
				throw {code: ERR_CURRENTVER, msg: "You are using the latest version"}
			else
			{
				; If new version ask user what to do
				; Yes/No | Icon Question | System Modal
				msgbox % 0x4 + 0x20 + 0x1000
					, % "New Update Available"
					, % "There is a new update available for this application.`n"
					. "Do you wish to upgrade to v" remVersion "?"
					, 10	; timeout

				ifmsgbox timeout
					throw {code: ERR_MSGTIMEOUT, msg: "The Message Box timed out."}
				ifmsgbox no
					throw {code: ERR_USRCANCEL, msg: "The user pressed the cancel button."}

				; Create temporal dirs
				ghubname := (InStr(rfile, "github") ? regexreplace(a_scriptname, "\..*$") "-latest\" : "")
				filecreatedir % tmpDir := a_temp "\" regexreplace(a_scriptname, "\..*$")
				filecreatedir % zipDir := tmpDir "\uzip"

				; Create lock file
				fileappend % a_now, % lockFile := tmpDir "\lock"

				; Download zip file
				urldownloadtofile % rfile, % tmpDir "\temp.zip"

				; Extract zip file to temporal folder
				oShell := ComObjCreate("Shell.Application")
				oDir := oShell.NameSpace(zipDir), oZip := oShell.NameSpace(tmpDir "\temp.zip")
				oDir.CopyHere(oZip.Items), oShell := oDir := oZip := ""

				filedelete % tmpDir "\temp.zip"

				/*
				******************************************************
				* Wait for lock file to be released
				* Copy all files to current script directory
				* Cleanup temporal files
				* Run main script
				* EOF
				*******************************************************
				*/
				if (a_iscompiled){
					tmpBatch =
					(Ltrim
						:lock
						if not exist "%lockFile%" goto continue
						timeout /t 10
						goto lock
						:continue

						xcopy "%zipDir%\%ghubname%*.*" "%a_scriptdir%\" /E /C /I /Q /R /K /Y
						if exist "%a_scriptfullpath%" cmd /C "%a_scriptfullpath%"

						cmd /C "rmdir "%tmpDir%" /S /Q"
						exit
					)
					fileappend % tmpBatch, % tmpDir "\update.bat"
					run % a_comspec " /c """ tmpDir "\update.bat""",, hide
				}
				else
				{
					tmpScript =
					(Ltrim
						while (fileExist("%lockFile%"))
							sleep 10

						FileCopyDir %zipDir%\%ghubname%, %a_scriptdir%, true
						FileRemoveDir %tmpDir%, true

						if (fileExist("%a_scriptfullpath%"))
							run %a_scriptfullpath%
						else
							msgbox `% 0x10 + 0x1000
								, `% "Update Error"
								, `% "There was an error while running the updated version.``n"
									. "Try to run the program manually."
								,  10
							exitapp
					)
					fileappend % tmpScript, % tmpDir "\update.ahk"
					run % a_ahkpath " " tmpDir "\update.ahk"
				}
				filedelete % lockFile
				exitapp
			}
		}
		else ;;; I guess I don't need this anymore, as GH automatically serves zips.
		{
			; 1. Update local vfile

			; FileDelete, % this.vfile_local
			; Error Codes
			if (!regexmatch(vfile, "^((?:http(?:s)?|ftp):\/\/)?((?:[a-z0-9_\-]+\.)+.*$)"))
				exception({code: ERR_INVALIDVFILE, msg: "Invalid URL`n`nThe version file parameter must point to a 	valid URL."})

			; This function expects a ZIP file
			if (!regexmatch(rfile, "\.zip"))
				exception({code: ERR_INVALIDRFILE, msg: "Invalid Zip`n`nThe remote file parameter must point to a zip file."})

			; A URL is expected in this parameter, we just perform a basic check
			; TODO make a more robust match
			if (!regexmatch(vfile, "^((?:http(?:s)?|ftp):\/\/)?((?:[a-z0-9_\-]+\.)+.*$)"))
				throw {code: ERR_INVALIDVFILE, msg: "Invalid URL`n`nThe version file parameter must point to a 	valid URL."}

			; This function does NOT expect a ZIP file
			if (rfile="") || (!regexmatch(rfile, "^((?:http(?:s)?|ftp):\/\/)?((?:[a-z0-9_\-]+\.)+.*$)"))
				throw {code: ERR_INVALIDRFILE, msg: "Invalid URL`n`nThe remote file parameter must point to a valid URL."}
			; Check if we are connected to the internet
			http := comobjcreate("WinHttp.WinHttpRequest.5.1")
			http.Open("GET", "https://www.google.com", true)
			http.Send()
			try
				http.WaitForResponse(1)
			catch e
				throw {code: ERR_NOCONNECT, msg: e.message}

			Progress, 50, 50/100, % "Checking for updates", % "Updating"

			; Download remote version file
			http.Open("GET", vfile, true)
			http.Send(), http.WaitForResponse()

			if !(http.responseText)
			{
				Progress, OFF
				throw {code: ERR_NORESPONSE, msg: "There was an error trying to download the ZIP file.`n"
												. "The server did not respond."}
			}
			; regexmatch(this.version, "\d+\.\d+\.\d+", loVersion)		;; as this version is not updated automatically, instead read the local version file
			
			FileRead, loVersion,% A_ScriptDir "\version.ini"
			regexmatch(http.responseText, "\d+\.\d+\.\d+", remVersion)

			Progress, 100, 100/100, % "Checking for updates", % "Updating"
			sleep 500 	; allow progress to update
			Progress, OFF

			; Make sure SemVer is used
			if (!loVersion || !remVersion)
				throw {code: ERR_INVALIDVER, msg: "Invalid version.`nThis function works with SemVer. "
												. "For more information refer to the documentation in the function"}

			; Compare against current stated version
			ver1 := strsplit(loVersion, ".")
			ver2 := strsplit(remVersion, ".")

			for i1,num1 in ver1
			{
				for i2,num2 in ver2
				{
					if (newversion)
						break

					if (i1 == i2)
						if (num2 > num1)
						{
							newversion := true
							break
						}
						else
							newversion := false
				}
			}

			if (!newversion)
				throw {code: ERR_CURRENTVER, msg: "You are using the latest version"}
			else
			{
				; If new version ask user what to do
				; Yes/No | Icon Question | System Modal
				msgbox % 0x4 + 0x20 + 0x1000
					, % "New Update Available"
					, % "There is a new update available for this application.`n"
					. "Do you wish to upgrade to v" remVersion "?"
					, 10	; timeout

				ifmsgbox timeout
					throw {code: ERR_MSGTIMEOUT, msg: "The Message Box timed out."}
				ifmsgbox no
					throw {code: ERR_USRCANCEL, msg: "The user pressed the cancel button."}

				; Create temporal dirs
				ghubname := (InStr(rfile, "github") ? regexreplace(a_scriptname, "\..*$") "-latest\" : "")
				filecreatedir % tmpDir := a_temp "\" regexreplace(a_scriptname, "\..*$")
				filecreatedir % zipDir := tmpDir "\uzip"

				; Create lock file
				fileappend % a_now, % lockFile := tmpDir "\lock"

				; Download zip file
				urldownloadtofile % rfile, % clipboard:= tmpDir "\temp.zip"

				; Extract zip file to temporal folder
				oShell := ComObjCreate("Shell.Application")
				oDir := oShell.NameSpace(zipDir), oZip := oShell.NameSpace(tmpDir "\temp.zip")
				oDir.CopyHere(oZip.Items)
				oShell := oDir := oZip := ""

				filedelete % tmpDir "\temp.zip"

				/*
				******************************************************
				* Wait for lock file to be released
				* Copy all files to current script directory
				* Cleanup temporal files
				* Run main script
				* EOF
				*******************************************************
				*/
				if (a_iscompiled){
					tmpBatch =
					(Ltrim
						:lock
						if not exist "%lockFile%" goto continue
						timeout /t 10
						goto lock
						:continue

						xcopy "%zipDir%\%ghubname%*.*" "%a_scriptdir%\" /E /C /I /Q /R /K /Y
						if exist "%a_scriptfullpath%" cmd /C "%a_scriptfullpath%"

						cmd /C "rmdir "%tmpDir%" /S /Q"
						exit
					)
					fileappend % tmpBatch, % tmpDir "\update.bat"
					run % a_comspec " /c """ tmpDir "\update.bat""",, hide
				}
				else
				{
					tmpScript =
					(Ltrim
						while (fileExist("%lockFile%"))
							sleep 10
						FileCopyDir %zipDir%\%ghubname%, %a_scriptdir%, true
						FileRemoveDir %tmpDir%, true

						if (fileExist("%a_scriptfullpath%"))
							run %a_scriptfullpath%
						else
							msgbox `% 0x10 + 0x1000
								, `% "Update Error"
								, `% "There was an error while running the updated version.``n"
									. "Try to run the program manually."
								,  10
							exitapp
					)
					fileappend % tmpScript, % tmpDir "\update.ahk"
					FileRead, Clipboard,% tmpScript
					run % a_ahkpath " " tmpDir "\update.ahk"
				}
				filedelete % lockFile
				exitapp
			}
		}
	}

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
	Autostart(status)
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

	/**
		Function: Splash
		Shows a custom image as a splash screen with a simple fading animation

		Parameters:
		img   (opt) - file to be displayed
		speed (opt) - fast the fading animation will be. Higher value is faster.
		pause (opt) - long in seconds the image will be paused after fully displayed.
	*/
	Splash(img:="", speed:=10, pause:=2)
	{
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
	Debug(level:=1, label:=">", msg:="", vars*)
	{
		if !this.dbglevel
			return

		for i,var in vars
			varline .= "|" var

		dbgMessage := label ">" msg "`n" varline

		if (level <= this.dbglevel)
			outputdebug % dbgMessage
		if (this.dbgFile)
			FileAppend, % dbgMessage, % this.dbgFile
	}

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
	About(scriptName:="", version:="", author:="",credits:="", homepagetext:="", homepagelink:="", donateLink:="", email:="")
	{
		static doc

		scriptName := scriptName ? scriptName : this.name
		version := version ? version : this.version
		author := author ? author : this.author
		credits := credits ? credits : this.credits
		creditslink := creditslink ? creditslink : RegExReplace(this.creditslink, "http(s)?:\/\/")
		ghtext := ghtext ? ghtext : RegExReplace(this.ghtext, "http(s)?:\/\/")
		ghlink := ghlink ? ghlink : RegExReplace(this.ghlink, "http(s)?:\/\/")
		doctext := doctext ? doctext : RegExReplace(this.doctext, "http(s)?:\/\/")
		doclink := doclink ? doclink : RegExReplace(this.doclink, "http(s)?:\/\/")
		forumtext := forumtext ? forumtext : RegExReplace(this.forumtext, "http(s)?:\/\/")
		forumlink := forumlink ? forumlink : RegExReplace(this.forumlink, "http(s)?:\/\/")
		homepagetext := homepagetext ? homepagetext : RegExReplace(this.homepagetext, "http(s)?:\/\/")
		homepagelink := homepagelink ? homepagelink : RegExReplace(this.homepagelink, "http(s)?:\/\/")
		donateLink := donateLink ? donateLink : RegExReplace(this.donateLink, "http(s)?:\/\/")
		email := email ? email : this.email

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
		if creditslink and credits
		{
			; Clipboard:=html
			sTmp=
			(

						<p>credits: <a href="https://%creditslink%" target="_blank">%credits%</a></p>
						<hr>
			)
			html.=sTmp
		}
		if forumlink and forumtext
		{
			sTmp=
			(

						<p><a href="https://%forumlink%" target="_blank">%forumtext%</a></p>
			)
			html.=sTmp
		}
		if homepagelink and homepagetext
		{
			sTmp=
			(

						<p><a href="https://%homepagelink%" target="_blank">%homepagetext%</a></p>

			)
			html.=sTmp
		}
		sTmp=
		(

								</div>
					%donateSection%
				</body>
			</html>
		)
		html.=sTmp
		; Clipboard:=html
		; html.= "`n
		; (
		; 	HEllo World
		; )"
		; Clipboard:=html
 		btnxPos := 300/2 - 75/2
		axHight:=12
		donateHeight := donateLink ? 6 : 0
		forumHeight := forumlink ? 1 : 0
		ghHeight := ghlink ? 1 : 0
		creditsHeight := creditslink ? 1 : 0
		homepageHeight := homepagelink ? 1 : 0
		docHeight := doclink ? 1 : 0
		axHight+=donateHeight
		axHight+=forumHeight
		axHight+=ghHeight
		axHight+=creditsHeight
		axHight+=homepageHeight
		axHight+=docHeight
		gui aboutScript:new, +alwaysontop +toolwindow, % "About " this.name
		gui margin, 2
		gui color, white
		gui add, activex, w300 r%axHight% vdoc, htmlFile
		gui add, button, w75 x%btnxPos% gaboutClose, % "&Close"
		doc.write(html)
		gui show, AutoSize
		return

		aboutClose:
			gui aboutScript:destroy
		return
	}

	/*
		Function: GetLicense
		Parameters:
		Notes:
	*/
	GetLicense()
	{
		global

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

	/*
		Function: SaveLicense
		Parameters:
		Notes:
	*/
	SaveLicense(licenseType, licenseNumber)
	{
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

	/*
		Function: IsLicenceValid
		Parameters:
		Notes:
	*/
	IsLicenceValid(licenseType, licenseNumber, URL)
	{
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

	/*
		Function: EDDRequest
		Parameters:
		Notes:
	*/
	EDDRequest(URL, Action, licenseType, licenseNumber)
	{
		strQuery := url "?edd_action=" Action
		         .  "&item_id=" licenseType
		         .  "&license=" licenseNumber
		         .  (this.systemID ? "&url=" this.systemID : "")

		try
		{
			http := ComObjCreate("WinHttp.WinHttpRequest.5.1")
			http.Open("GET", strQuery)
			http.SetRequestHeader("Pragma", "no-cache")
			http.SetRequestHeader("Cache-Control", "no-cache, no-store")
			http.SetRequestHeader("User-Agent", "Mozilla/4.0 (compatible; Win32)")

			http.Send()
			http.WaitForResponse()

			return http.responseText
		}
		catch err
			return err.what ":`n" err.message
	}

/*


	; Activate()
	; 	{
	; 	strQuery := this.strEddRootUrl . "?edd_action=activate_license&item_id=" . this.strRequestedProductId . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId
	; 	strJSON := Url2Var(strQuery)
	; 	Diag(A_ThisFunc . " strQuery", strQuery, "")
	; 	Diag(A_ThisFunc . " strJSON", strJSON, "")
	; 	return JSON.parse(strJSON)
	; 	}
	; Deactivate()
	; 	{
	; 	Loop, Parse, % "/|", |
	; 	{
	; 	strQuery := this.strEddRootUrl . "?edd_action=deactivate_license&item_id=" . this.strRequestedProductId . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId . A_LoopField
	; 	strJSON := Url2Var(strQuery)
	; 	Diag(A_ThisFunc . " strQuery", strQuery, "")
	; 	Diag(A_ThisFunc . " strJSON", strJSON, "")
	; 	this.oLicense := JSON.parse(strJSON)
	; 	if (this.oLicense.success)
	; 	break
	; 	}
	; 	}
	; GetVersion()
	; 	{
	; 	strQuery := this.strEddRootUrl . "?edd_action=get_version&item_id=" . this.oLicense.item_id . "&license=" . this.strEddLicense . "&url=" . this.strUniqueSystemId
	; 	strJSON := Url2Var(strQuery)
	; 	Diag(A_ThisFunc . " strQuery", strQuery, "")
	; 	Diag(A_ThisFunc . " strJSON", strJSON, "")
	; 	return JSON.parse(strJSON)
	; 	}
	; RenewLink()
	; 	{
	; 	strUrl := this.strEddRootUrl . "checkout/?edd_license_key=" . this.strEddLicense . "&download_id=" . this.oLicense.item_id
	; 	Diag(A_ThisFunc . " strUrl", strUrl, "")
	; 	return strUrl
	; 	}

*/

	Load(INI_File:="")
	{
		if (INI_File="")
			INI_File:=this.configfile
		Result := []
		OrigWorkDir:=A_WorkingDir
		if (d_fWriteINI_st_count(INI_File,".ini")>0)
		{
			INI_File:=d_fWriteINI_st_removeDuplicates(INI_File,".ini") ;. ".ini" ; reduce number of ".ini"-patterns to 1
			if (d_fWriteINI_st_count(INI_File,".ini")>0)
				INI_File:=SubStr(INI_File,1,StrLen(INI_File)-4) ; and remove the last instance
		}
		if !FileExist(INI_File) ;; create new INI_File if not existing
		{
			SplitPath, INI_File, INI_File_File, INI_File_Dir, INI_File_Ext, INI_File_NNE, INI_File_Drive
			if !Instr(d:=FileExist(INI_File_Dir),"D:")
				FileCreateDir, % INI_File_Dir
			if !FileExist(INI_File_File ".ini") ; check for ini-file file ending
				FileAppend,, % INI_File ".ini"
		}
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
				if !Instr(Pairs, "=" Value "`n")
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
