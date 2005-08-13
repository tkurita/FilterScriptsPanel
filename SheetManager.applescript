property sheetRecordList : {}
property sheetRecordLength : 0

global theHandler

on addSheetRecordWith(theSheetRecord)
	set end of sheetRecordList to theSheetRecord
	set sheetRecordLength to sheetRecordLength + 1
end addSheetRecordWith

on addSheetRecord given parentWindow:theWindow, ownerObject:theObject
	set attachedSheet to call method "attachedSheet" of theWindow
	set theSheetRecord to {sheetWindow:attachedSheet, ownerObject:theObject}
	addSheetRecordWith(theSheetRecord)
end addSheetRecord

on transferToOwner for theReply from theWindow
	repeat with ith from 1 to sheetRecordLength
		set theSheetRecord to item ith of sheetRecordList
		if sheetWindow of theSheetRecord is theWindow then
			exit repeat
		end if
	end repeat
	
	if ith is 1 then
		set sheetRecordList to rest of sheetRecordList
	else if ith is sheetRecordLength then
		set sheetRecordList to items 1 thru -2 of sheetRecordList
	else
		set sheetRecordList to ((items 1 thru (ith - 1) of sheetRecordList) & (items (ith + 1) thru -1 of sheetRecordList))
	end if
	
	set sheetRecordLength to sheetRecordLength - 1
	
	tell ownerObject of theSheetRecord
		set theObject to ownerObject of theSheetRecord
		sheetEnded(theReply) of theObject
	end tell
end transferToOwner