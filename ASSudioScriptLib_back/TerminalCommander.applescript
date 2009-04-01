global TerminalCommanderBase
global TerminalColors

on buildup()
	script TerminalCommanderExtend
		property parent : TerminalCommanderBase
		
		on send_command for a_command
			set activate_flag to contents of default entry "ActivateTerminal" of user defaults
			do_command for a_command given activation:activate_flag
		end send_command
		
		on activate_terminal()
			call method "activateAppOfType:" of class "SmartActivate" with parameter "trmx"
			return true
		end activate_terminal
		
		on execution_string()
			set exec_string to contents of default entry "ExecutionString" of user defaults
			if exec_string is "" then
				set exec_string to missing value
			end if
			return exec_string
		end execution_string
		
		on shell_path()
			set shell_mode to contents of default entry "ShellMode" of user defaults
			if (shell_mode is 0) then
				return system attribute "SHELL"
			else
				set shell_path to contents of default entry "Shell" of user defaults
				if (shell_path is "") then
					return system attribute "SHELL"
				else
					return shell_path
				end if
			end if
		end shell_path
		
		on use_ctrlv_escapes()
			return contents of default entry "UseCtrlVEscapes" of user defaults
		end use_ctrlv_escapes
	end script
	TerminalCommanderExtend's set_colors(TerminalColors)
	return TerminalCommanderExtend
end buildup