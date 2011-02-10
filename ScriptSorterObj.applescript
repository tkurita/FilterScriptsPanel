global FileSorter

on makeObj(folderName)
	copy FileSorter to theFileSorter
	
	script ScriptSorter
		property parent : theFileSorter
		
		on getTargetItems()
			set nameList to list folder my targetContainer without invisibles
			set containerPath to my targetContainer as Unicode text
			set thelist to {}
			repeat with ith from 1 to length of nameList
				set end of thelist to (containerPath & (item ith of nameList)) as alias
			end repeat
			return {thelist, nameList}
		end getTargetItems
		
		on buildIndexArray()
			set {itemList, nameList} to getTargetItems()
			set indexList to {}
			repeat with ith from 1 to length of itemList
				set end of indexList to extractInfo(item ith of itemList)
			end repeat
			return {itemList, nameList, indexList}
		end buildIndexArray
		
		on resolve_mi_folder()
			set sub_path to "mi:"
			set path_list to {(path to application support from user domain as Unicode text) & sub_path, Å 
				(path to preferences from user domain as Unicode text) & sub_path}
			try
				repeat with a_path in path_list
					a_path as alias
					return a_path
				end repeat
			end try
			error "Can't find mi folder." number 2061
		end resolve_mi_folder
		
		on getContainer()
			--log "start getContainer"
			set filterScripsFolderPath to resolve_mi_folder() & "FilterScripts:"
			set targetFolderPath to filterScripsFolderPath & folderName & ":"
			--log targetFolderPath
			try
				set theAlias to targetFolderPath as alias
			on error errMsg number -43
				--log errMsg
				set resourcePath to resource path of main bundle
				set scriptsZip to quoted form of (resourcePath & "/" & folderName & ".zip")
				do shell script "ditto --sequesterRsrc -x -k " & scriptsZip & space & (quoted form of POSIX path of filterScripsFolderPath)
				set theAlias to targetFolderPath as alias
				tell application "Finder"
					set arrangement of icon view options of container window of theAlias to snap to grid
				end tell
			end try
			--log "end getContainer"
			return theAlias
		end getContainer
		
		on sortDirectionOfIconView()
			return "column direction"
		end sortDirectionOfIconView
	end script
end makeObj