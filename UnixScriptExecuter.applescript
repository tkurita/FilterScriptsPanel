global MessageUtility
global lineFeed

on makeObj(theScriptFile)
	--log "start newFilterScriptExecuter"
	set firstLine to read theScriptFile before lineFeed
	
	if firstLine starts with "#!" then
		set theScriptCommand to text 3 thru -1 of firstLine
	else
		set invalidCommand to localized string "invalidCommand"
		tell application "Finder"
			set theName to name of theScriptFile
		end tell
		set theMessage to aDoc & space & sQ & theName & eQ & space & invalidCommand
		showMessageOnmi(theMessage) of MessageUtility
		error "The document does not start with #!." number 1620
	end if
	
	set scriptRunner to call method "alloc" of class "ScriptRunner"
	call method "initWithScriptFile:withCommand:" of scriptRunner with parameters {POSIX path of theScriptFile, theScriptCommand}
	return scriptRunner
end makeObj
