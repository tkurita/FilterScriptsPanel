#import "AppController.h"

@implementation AppController

- (void)checkQuit:(NSTimer *)aTimer
{
	NSArray *appList = [[NSWorkspace sharedWorkspace] launchedApplications];
	NSEnumerator *enumerator = [appList objectEnumerator];
	
	id appDict;
	BOOL isMiLaunched = NO;
	while (appDict = [enumerator nextObject]) {
		NSString *appName = [appDict objectForKey:@"NSApplicationName"];
		if ([appName isEqualToString:appName] ) {
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
	//NSLog(@"anApplicationIsTerminated");
	NSString *appName = [[aNotification userInfo] objectForKey:@"NSApplicationName"];
	//NSLog(appName);
	if ([appName isEqualToString:@"mi"] ) [[NSApplication sharedApplication] terminate:self];
}

#pragma mark delegate of NSApplication
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	NSLog(@"start applicationDidFinishLaunching");
	appQuitTimer = [NSTimer scheduledTimerWithTimeInterval:60*60 target:self selector:@selector(checkQuit:) userInfo:nil repeats:YES];
	[appQuitTimer retain];
	
	NSNotificationCenter *notifyCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
	[notifyCenter addObserver:self selector:@selector(anApplicationIsTerminated:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
	
	NSString *defaultsPlistPath = [[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"];
	NSDictionary *defautlsDict = [NSDictionary dictionaryWithContentsOfFile:defaultsPlistPath];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults registerDefaults:defautlsDict];
	//NSArray *tmpEnvVariables = [userDefaults arrayForKey:@"enviromentVariables"];
	//NSLog([tmpEnvVariables description]);
}

@end
