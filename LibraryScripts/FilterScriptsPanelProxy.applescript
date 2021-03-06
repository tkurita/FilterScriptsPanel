property _panelapp : "FilterScriptsPanel"

on resolve_panelapp()
	if application (my _panelapp) is running then
		tell application "System Events"
			return (file of application process (my _panelapp)) as Unicode text
		end tell
	end if
	
	set ver to version of current application
	considering numeric strings
		set mi_third to (ver ≥ "3.0")
	end considering
	
	if mi_third then
		set sub_path to "mi3:FilterScripts:" & my _panelapp & ".app"
		set path_list to {(path to application support from user domain as Unicode text) & sub_path}
	else
		set sub_path to "mi:FilterScripts:" & my _panelapp & ".app"
		set path_list to {(path to application support from user domain as Unicode text) & sub_path, ¬
			(path to preferences from user domain as Unicode text) & sub_path}
	end if
	
	try
		repeat with a_path in path_list
			a_path as alias
			return a_path
		end repeat
	end try
	error "Can't find FilterScriptsPanel.app." number 2060
	return missing value
end resolve_panelapp

on localized_string(a_key, insert_texts)
	tell application (my _compile_server)
		launch
		set a_text to localized string a_key
	end tell
	
	tell XText
		store_delimiters()
		set a_text to formated_text given template:a_text, args:insert_texts
		restore_delimiters()
	end tell
	return a_text
end localized_string

on make
	set a_path to resolve_panelapp()
	script FilterScriptsPanelProxy
		property _app_path : a_path
	end script
	
	return FilterScriptsPanelProxy
end make

on app_ref()
	return application (my _app_path)
end app_ref

on show_help()
	try
		tell application (my _app_path)
			launch
			ignoring application responses
				using terms from application "FilterScriptsPanel"
					show help
				end using terms from
			end ignoring
		end tell
	on error msg
		display alert msg
		return false
	end try
	return true
end show_help

on terminate()
	tell application "System Events"
		set a_list to application processes whose name is my _panelapp
	end tell
	
	if a_list is not {} then
		tell application (name of (item 1 of a_list))
			quit
		end tell
	end if
end terminate

on debug()
	--do_command({commandID:"sendCommandInCommonTerm", argument:{command:"echo 'hello'"}})
	make
end debug

on run
	debug()
end run