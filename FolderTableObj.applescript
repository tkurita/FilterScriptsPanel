global ScriptSorterObj
global DefaultsManager

property targetDataSource : missing value
property targetFolder : missing value
property targetWindow : missing value
property targetTable : missing value

property listName : missing value
property lastRebuidDateLabel : missing value
property itemList : missing value
property FolderItemSorter : missing value
property isInitialized : false
property lastItemName : missing value
property selectedDataRow : missing value
property selectedItemAlias : missing value
property lastRebuildDate : missing value

on initialize(targetName)
	-- log "start initialize in FolderTableObj"
	set listName to targetName & "_list"
	set lastRebuidDateLabel to targetName & "_lastRebuildDate"
	
	set FolderItemSorter to makeObj(targetName) of ScriptSorterObj
	set my targetFolder to getContainer() of FolderItemSorter
	set isInitialized to true
	-- log "end  initialize in FolderTableObj"
end initialize

on target_folder()
	return my targetFolder
end target_folder

on readTableContents()
	--log "start readTableContents"
	if exists default entry lastRebuidDateLabel of user defaults then
		--log "exists entry"
		set lastRebuildDate to contents of default entry lastRebuidDateLabel of user defaults
		--log "afterf read"
		tell application "System Events"
			set currentModDate to modification date of targetFolder
		end tell
		--display dialog (lastRebuildDate as string) & return & (currentModDate as string)
		
		if lastRebuildDate > currentModDate then
			set itemList to readDefaultValueWith(listName, itemList) of DefaultsManager
			--log "before append"
			append targetDataSource with itemList
			--log "after append"
		else
			rebuild()
			writeTableContents()
		end if
		
	else
		rebuild()
		makeTableContentsDefaults()
	end if
	--log "end readTableContents"
end readTableContents

on updateTableContents()
	--log "start updateTableContetns"
	tell application "System Events"
		set currentModDate to modification date of targetFolder
	end tell
	
	if lastRebuildDate > currentModDate then
		return false
	else
		rebuild()
		return true
	end if
end updateTableContents

on makeTableContentsDefaults()
	--log "start makeTableContentsDefaults"
	make new default entry at end of default entries of user defaults with properties {name:listName, contents:itemList}
	make new default entry at end of default entries of user defaults with properties {name:lastRebuidDateLabel, contents:current date}
	--log "end makeTableContentsDefaults"
end makeTableContentsDefaults

on rebuild()
	--log "start rebuild"
	set {pathList, nameList, indexList} to sortByView() of FolderItemSorter
	set itemList to {}
	repeat with ith from 1 to length of nameList
		set end of itemList to {|name|:item ith of nameList}
	end repeat
	delete (every data row of targetDataSource)
	append targetDataSource with itemList
end rebuild

on writeTableContents()
	--log "start writeTableContents"
	set contents of default entry listName of user defaults to itemList
	set contents of default entry (lastRebuidDateLabel) of user defaults to current date
end writeTableContents

on getSelectedItem()
	set selectedDataRow to selected data row of targetTable
	try
		set lastItemName to contents of data cell "Name" of selectedDataRow
	on error number -2753
		set noSelectionMsg to localized string "NoSelection_" & (name of targetTable)
		display dialog noSelectionMsg attached to targetWindow buttons {"OK"} default button "OK" with icon 0
		error number -128
	end try
	
	set selectedItemAlias to ((targetFolder as Unicode text) & lastItemName) as alias
	if alias of (info for selectedItemAlias) then
		try
			tell application "Finder"
				set selectedItemAlias to original item of selectedItemAlias
			end tell
		on error number -1728 -- no original alias file
			set theMessage to localized string "noOriginalItem"
			display dialog theMessage attached to targetWindow buttons {"OK"} default button "OK" with icon 0
			error "No Original item for the filter script." number 1630
		end try
	end if
	return selectedItemAlias
end getSelectedItem