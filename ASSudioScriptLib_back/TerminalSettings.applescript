global TerminalCommander
global TerminalColors
global appController

property terminalSettingBox : missing value

on control_clicked(theObject)
	set a_name to name of theObject
	--log a_name
	if a_name is "ApplyColors" then
		apply_colors_to_terminal()
	else if a_name is "RevertColors" then
		revert_colors_to_terminal()
	else if a_name is "SaveColors" then
		color_settings_from_window()
		write_color_settings()
	end if
end control_clicked

on revert_to_factory_colors()
	set isChangeBackground to call method "factoryDefaultForKey:" of appController with parameter "IsChangeBackground"
	set backgroundColor to call method "factoryDefaultForKey:" of appController with parameter "BackgroundColor"
	set terminalOpaqueness to call method "factoryDefaultForKey:" of appController with parameter "TerminalOpaqueness"
	set isChangeNormalText to call method "factoryDefaultForKey:" of appController with parameter "IsChangeNormalText"
	set normalTextColor to call method "factoryDefaultForKey:" of appController with parameter "NormalTextColor"
	set isChangeBoldText to call method "factoryDefaultForKey:" of appController with parameter "IsChangeBoldText"
	set boldTextColor to call method "factoryDefaultForKey:" of appController with parameter "BoldTextColor"
	set isChangeCursor to call method "factoryDefaultForKey:" of appController with parameter "IsChangeCursor"
	set cursorColor to call method "factoryDefaultForKey:" of appController with parameter "CursorColor"
	set isChangeSelection to call method "factoryDefaultForKey:" of appController with parameter "IsChangeSelection"
	set selectionColor to call method "factoryDefaultForKey:" of appController with parameter "SelectionColor"
	
	tell TerminalColors
		set_normal_text(normalTextColor, isChangeNormalText)
		set_bold_text(boldTextColor, isChangeBoldText)
		set_background(backgroundColor, terminalOpaqueness, isChangeBackground)
		set_coursor(cursorColor, isChangeCursor)
		set_selection(selectionColor, isChangeSelection)
	end tell
end revert_to_factory_colors

on revert_to_factory_setting()
	call method "revertToFactoryDefaultForKey:" of appController with parameter "Shell"
	call method "revertToFactoryDefaultForKey:" of appController with parameter "UseCtrlVEscapes"
	call method "revertToFactoryDefaultForKey:" of appController with parameter "ShellMode"
	call method "revertToFactoryDefaultForKey:" of appController with parameter "ExecutionString"
	
	--colors
	revert_to_factory_colors()
	
	write_settings()
end revert_to_factory_setting

on load_color_settings()
	tell user defaults
		set isChangeBackground to contents of default entry "IsChangeBackground"
		set backgroundColor to contents of default entry "BackgroundColor"
		set terminalOpaqueness to contents of default entry "TerminalOpaqueness"
		set isChangeNormalText to contents of default entry "IsChangeNormalText"
		set normalTextColor to contents of default entry "NormalTextColor"
		set isChangeBoldText to contents of default entry "IsChangeBoldText"
		set boldTextColor to contents of default entry "BoldTextColor"
		set isChangeCursor to contents of default entry "IsChangeCursor"
		set cursorColor to contents of default entry "CursorColor"
		set isChangeSelection to contents of default entry "IsChangeSelection"
		set selectionColor to contents of default entry "SelectionColor"
	end tell
	
	tell TerminalColors
		set_normal_text(normalTextColor, isChangeNormalText)
		set_bold_text(boldTextColor, isChangeBoldText)
		set_background(backgroundColor, terminalOpaqueness, isChangeBackground)
		set_coursor(cursorColor, isChangeCursor)
		set_selection(selectionColor, isChangeSelection)
	end tell
end load_color_settings

on load_settings()
	--log "start load_settings of TerminalSettings"
	tell TerminalCommander
		set_custom_title(call method "factoryDefaultForKey:" of appController with parameter "CustomTitle")
		set_string_encoding(call method "factoryDefaultForKey:" of appController with parameter "StringEncoding")
	end tell
	--colors
	load_color_settings()
	
	--TerminalCommander Setting
	--set _displayDeviceName of TerminalCommander to true
end load_settings

on write_settings()
	write_color_settings()
end write_settings

