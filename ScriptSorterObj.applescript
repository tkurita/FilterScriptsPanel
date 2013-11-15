global FileSorter

on resolve_mi_folder()
	-- log "start resolve_mi_folder"
	set fspanel_path to (path to me)'s POSIX path
	set app_support_path to (path to application support from user domain)'s POSIX path
	set path_list to {}
	set mi_support_path to app_support_path & "mi3/"
	if fspanel_path starts with mi_support_path then
		return mi_support_path
	end if
	set end of path_list to mi_support_path
	
	set mi_support_path to app_support_path & "mi/"
	if fspanel_path starts with (mi_support_path) then
		return mi_support_path
	end if
	set end of path_list to mi_support_path
	
	set mi_support_path to ((path to preferences from user domain)'s POSIX path) & "mi/"
	if fspanel_path starts with (mi_support_path) then
		return mi_support_path
	end if
	set end of path_list to mi_support_path
	
	try
		repeat with a_path in path_list
			(a_path as POSIX file) as alias
			return a_path
		end repeat
	end try
	error "Can't find mi folder." number 2061
end resolve_mi_folder

on resolve_container()
	-- log "start resolve_container"
	if my _container is not missing value then
		return my _container
	end if
	set filter_scripts_folder to resolve_mi_folder() & "FilterScripts/"
	set target_folder_path to filter_scripts_folder & my _folder_name & "/"
	--log targetFolderPath
	try
		set an_alias to (target_folder_path as POSIX file) as alias
	on error msg number errno
		if errno is in {-43, -1700} then
			-- -43   : when coerce HFS path to alias
			-- -1700 : when coerce POSIX file to alias
			--log errMsg
			set resourcePath to resource path of main bundle
			set scriptsZip to quoted form of (resourcePath & "/" & my _folder_name & ".zip")
			do shell script "ditto --sequesterRsrc -x -k " & scriptsZip & space & (quoted form of filter_scripts_folder)
			set an_alias to (target_folder_path as POSIX file) as alias
			tell application "Finder"
				set arrangement of icon view options of container window of an_alias to snap to grid
			end tell
		else
			error msg number errno
		end if
	end try
	-- log "end getContainer"
	set my _container to an_alias
	return an_alias
end resolve_container

on make_with(a_name)
	set a_class to me
	script SorterDelegate
		property parent : a_class
		property _folder_name : a_name
		property _container : missing value
	end script
	
	return FileSorter's make_with_delegate(SorterDelegate)
end make_with
