global UtilityHandlers

on showErrorInFrontmostApp(errno, errMsg) --deprecated (UnixScriptServer, TeXCompileServer is clean)
	set errorLabel to localized string "errorLabel"
	set a_msg to errorLabel & space & errno & return & (name of current application) & " : " & errMsg
	using terms from application "System Events" -- without this statemet, display dialog means a showing panel intead of display dialog command in Standard Additions.
		tell application (path to frontmost application as Unicode text)
			display dialog a_msg buttons {"OK"} default button "OK" with icon caution
		end tell
	end using terms from
end showErrorInFrontmostApp

on show_error(errno, place, msg)
	activate
	set a_msg to UtilityHandlers's localized_string("error_msg", {errno, place, msg})
	display alert message a_msg
end show_error

on show_message(a_msg)
	activate
	display alert message a_msg
end show_message
