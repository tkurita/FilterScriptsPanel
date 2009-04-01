property _sheet_records : {}

on register_sheet_record(theSheetRecord)
	set end of _sheet_records to theSheetRecord
end register_sheet_record

on addSheetRecord given parentWindow:theWindow, ownerObject:theObject
	set attachedSheet to call method "attachedSheet" of theWindow
	set theSheetRecord to {sheetWindow:attachedSheet, delegate:theObject}
	register_sheet_record(theSheetRecord)
end addSheetRecord

on register_sheet given attached_to:a_window, delegate:an_object
	set a_sheet to call method "attachedSheet" of a_window
	set a_record to {sheetWindow:a_sheet, delegate:an_object}
	register_sheet_record(a_record)
end register_sheet

on sheet_ended(theWindow, theReply)
	set sheetRecordLength to length of my _sheet_records
	if sheetRecordLength < 1 then
		return false
	end if
	repeat with ith from 1 to sheetRecordLength
		set theSheetRecord to item ith of _sheet_records
		if sheetWindow of theSheetRecord is theWindow then
			exit repeat
		end if
	end repeat
	
	if ith is 1 then
		set _sheet_records to rest of _sheet_records
	else if ith is sheetRecordLength then
		set _sheet_records to items 1 thru -2 of _sheet_records
	else
		set _sheet_records to ((items 1 thru (ith - 1) of _sheet_records) & (items (ith + 1) thru -1 of _sheet_records))
	end if
	
	tell delegate of theSheetRecord
		set theObject to delegate of theSheetRecord
		sheet_ended(theWindow, theReply) of theObject
	end tell
end sheet_ended

on transferToOwner for theReply from theWindow
	set sheetRecordLength to length of my _sheet_records
	repeat with ith from 1 to sheetRecordLength
		set theSheetRecord to item ith of _sheet_records
		if sheetWindow of theSheetRecord is theWindow then
			exit repeat
		end if
	end repeat
	
	if ith is 1 then
		set _sheet_records to rest of _sheet_records
	else if ith is sheetRecordLength then
		set _sheet_records to items 1 thru -2 of _sheet_records
	else
		set _sheet_records to ((items 1 thru (ith - 1) of _sheet_records) & (items (ith + 1) thru -1 of _sheet_records))
	end if
	
	tell delegate of theSheetRecord
		set theObject to delegate of theSheetRecord
		sheetEnded(theReply) of theObject
	end tell
end transferToOwner