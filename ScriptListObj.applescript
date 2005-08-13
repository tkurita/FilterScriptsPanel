global UtilityHandlers
global DefaultsManager
global FolderTableObj
global SheetManager
global PaletteWindowController

on makeObj()
	copy FolderTableObj to newFolderTableObj
	
	script FilterScriptListObj
		property parent : newFolderTableObj
		global UnixScriptExecuter
		global StringEngine
		global lineFeed
		
		on initialize(targetName)
			--log "start initilize of ScriptListObj"
			set my targetWindow to window "FilterScripts"
			set my targetTable to table view "ScriptList" of scroll view "ScriptListScroll" of my targetWindow
			set my targetDataSource to data source of my targetTable
			--log "before continue initialize"
			continue initialize(targetName)
			--log "after continue initialize"
			if my itemList is missing value then
				readTableContents()
			else
				updateTableContents()
			end if
			set selectedItem to readDefaultValueWith("selectedItem", -1) of DefaultsManager
			set selected row of my targetTable to selectedItem + 1
			
			--log "end initialize of ScriptListObj"
		end initialize
		
		on doRename(theReply)
			set theButton to button returned of theReply
			set newName to text returned of theReply
			if (theButton is "OK") and (newName is not my lastItemName) then
				tell application "Finder"
					set name of my selectedItemAlias to newName
				end tell
				set contents of data cell "Name" of my selectedDataRow to newName
			end if
		end doRename
		
		on renameScript()
			getSelectedItem()
			set enterNewNameMsg to localized string "enterNewName"
			display dialog enterNewNameMsg attached to my targetWindow default answer my lastItemName
			script renameTransfer
				on sheetEnded(theReply)
					doRename(theReply)
				end sheetEnded
			end script
			addSheetRecord of SheetManager given parentWindow:my targetWindow, ownerObject:renameTransfer
		end renameScript
		
		on removeScript()
			try
				set selectedItem to getSelectedItem()
			on error -128
				return
			end try
			set removeConfirmMessage to getLocalizedString of UtilityHandlers given keyword:"removeConfirm", insertTexts:{my lastItemName}
			display dialog removeConfirmMessage attached to my targetWindow default button 1
			script removeTransfer
				property targetItem : selectedItem
				on sheetEnded(theReply)
					tell application "Finder"
						delete targetItem
					end tell
					rebuild()
				end sheetEnded
			end script
			addSheetRecord of SheetManager given parentWindow:my targetWindow, ownerObject:removeTransfer
		end removeScript
		
		on runFilterScript()
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
				set theFileType to call method "hfsFileType" of (POSIX path of theScriptFile)
				set isAppleScript to (theFileType is "'osas'")
				--log "after get file type"
			end if
			
			if isAppleScript then
				try
					set theResult to run script theScriptFile with parameters {theText}
				on error errMsg number errNum
					call method "showErrorMessage:" of PaletteWindowController with parameter errMsg
					--set contents of text view "ScriptError" of scroll view "ScriptError" of window "ScriptError" to errMsg
					--display targetPanel attached to my targetWindow
					set theResult to ""
				end try
			else
				set thelist to every paragraph of theText
				startStringEngine() of StringEngine
				--set theText to joinStringList of StringEngine for thelist by lineFeed
				set theText to joinUTextList of StringEngine for thelist by lineFeed
				stopStringEngine() of StringEngine
				set theFilterScriptExecuter to makeObj(theScriptFile) of UnixScriptExecuter
				--log "before launchTaskWithString"
				call method "launchTaskWithString:" of theFilterScriptExecuter with parameter theText
				--log "after call method launchTaskWithString"
				
				set terminationStatus to call method "terminationStatus" of theFilterScriptExecuter
				if terminationStatus is 0 then
					set theResult to call method "standardOutput" of theFilterScriptExecuter
				else
					set theResult to ""
				end if
				call method "release" of theFilterScriptExecuter
				
				--log "after execution of a unix script"
			end if
			--log "after execution"
			
			if theResult is not "" then
				set useNewWindow to ((state of cell "InNewWindow" of matrix "ResultMode" of my targetWindow) is on state)
				if useNewWindow then
					set docTitle to (my lastItemName & "-stdout-" & (current date)) as Unicode text
					tell application "mi"
						--make new document with data theResult with properties {name:docTitle}
						make new document with properties {name:docTitle, content:theResult}
						--set asksaving of document docTitle to false
					end tell
				else
					tell application "mi"
						set content of selection object 1 of document 1 to theResult
					end tell
				end if
			end if
			beep
			--log "end runFilterScript"
		end runFilterScript
	end script
end makeObj