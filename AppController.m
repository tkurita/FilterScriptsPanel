#import "AppController.h"
#import "CocoaLib/PaletteWindowController.h"
#import "CocoaLib/WindowVisibilityController.h"
#import "DonationReminder/DonationReminder.h"
#import "PathExtra.h"

#define useLog 0
#include <signal.h>

@implementation AppController


- (void)checkQuit:(NSTimer *)aTimer
{
	NSArray *appList = [[NSWorkspace sharedWorkspace] launchedApplications];
	NSEnumerator *enumerator = [appList objectEnumerator];
	
	id appDict;
	BOOL isMiLaunched = NO;
	while (appDict = [enumerator nextObject]) {
		NSString *app_identifier = [appDict objectForKey:@"NSApplicationBundleIdentifier"];
		if ([app_identifier isEqualToString:@"net.mimikaki.mi"] ) {
			isMiLaunched = YES;
			break;
		}		
	}
	
	if (! isMiLaunched) {
		[[NSApplication sharedApplication] terminate:self];
	}
}

- (void)anApplicationIsTerminated:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"anApplicationIsTerminated");
#endif
	NSDictionary *user_info = [aNotification userInfo];
	NSString *identifier = [user_info objectForKey:@"NSApplicationBundleIdentifier"];
	if ([identifier isEqualToString:@"net.mimikaki.mi"] ) [[NSApplication sharedApplication] terminate:self];
	
}

#pragma mark delegate of NSApplication
- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"start applicationWillFinishLaunching");
#endif
	NSString *defaultsPlistPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *defautlsDict = [NSDictionary dictionaryWithContentsOfFile:defaultsPlistPath];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:defautlsDict];
	signal(SIGPIPE, SIG_IGN);
	[PaletteWindowController setVisibilityController:[[[WindowVisibilityController alloc] init] autorelease]];
	id donationReminder = [DonationReminder remindDonation];
	if (donationReminder != nil) [NSApp activateIgnoringOtherApps:YES];
}

- (void)showWindow:(id)sender
{
	[listWindowController showWindow:self];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"start applicationDidFinishLaunching");
#endif
	appQuitTimer = [NSTimer scheduledTimerWithTimeInterval:60*60 target:self selector:@selector(checkQuit:) userInfo:nil repeats:YES];
	[appQuitTimer retain];
	
	NSNotificationCenter *notifyCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	[notifyCenter addObserver:self selector:@selector(anApplicationIsTerminated:) 
						 name:NSWorkspaceDidTerminateApplicationNotification object:nil];
	
	listWindowController = [[ListWindowController alloc] initWithWindowNibName:@"NewScriptWindow"];
	[listWindowController showWindow:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
#if useLog	
	NSLog(@"willl application terminate");
#endif	
}

@end
