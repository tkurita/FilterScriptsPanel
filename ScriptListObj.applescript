global UtilityHandlers
global DefaultsManager
global FolderTableObj
global SheetManager
global NewFilterScriptObj

on makeObj()
	copy FolderTableObj to newFolderTableObj
	
	script FilterScriptListObj
		property parent : newFolderTableObj
		property WindowController : missing value
		property currentExecuter : missing value
		global UnixScriptExecuter
		
		on openWindow()
			if WindowController is missing value then
				initialize("Scripts")
			end if
			call method "showWindow:" of WindowController
		end openWindow
		
		on initialize(targetName)
			--log "start initilize of ScriptListObj"
			set WindowController to call method "alloc" of class "ScriptListController"
			set WindowController to call method "initWithWindowNibName:" of WindowController with parameter "ScriptWindow"
			set my targetWindow to call method "window" of WindowController
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
			set NewFilterScriptObj to makeObj() of NewFilterScriptObj
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
					if (text returned of theReply is "OK") then
						tell application "Finder"
							delete targetItem
						end tell
						rebuild()
					end if
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
					return true
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
					call method "showErrorMessage:" of WindowController with parameter errMsg
					set theResult to ""
				end try
				sendDataTomi(theResult)
				beep
				return true
			else
				set currentExecuter to makeObj(theScriptFile) of UnixScriptExecuter
				--log "before launchTaskWithString"
				call method "launchTaskWithString:" of currentExecuter with parameter theText
				--log "after call method launchTaskWithString"
				return false
			end if
		end runFilterScript
		
		on didEndTask()
			set terminationStatus to call method "terminationStatus" of currentExecuter
			if terminationStatus is 0 then
				set theResult to call method "outputString" of currentExecuter
				sendDataTomi(theResult)
			end if
			call method "release" of currentExecuter
		end didEndTask
		
		on sendDataTomi(theResult)
			if theResult is not "" then
				set useNewWindow to ((state of cell "InNewWindow" of matrix "ResultMode" of my targetWindow) is on state)
				if useNewWindow then
					set docTitle to (my lastItemName & "-stdout-" & (current date)) as Unicode text
					tell application "mi"
						--make new document with data theResult with properties {name:docTitle} -- does not work with mi 2.1.7
						make new document with properties {name:docTitle, content:theResult}
						--set asksaving of document docTitle to false
					end tell
				else
					tell application "mi"
						set content of selection object 1 of document 1 to theResult
					end tell
				end if
			end if
		end sendDataTomi
	end script
end makeObj
