global lineFeed
global UtilityHandlers
global DialogOwner
global StringEngine
global UnixScriptExecuter
global DefaultsManager
global FolderTableObj

global DialogOwner

on makeObj()
	copy FolderTableObj to newFolderTableObj
	
	script FilterScriptListObj
		property parent : newFolderTableObj
		
		on initialize(targetName)
			--log "start initilize of ScriptListObj"
			set my targetWindow to window "FilterScripts"
			set my targetTable to table view "ScriptList" of scroll view "ScriptList" of my targetWindow
			set my targetDataSource to data source of my targetTable
			continue initialize(targetName)
			
			if my scriptList is missing value then
				readTableContents()
			else
				updateTableContents()
			end if
		end initialize
		
		on doRename(theReply)
			set theButton to button returned of theReply
			set newName to text returned of theReply
			if (theButton is "OK") and (newName is not lastItemName) then
				tell application "System Events"
					set name of selectedItemAlias to newName
				end tell
				set contents of data cell "Name" of selectedDataRow to newName
			end if
			set DialogOwner to missing value
		end doRename
		
		on renameScript()
			getSelectedItem()
			set enterNewNameMsg to localized string "enterNewName"
			set DialogOwner to "RenameScript"
			set theReply to display dialog enterNewNameMsg attached to my targetWindow default answer my lastItemName
		end renameScript
		
		on runFilterScript()
			log "start runFilterScript"
			(*get input data from mi*)
			tell application "mi"
				if exists front document then
					set theText to content of selection object 1 of front document
				else
					beep
					return
				end if
			end tell
			
			set theScriptFile to getSelectedItem()
			set pathText to theScriptFile as Unicode text
			if (pathText ends with ".scptd:") or (pathText ends with ".scpt") then
				set isAppleScript to true
			else
				log "before get file type"
				set infoRecord to info for theScriptFile
				set isAppleScript to ((file type of infoRecord) is "osas")
				log "after get file type"
			end if
			
			log "before execution"
			if isAppleScript then
				set theResult to run script theScriptFile with parameters {theText}
			else
				set theList to every paragraph of theText
				--set beginning of theList to "<<EndOfData"
				--set end of theList to "EndOfData"
				startStringEngine() of StringEngine
				set theText to joinStringList of StringEngine for theList by lineFeed
				stopStringEngine() of StringEngine
				set contents of pasteboard "general" to theText
				log "berfore newFilterScriptExecuter"
				set theFilterScriptExecuter to newFilterScriptExecuter of UnixScriptExecuter from theScriptFile
				--set postOption of theFilterScriptExecuter to theText
				log "before execution of a unix script"
				set theResult to runScript() of theFilterScriptExecuter
				log "after execution of a unix script"
			end if
			log "after execution"
			
			if theResult is not "" then
				set useNewWindow to ((state of cell "InNewWindow" of matrix "ResultMode" of my targetWindow) is on state)
				if useNewWindow then
					set docTitle to my lastItemName & "-stdout-" & ((current date) as string)
					tell application "mi"
						make new document with data theResult with properties {name:docTitle}
						--set asksaving of document docTitle to false
					end tell
				else
					tell application "mi"
						set content of selection object 1 of document 1 to theResult
					end tell
				end if
			end if
			beep
			log "end runFilterScript"
		end runFilterScript
	end script
end makeObj