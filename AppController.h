#import <Cocoa/Cocoa.h>
#import "ListWindowController.h"

@interface AppController : NSObject
{
	NSTimer *appQuitTimer;
	NSWindowController *listWindowController;
}

- (void)anApplicationIsTerminated:(NSNotification *)aNotification;
- (void)checkQuit:(NSTimer *)aTimer;

@end
