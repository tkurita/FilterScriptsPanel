global FilterPaletteController
global FolderTableObj
global ScriptListObj
global UtilityHandlers

global DialogOwner

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
			attachPanel(my targetWindow) of FilterPaletteController
		end openPanel
		
		on closePanel()
			closeAttachedPanel() of FilterPaletteController
		end closePanel
		
		on makeNewScript()
			set newName to contents of text field "NewScriptName" of my targetWindow
			set templateAlias to getSelectedItem()
			
			set targetFolderPath to (scriptFolder of ScriptListObj) as Unicode text
			if isExists(targetFolderPath & newName) of UtilityHandlers then
				set isExistsMsg to localized string "isExists"
				set theMessage to newName & space & isExistsMsg
				displayNewScriptName(theMessage)
				return
			else
				closePanel()
				set targetItem to copyItem(templateAlias, scriptFolder of ScriptListObj, newName) of UtilityHandlers
				rebuild() of ScriptListObj
				tell application "Finder"
					open targetItem
				end tell
			end if
		end makeNewScript
		
		on displayNewScriptName(theMessage)
			set DialogOwner to "NewScript"
			set theReply to display dialog theMessage attached to my targetWindow buttons {"OK"} default button "OK"
		end displayNewScriptName
		
	end script
end makeObj
