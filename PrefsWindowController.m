#import "PrefsWindowController.h"

#define useLog 0

@implementation PrefsWindowController
#pragma mark actions
- (IBAction)cancelAction:(id)sender
{
	[[NSApplication sharedApplication] endSheet: [sender window] returnCode:128];
}

- (IBAction)okAction:(id)sender
{
	[[NSApplication sharedApplication] endSheet: [sender window] returnCode:128];
	if (isTableDataChanged) {
		NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
		[userDefaults setObject:envVariables forKey:@"enviromentVariables"];
	}
}

- (IBAction)addRecrodAction:(id)sender
{
	NSMutableDictionary *newEnvVariable = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"",@"name",@"",@"value",nil];
	[envVariables addObject:newEnvVariable];
	[envVariableTable reloadData];
	NSIndexSet *newRowIndex = [NSIndexSet indexSetWithIndex:[envVariables count]-1];
	[envVariableTable selectRowIndexes:newRowIndex byExtendingSelection:NO];
	[[self window] makeFirstResponder:envVariableTable];
	[envVariableTable editColumn:0 row:([envVariables count] - 1) withEvent:nil select:YES];
}

- (IBAction)removeRecrodAction:(id)sender
{
	int selectedIndex = [envVariableTable selectedRow];
	if (selectedIndex != -1) {
		[envVariables removeObjectAtIndex:selectedIndex];
		[envVariableTable reloadData];
		isTableDataChanged = YES;
	}
}

#pragma mark init and dealloc

- (id)init
{
#if useLog
	NSLog(@"start init in PrefsWindowController");
#endif
	return [super init];
}

- (void)awakeFromNib
{
	//NSLog(@"start awakeFromNib in PrefsWindowController");

	isTableDataChanged = NO;
	
	[[self window] setInitialFirstResponder:envVariableTable];
		
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[self setEnvVariables:[userDefaults arrayForKey:@"enviromentVariables"]];
	//NSLog([envVariables description]);
}

#pragma mark delegate of tabele
#pragma mark data source
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return [envVariables count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)rowIndex
{
	//NSLog(@"start tableView:ObjectValueForTableColumn:");
	id identifier = [tableColumn identifier];
	NSDictionary *aEnvVarable;
	if (aEnvVarable =[envVariables objectAtIndex:rowIndex]) {
		NSString *theValue;
		if (theValue = [aEnvVarable objectForKey:identifier]) {
			return theValue;
		}
	}

	return nil;
}

- (void)tableView:(NSTableView *)aTableView setObjectValue:anObject forTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
	NSLog(@"tableView:setObjectValue:");
	NSParameterAssert(rowIndex >= 0 && rowIndex < [envVariables count]);
	
	NSString *identifier = [aTableColumn identifier];
	id theEnvVarriable = [envVariables objectAtIndex:rowIndex];
	NSString *currentValue = [theEnvVarriable objectForKey:identifier];
	if (![currentValue isEqualToString:anObject]) {
		[theEnvVarriable setObject:anObject forKey:identifier];
		isTableDataChanged = YES;
	}
    return;
}

#pragma mark delegate of window


#pragma mark accessors
- (void)setEnvVariables:(id)theArray
{
	[theArray retain];
	[envVariables release];
	envVariables = theArray;
}

@end
