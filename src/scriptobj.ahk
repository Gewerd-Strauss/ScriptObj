/**
 * =============================================================================================== *
 * @Author           : RaptorX   <graptorx@gmail.com>
 * @Script Name      : Script Object
 * @Script Version   : 0.1.0
 * @Homepage         :
 *
 * @Creation Date    : November 09, 2020
 *
 * @Description      :
 * -------------------
 * This is an object used to have a few common functions between scripts
 * Those are functions related to script information, upgrade and configuration.
 *
 * =============================================================================================== *
 */

; SuperGlobal variables
global null:="",sec:=1000,min:=60*sec,hour:=60*min

class script
{
	name        := ""
    version     := ""
    author      := ""
    email       := ""
    homepage    := ""
    conf        := ""

	/**
	 * Function: Update
	 * This function checks for the current script version
	 * Downloads the remote version information
	 * Compares and automatically downloads the new script file and reloads the script.
	 *
	 * Parameters:
	 * vfile	-	Version File
	 *				This is the remote version file to be validated against.
	 * rfile	-	Remote File
	 *				This is the remote script file to be downloaded and installed if a new version is found.
	 *				It should be a zip file that will be unzipped by the function
	 *
	 * Notes:
	 * The versioning file should only contain a version string and nothing else.
	 * The matching will be performed against a SemVer format and only the three
	 * major components will be taken into account.
	 *
	 * e.g. '1.0.0'
	 *
	 * For more information about SemVer and its specs click here: <https://semver.org/>
	 */
	update(vfile, rfile){
		; Check if we are connected to the internet
		; Download remote version file
		; Save information to variable
		; Compare against current stated version
		; If new version ask user what to do
		; Create lock file
		; Download zip file
		; Extract zip file to temporal folder

		; if is compiled
		 	; Create batch file
		; else
			; Create script file

		; [script/batch contents]
		; Wait for lock file to be released
		; Sleep for 500ms just in case
		; Copy all files to current script directory
		; Cleanup temporal files
		; Run main script
		; EOF

		; Run temporal update script
		; Delete lock file
		; Stop current script
	 }
}
