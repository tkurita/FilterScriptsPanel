(* shared script objects *)
global WindowController

on makeObj(theWindow)
	set theWindowController to makeObj(theWindow) of WindowController
	
	script FilterPaletteController
		global ScriptListObj
		global DefaultsManager
		
		property parent : theWindowController
		property selectedItem : missing value
		property scriptTable : missing value
		
		on initialize()
			--log "start initialize in FilterPaletteController"
			set scriptTable to table view "ScriptList" of scroll view "ScriptList" of my targetWindow
			--log "before initialize of ScriptListObj"
			initialize("Scripts") of ScriptListObj
			continue initialize()
			--log "end initialize in FilterPaletteController"
		end initialize
		
		on readDefaults()
			--log "start readDefaults"
			set selectedItem to readDefaultValueWith("selectedItem", 0) of DefaultsManager
			continue readDefaults()
		end readDefaults
		
		on writeDefaults()
			set selectedItem to selected row of scriptTable
			set contents of default entry "selectedItem" of user defaults to selectedItem
			continue writeDefaults()
		end writeDefaults
		
		on applyDefaults()
			--log "start applyDefaults"
			set selected row of scriptTable to selectedItem
			--log "before continue applyDefaults"
			continue applyDefaults()
			--log "end applyDefaults"
		end applyDefaults
	end script
end makeObj