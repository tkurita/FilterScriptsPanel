(* shared script objects *)
property LibraryFolder : "IGAGURI HD:Users:tkurita:Factories:Script factory:ProjectsX:UnixScriptTools for mi:Library Scripts:"
property PathAnalyzer : load script file (LibraryFolder & "PathAnalyzer")
property StringEngine : load script file (LibraryFolder & "StringEngine")

property UtilityHandlers : missing value
property MessageUtility : missing value
property DefaultsManager : missing value

property ScriptListObj : missing value
property FilterPaletteController : missing value
property UnixScriptExecuter : missing value
property UnixScriptObj : missing value
property WindowController : missing value
property ScriptSorterObj : missing value
property NewFilterScriptObj : missing value
property FolderTableObj : missing value

(*shared constants *)
property dQ : ASCII character 34
property yenmark : ASCII character 92
property lineFeed : ASCII character 10
property idleTime : 1

(* shared variable *)
property isShouldShow : false
property FreeTime : 0 -- second
property DialogOwner : missing value
property currentAppName : missing value
-- property miAppRef : missing value

(* application setting *)
property lifeTime : 60 * 60 -- sec

(* events of application*)

on importScript(scriptName)
	--log "start importScript"
	--log scriptName
	tell main bundle
		set scriptPath to path for script scriptName extension "scpt"
	end tell
	--log "end importScript"
	return load script POSIX file scriptPath
end importScript

on launched theObject
	(*debug code*)
	--log "start launched"
	openWindow() of FilterPaletteController
	--openPanel() of NewFilterScriptObj
	(*end of debug code*)
end launched

on open theObject
	if class of theObject is record then
		set theCommandID to commandID of theObject
		try
			set optionRecord to argument of theObject
		on error
			set optionRecord to missing value
		end try
		
		if theCommandID is "ShowFilterScripts" then
			openWindow() of FilterPaletteController
		else if theCommandID is "Help" then
			call method "showHelp:"
		end if
		set FreeTime to 0
	end if
	--display dialog theCommandID
	return true
end open

on idle theObject
	--log "start idle"
	
	if (FreeTime) > lifeTime then
		quit
	end if
	
	if (isOpened of FilterPaletteController) then
		set frontAppPath to path to frontmost application as Unicode text
		set isShouldShow to (frontAppPath ends with (":" & currentAppName & ":")) or (frontAppPath ends with ":mi:")
		updateVisibility(isShouldShow) of FilterPaletteController
	else
		set FreeTime to FreeTime + idleTime
	end if
	
	return idleTime
end idle

on clicked theObject
	set theName to name of theObject
	if theName is "EditScript" then
		set theScript to getSelectedItem() of ScriptListObj
		tell application "Finder"
			open theScript
		end tell
	else if theName is "RenameScript" then
		renameScript() of ScriptListObj
	else if theName is "NewScript" then
		openPanel() of NewFilterScriptObj
	else if theName is "NewScriptOK" then
		makeNewScript() of NewFilterScriptObj
	else if theName is "NewScriptCancel" then
		closePanel() of NewFilterScriptObj
	end if
end clicked

on awake from nib theObject
	set theName to name of theObject
	--log "start awake from nib for " & theName
	if theName is "FilterScripts" then
		set hides when deactivated of theObject to false
		set floating of theObject to true
		
	else if theName is "scriptDataSource" then
		tell theObject
			make new data column at the end of the data columns with properties {name:"name"}
		end tell
	else if theName is "templateDataSource" then
		tell theObject
			make new data column at the end of the data columns with properties {name:"name"}
		end tell
	end if
	--log "end awake from nib"
end awake from nib

on double clicked theObject
	runFilterScript() of ScriptListObj
end double clicked

on dialog ended theObject with reply theReply
	if DialogOwner is "RenameScript" then
		doRename(theReply) of ScriptListObj
	else if DialogOwner is "NewScript" then
		--makeNewScript(theReply) of ScriptListObj
	end if
end dialog ended

on will finish launching theObject
	--log "start will finish launching"
	set DefaultsManager to importScript("DefaultsManager")
	
	set UtilityHandlers to importScript("UtilityHandlers")
	set MessageUtility to importScript("MessageUtility")
	
	set UnixScriptExecuter to importScript("UnixScriptExecuter")
	
	set ScriptSorterObj to importScript("ScriptSorterObj")
	set FolderTableObj to importScript("FolderTableObj")
	
	set ScriptListObj to importScript("ScriptListObj")
	set ScriptListObj to makeObj() of ScriptListObj
	set NewFilterScriptObj to importScript("NewFilterScriptObj")
	set NewFilterScriptObj to makeObj() of NewFilterScriptObj
	
	set WindowController to importScript("WindowController")
	set FilterPaletteController to importScript("FilterPaletteController")
	set FilterPaletteController to makeObj(window "FilterScripts") of FilterPaletteController
	
	--log "end of importScripts"
	--log (path to current application)
	tell application "System Events"
		set currentAppName to name of (path to current application)
	end tell
	
	--center window "Setting"
	--set miAppRef to path to application "mi" as alias
	--log "end finish launching"
end will finish launching

on will close theObject
	set theName to name of theObject
	if theName is "FilterScripts" then
		prepareClose() of FilterPaletteController
	end if
end will close

on should zoom theObject proposed bounds proposedBounds
	set theName to name of theObject
	if theName is "FilterScripts" then
		return toggleCollapsePanel of FilterPaletteController
	end if
end should zoom

on will quit theObject
	if isOpened of FilterPaletteController then
		prepareClose() of FilterPaletteController
	end if
end will quit

