#import "ScriptListController.h"
#import "ScriptRunner.h"
#import "PrefsWindowController.h"

#define useLog 0

static const int DIALOG_OK		= 128;
//static const int DIALOG_ABORT	= 129;

@implementation ScriptListController

- (IBAction)showPrefsWindow:(id)sender
{
	PrefsWindowController *prefsController = [[PrefsWindowController alloc] initWithWindowNibName:@"PreferenceWindow"];
	[[NSApplication sharedApplication] beginSheet:[prefsController window] 
								   modalForWindow:[self window] 
									modalDelegate:self 
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
									  contextInfo:nil];
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

- (void)didEndScriptRunner:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"didEndScriptRunner");
#endif
	[endOfTask performClick:self];
	ScriptRunner *theRunner = [aNotification object];
	if ([theRunner terminationStatus] != 0) {
		[self showErrorMessageWithNotification:aNotification];
	}
}

#pragma mark delgate and override and notification

- (void)saveDefaults
{
	int selectedIndex = [scriptList selectedRow];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:selectedIndex forKey:@"selectedItem"];	
	[super saveDefaults];
}

- (void)awakeFromNib
{
#if useLog
	NSLog(@"start awakeFromNib in ScriptListController");
#endif
	[self setFrameName:@"FilterScriptsPanel"];
	[self setApplicationsFloatingOnFromDefaultName:@"applicationsFloatingOn"];
	[self useFloating];
	[self useWindowCollapse];
	
	//setup notification
	NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
	[notiCenter addObserver:self selector:@selector(didEndScriptRunner:) name:@"ScriptRunnerDidEndNotification" object:nil];
}

@end
