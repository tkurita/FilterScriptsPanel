global FolderTableObj
global ScriptListObj
global UtilityHandlers
global SheetManager

on makeObj()
	copy FolderTableObj to newFolderTableObj
	
	script NewFilterScriptObj
		property parent : newFolderTableObj
		
		on initialize(targetName)
			--log "start initialize in NewFilterScriptObj"
			set my targetWindow to window "NewScript"
			set my targetTable to table view "TemplateList" of scroll view "TemplateList" of my targetWindow
			set my targetDataSource to data source of my targetTable
			continue initialize(targetName)
			--log "end initialize in NewFilterScriptObj"
		end initialize
		
		on openPanel()
			if not my isInitialized then
				initialize("Templates")
				readTableContents()
			else
				updateTableContents()
			end if
			display my targetWindow attached to window "FilterScripts"
		end openPanel
		
		on closePanel()
			close panel my targetWindow
		end closePanel
		
		on makeNewScript()
			--log "start makeNewScript"
			set newName to contents of text field "NewScriptName" of my targetWindow
			set templateAlias to getSelectedItem()
			
			set targetFolderPath to (targetFolder of ScriptListObj) as Unicode text
			if isExists(targetFolderPath & newName) of UtilityHandlers then
				set isExistsMsg to localized string "isExists"
				set theMessage to newName & space & isExistsMsg
				displayNewScriptName(theMessage)
				return
			else
				closePanel()
				set targetItem to copyItem(templateAlias, targetFolder of ScriptListObj, newName) of UtilityHandlers
				rebuild() of ScriptListObj
				tell application "Finder"
					open targetItem
				end tell
			end if
		end makeNewScript
		
		on displayNewScriptName(theMessage)
			display dialog theMessage attached to my targetWindow buttons {"OK"} default button "OK"
			script newNameTransfer
				on sheetEnded(theReply)
					makeNewScript(theReply)
				end sheetEnded
			end script
			addSheetRecord of SheetManager given parentWindow:my targetWindow, ownerObject:newNameTransfer
		end displayNewScriptName
		
	end script
end makeObj
