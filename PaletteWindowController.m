#import "PaletteWindowController.h"
#import "ScriptRunner.h"
#import "PrefsWindowController.h"

static const int DIALOG_OK		= 128;
//static const int DIALOG_ABORT	= 129;

@implementation PaletteWindowController

#pragma mark init and actions
- (id)init
{
	[super init];
	isCollapsed = NO;
	frameName = @"FilterScriptsPanel";
	return self;
}

- (IBAction)showWindow:(id)sender
{
	//NSLog(@"showWindow");
	[super showWindow:sender];
	[self setDisplayToggleTime];
	//[self toggleCollapse];
}

- (IBAction)showPrefsWindow:(id)sender
{
	PrefsWindowController *prefsController = [[PrefsWindowController alloc] initWithWindowNibName:@"PreferenceWindow"];
	[[NSApplication sharedApplication] beginSheet:[prefsController window] 
								   modalForWindow:[self window] 
									modalDelegate:self 
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
									  contextInfo:nil];
}


#pragma mark methods for others
- (void)saveDefaults:(NSNotification *)aNotification
{
	int selectedIndex = [scriptList selectedRow];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:selectedIndex forKey:@"selectedItem"];	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark methods for sheets
- (IBAction)newScriptCancel:(id)sender
{
}

- (IBAction)newScriptOK:(id)sender
{
}

#pragma mark methods for error message sheets
- (IBAction)errorOK:(id)sender
{
	[[NSApplication sharedApplication] endSheet: [sender window] returnCode:DIALOG_OK];
}

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    [sheet orderOut:self];
}

- (void)showErrorMessage:(NSString *)errorText
{	
	[[NSApplication sharedApplication] beginSheet:errorPanel 
								   modalForWindow:[self window] 
									modalDelegate:self 
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
									  contextInfo:nil];
	[errorTextView setString:errorText];
}

- (void)showErrorMessageWithNotification:(NSNotification *)aNotification
{
	ScriptRunner *theRunner = [aNotification object];
	[self showErrorMessage:[theRunner standardError]];
}


#pragma mark methods for collapsing
- (float)titleBarHeight
{
	id theWindow = [self window];
	 NSRect windowRect = [theWindow frame];
	 NSRect contentRect = [NSWindow contentRectForFrameRect:windowRect
												  styleMask:[theWindow styleMask]];
	 //NSRect contentRect = [[theWindow contentView] frame];
	 return NSHeight(windowRect) - NSHeight(contentRect);
}

- (void)collapseAction
{
	[self toggleCollapseWithDisplay:NO];
}

- (void)toggleCollapseWithDisplay:(BOOL)flag
{
	id theWindow = [self window];
	NSRect windowRect = [theWindow frame];

	if (isCollapsed) {
		windowRect.origin.y = windowRect.origin.y - expandedRect.size.height + windowRect.size.height;
		windowRect.size.height = expandedRect.size.height;
		[theWindow setFrame:windowRect display:flag animate:flag];
		[theWindow saveFrameUsingName:frameName];
		[scrollView setFrame:scriptListFrame];
		isCollapsed = NO;
		
	}
	else {
		expandedRect = windowRect;
		NSRect contentRect = [NSWindow contentRectForFrameRect:windowRect styleMask:[theWindow styleMask]];
		scriptListFrame = [scrollView frame];
		windowRect.origin.y = windowRect.origin.y + NSHeight(contentRect);
		windowRect.size.height = NSHeight(windowRect) - NSHeight(contentRect);
		[theWindow saveFrameUsingName:frameName];
		[theWindow setFrame:windowRect display:flag animate:flag];
		
		isCollapsed = YES;		
	}
}

- (void)updateVisibility:(NSTimer *)theTimer
{
	NSString *appName = [[[NSWorkspace sharedWorkspace] activeApplication] objectForKey:@"NSApplicationName"];
	if (appName == nil) {
		return;
	}

	id theWindow = [self window];
	if ([appName isEqualToString:@"mi"]) {
		if (![theWindow isVisible]) [super showWindow:self];
	}
	else {
		if ([theWindow isVisible]) {
			if ([theWindow attachedSheet] == nil) [self close];	
		}
	}
}

- (void)setDisplayToggleTime
{
	[displayToggleTime release];
	displayToggleTime = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateVisibility:) userInfo:nil repeats:YES];
	[displayToggleTime retain];
}

#pragma mark delegates
- (void)windowWillClose:(NSNotification *)aNotification
{
	NSLog(@"start windowWillClose:");
	if (!isCollapsed) [[aNotification object] saveFrameUsingName:frameName];
	int selectedIndex = [scriptList selectedRow];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:selectedIndex forKey:@"selectedItem"];
	//[userDefaults synchronize];
}

- (BOOL)windowShouldClose:(id)sender
{
	NSLog(@"windowShouldClose");
	[displayToggleTime invalidate];
	if (!isCollapsed) [sender saveFrameUsingName:frameName];
	return YES;
}

- (void)awakeFromNib
{
	NSLog(@"start awakeFromNib in PaletteWindowController");
	id theWindow = [self window];
	[theWindow center];
	//[theWindow setFrameAutosaveName:@"FilterScriptsPanel"];	
	//setup window properties
	[theWindow setFrameUsingName:frameName];
	[theWindow setHidesOnDeactivate:NO];
	[theWindow setLevel:NSFloatingWindowLevel];
	[theWindow setWindowController:self];
	
	//set zoom button
	NSButton *zoomButton = [theWindow standardWindowButton:NSWindowZoomButton];
	[zoomButton setTarget:self];
	[zoomButton setAction:@selector(collapseAction)];
	
	//setup notification
	NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
	[notiCenter addObserver:self selector:@selector(showErrorMessageWithNotification:) name:@"ScriputRunnerDidEndWithError" object:nil];
	[notiCenter addObserver:self selector:@selector(saveDefaults:) name:NSApplicationWillTerminateNotification object:nil];
	//read apply user defaults
	NSLog(@"end awakeFromNib in PaletteWindowController");
}
@end