on write_color_settings()
	tell user defaults
		set contents of default entry "IsChangeBackground" to is_change_background() of TerminalColors
		set contents of default entry "BackgroundColor" to background_color() of TerminalColors
		set contents of default entry "TerminalOpaqueness" to background_opaqueness() of TerminalColors
		set contents of default entry "IsChangeNormalText" to is_change_normal_text() of TerminalColors
		set contents of default entry "NormalTextColor" to normal_text() of TerminalColors
		set contents of default entry "IsChangeBoldText" to is_change_bold_text() of TerminalColors
		set contents of default entry "BoldTextColor" to bold_text() of TerminalColors
		set contents of default entry "IsChangeCursor" to is_change_cursor() of TerminalColors
		set contents of default entry "CursorColor" to cursor_color() of TerminalColors
		set contents of default entry "IsChangeSelection" to is_change_selection() of TerminalColors
		set contents of default entry "SelectionColor" to selection_color() of TerminalColors
	end tell
end write_color_settings

on color_settings_from_window()
	tell box "TerminalColors" of terminalSettingBox
		if (state of button "BackSwitch" is 1) then
			set_background(color of color well "BackgroundColor", contents of slider "BackTransparency", true) of TerminalColors
		else
			set_change_background(false) of TerminalColors
		end if
		
		if (state of button "NormalSwitch" is 1) then
			set_normal_text(color of color well "NormalTextColor", true) of TerminalColors
		else
			set_change_normal_text(false) of TerminalColors
		end if
		
		if (state of button "BoldSwitch" is 1) then
			set_bold_text(color of color well "BoldTextColor", true) of TerminalColors
		else
			set_change_bold_text(false) of TerminalColors
		end if
		
		if (state of button "CursorSwitch" is 1) then
			set_coursor(color of color well "cursorColor", true) of TerminalColors
		else
			set_change_cursor(false) of TerminalColors
		end if
		
		if (state of button "SelectionSwitch" is 1) then
			set_selection(color of color well "selectionColor", true) of TerminalColors
		else
			set_change_selection(false) of TerminalColors
		end if
	end tell
end color_settings_from_window

on set_colors_to_window()
	--log "start set_colors_to_window"
	tell box "TerminalColors" of terminalSettingBox
		
		if is_change_background() of TerminalColors then
			set state of button "BackSwitch" to 1
			set enabled of color well "BackgroundColor" to true
			set enabled of slider "BackTransparency" to true
			set color of color well "BackgroundColor" to background_color() of TerminalColors
			set contents of slider "BackTransparency" to background_opaqueness() of TerminalColors
		else
			set state of button "BackSwitch" to 0
			set enabled of color well "BackgroundColor" to false
			set enabled of slider "BackTransparency" to false
		end if
		
		if is_change_normal_text() of TerminalColors then
			set state of button "NormalSwitch" to 1
			set enabled of color well "NormalTextColor" to true
			set color of color well "NormalTextColor" to normal_text() of TerminalColors
		else
			set state of button "NormalSwitch" to 0
			set enabled of color well "NormalTextColor" to false
		end if
		
		if is_change_bold_text() of TerminalColors then
			set state of button "BoldSwitch" to 1
			set enabled of color well "BoldTextColor" to true
			set color of color well "BoldTextColor" to bold_text() of TerminalColors
		else
			set state of button "BoldSwitch" to 0
			set enabled of color well "BoldTextColor" to false
		end if
		
		if is_change_cursor() of TerminalColors then
			set state of button "CursorSwitch" to 1
			set enabled of color well "CursorColor" to true
			set color of color well "CursorColor" to cursor_color() of TerminalColors
		else
			set state of button "CursorSwitch" to 0
			set enabled of color well "CursorColor" to false
		end if
		
		if is_change_selection() of TerminalColors then
			set state of button "SelectionSwitch" to 1
			set enabled of color well "SelectionColor" to true
			set color of color well "SelectionColor" to selection_color() of TerminalColors
		else
			set state of button "SelectionSwitch" to 0
			set enabled of color well "SelectionColor" to false
		end if
	end tell
end set_colors_to_window

on set_setting_to_window(theView)
	--log "start set_setting_to_window"
	set terminalSettingBox to theView
	set_colors_to_window()
end set_setting_to_window

on apply_colors_to_terminal()
	color_settings_from_window()
	if not TerminalColors's apply(TerminalCommander) then
		do_command of TerminalCommander for "echo Test colors" with activation
	end if
end apply_colors_to_terminal

on revert_colors_to_terminal()
	load_color_settings()
	set_colors_to_window()
	if not TerminalColors's apply(TerminalCommander) then
		do_command of TerminalCommander for "echo Test colors" with activation
	end if
end revert_colors_to_terminal