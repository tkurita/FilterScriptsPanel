property _factorySettingDict : missing value

on register_factory_settings(fileName)
	load_factory_settrings(fileName)
	call method "registerDefaults:" of user defaults with parameter my _factorySettingDict
end register_factory_settings

on load_factory_settrings(fileName)
	tell main bundle
		set a_file to path for resource fileName extension "plist"
	end tell
	set _factorySettingDict to call method "dictionaryWithContentsOfFile:" of class "NSDictionary" with parameter a_file
end load_factory_settrings

on factory_setting_for(a_name)
	return call method "objectForKey:" of my _factorySettingDict with parameter a_name
end factory_setting_for

on initialize_for(a_name, a_value)
	tell user defaults
		if not (exists default entry a_name) then
			make new default entry at end of default entries with properties {name:a_name, contents:a_value}
		end if
	end tell
end initialize_for

on value_for(a_name)
	tell user defaults
		return contents of default entry a_name
	end tell
end value_for

on set_value(a_name, a_value)
	tell user defaults
		if (exists default entry a_name) then
			set contents of default entry a_name to a_value
		else
			make new default entry at end of default entries with properties {name:a_name, contents:a_value}
		end if
	end tell
end set_value

on value_with_default(a_name, a_value)
	tell user defaults
		if exists default entry a_name then
			return contents of default entry a_name
		else
			make new default entry at end of default entries with properties {name:a_name, contents:a_value}
			return a_value
		end if
	end tell
end value_with_default

(*== obsolete *)
on readDefaultValueWith(a_name, a_value)
	return value_with_default(a_name, a_value)
end readDefaultValueWith

on readDefaultValue(a_name)
	return value_for(a_name)
end readDefaultValue

on initializeDefaultValue(a_name, a_value)
	return initialize_for(a_name, a_value)
end initializeDefaultValue

on getFactorySetting for a_name
	return factory_setting_for(a_name)
end getFactorySetting

on loadFactorySettings(fileName)
	load_factory_settrings(fileName)
end loadFactorySettings

on registerFactorySetting(fileName)
	register_factory_settings(fileName)
end registerFactorySetting
