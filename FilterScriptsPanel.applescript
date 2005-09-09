(* shared script objects *)
property LibraryFolder : "IGAGURI HD:Users:tkurita:Factories:Script factory:ProjectsX:UnixScriptTools for mi:Library Scripts:"
property PathAnalyzer : load script file (LibraryFolder & "PathAnalyzer")
property StringEngine : load script file (LibraryFolder & "StringEngine")

property UtilityHandlers : missing value
property MessageUtility : missing value
property DefaultsManager : missing value

property ScriptListObj : missing value
property UnixScriptExecuter : missing value
property ScriptSorterObj : missing value
property NewFilterScriptObj : missing value
property FolderTableObj : missing value
property SheetManager : missing value

(*shared constants *)
property dQ : ASCII character 34
property yenmark : ASCII character 92
property lineFeed : ASCII character 10

property isTaskRunning : false

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
	--log "start launched"
	openWindow() of ScriptListObj
	(*debug code*)
	--openPanel() of NewFilterScriptObj
	(*end of debug code*)
	--log "end launched"
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
			openWindow() of ScriptListObj
		else if theCommandID is "Help" then
			call method "showHelp:"
		end if
		set FreeTime to 0
	end if
	--display dialog theCommandID
	return true
end open

on clicked theObject
	set theName to name of theObject
	--log "clicked " & theName
	if theName is "endOfTask" then
		didEndTask() of ScriptListObj
		set theIndicator to progress indicator "workingIndicator" of window "FilterScripts"
		stop theIndicator
		call method "setHidden:" of theIndicator with parameters {true}
		set isTaskRunning to false
	else if theName is "EditScript" then
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
	else if theName is "ReloadNewScripts" then
		rebuild() of NewFilterScriptObj
	else if theName is "OpenNewScriptFolder" then
		tell application "Finder"
			open targetFolder of NewFilterScriptObj
		end tell
		call method "smartActivate:" with parameter "MACS"
	else if theName is "RemoveScript" then
		removeScript() of ScriptListObj
	else if theName is "ReloadScripts" then
		rebuild() of ScriptListObj
	else if theName is "OpenScriptsFolder" then
		tell application "Finder"
			open targetFolder of ScriptListObj
		end tell
		call method "smartActivate:" with parameter "MACS"
	end if
end clicked

on awake from nib theObject
	set theName to name of theObject
	--log "start awake from nib for " & theName
	if theName is "scriptDataSource" then
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
	if not isTaskRunning then
		set theIndicator to progress indicator "workingIndicator" of window "FilterScripts"
		call method "setHidden:" of theIndicator with parameters {false}
		start theIndicator
		if (runFilterScript() of ScriptListObj) then
			stop theIndicator
			call method "setHidden:" of theIndicator with parameters {true}
		else
			set isTaskRunning to true
		end if
	end if
end double clicked

on dialog ended theObject with reply theReply
	transferToOwner of SheetManager for theReply from theObject
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
	
	set SheetManager to importScript("SheetManager")
	
	--log "end finish launching"
end will finish launching
