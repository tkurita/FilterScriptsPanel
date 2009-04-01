global XText
global appController

property yenmark : missing value
property backslash : missing value

on ConsoleLog(a_msg)
	set theMesssage to ((current date) as Unicode text) & space & a_msg
	do shell script "echo '" & a_msg & "' >/dev/console"
end ConsoleLog

on clean_yenmark(a_xtext)
	if yenmark is missing value then
		set yenmark to call method "factoryDefaultForKey:" of appController with parameter "yenmark"
		set backslash to call method "factoryDefaultForKey:" of appController with parameter "backslash"
	end if
	if class of a_xtext is script then
		set a_result to a_xtext's replace(yenmark, backslash)
	else
		set a_result to XText's make_with(a_xtext)'s replace(yenmark, backslash)'s as_unicode()
	end if
end clean_yenmark

on loadPlistDictionary(basename)
	tell main bundle
		set plistFile to path for resource basename extension "plist"
	end tell
	return call method "dictionaryWithContentsOfFile:" of class "NSDictionary" with parameter plistFile
end loadPlistDictionary

on getKeyValue for entryName from dictionaryValue
	return call method "objectForKey:" of dictionaryValue with parameter entryName
end getKeyValue

on isExists(filePath) -- deprecated (TeXCompileServer is cleaned.)
	try
		filePath as alias
		return true
	on error
		return false
	end try
end isExists

on is_running(app_name)
	tell application "System Events"
		return exists application process app_name
	end tell
end is_running

on activeAppName()
	set theWorkspace to call method "sharedWorkspace" of class "NSWorkspace"
	set appInfo to call method "activeApplication" of theWorkspace
	return |NSApplicationName| of appInfo
end activeAppName

on copyItem(sourceItem, saveLocation, newName)
	set tmpFolder to path to temporary items
	tell application "Finder"
		set an_item to (duplicate sourceItem to tmpFolder with replacing) as alias
		set name of an_item to newName
		return (move an_item to saveLocation with replacing) as alias
	end tell
end copyItem

on xlocalized_string(a_keyword, insert_texts)
	set a_text to localized string a_keyword
	--log theKeyword & ":" & theText
	return XText's make_with(a_text)'s format_with(insert_texts)
end xlocalized_string

on localized_string(a_keyword, insert_texts)
	return xlocalized_string(a_keyword, insert_texts)'s as_unicode()
end localized_string

(*== deprecated handlers *)

(*
on importScript(scriptName)
	tell main bundle
		set scriptPath to path for script scriptName extension "scpt"
	end tell
	return load script POSIX file scriptPath
end importScript

on deleteListItem for an_item from theList
	set nList to length of theList
	repeat with ith from 1 to nList
		if an_item is item ith of theList then
			if ith is 1 then
				set theList to rest of theList
				exit repeat
			else if ith is nList then
				set theList to items 1 thru -2 of theList
				exit repeat
			else
				set theList to (items 1 thru (ith - 1) of theList) & (items (ith + 1) thru -1 of theList)
				exit repeat
			end if
		end if
	end repeat
	return theList
end deleteListItem
*)

