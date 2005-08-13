/* PaletteWindowController */

#import <Cocoa/Cocoa.h>

@interface PaletteWindowController : NSWindowController
{
    IBOutlet id errorPanel;
    IBOutlet id errorTextView;
    IBOutlet id newScriptPanel;
    IBOutlet id progressIndicator;
	IBOutlet id scriptList;
	IBOutlet id scrollView;
	NSTimer *displayToggleTime;
	BOOL isCollapsed;
	NSRect expandedRect;
	NSString *frameName;
	NSRect scriptListFrame;
}
- (IBAction)errorOK:(id)sender;
- (IBAction)newScriptCancel:(id)sender;
- (IBAction)newScriptOK:(id)sender;
- (IBAction)showPrefsWindow:(id)sender;

- (void)setDisplayToggleTime;
- (void)updateVisibility:(NSTimer *)theTimer;
- (float)titleBarHeight;
- (void)toggleCollapseWithDisplay:(BOOL)flag;
- (void)collapseAction;
- (void)showErrorMessage:(NSString *)errorText;

@end
