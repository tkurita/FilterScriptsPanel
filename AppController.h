#import <Cocoa/Cocoa.h>
#import "ListWindowController.h"

@interface AppController : NSObject

@property (nonatomic) NSTimer* appQuitTimer;
@property (nonatomic) NSWindowController *listWindowController;

- (void)anApplicationIsTerminated:(NSNotification *)aNotification;
- (void)checkQuit:(NSTimer *)aTimer;

@end
