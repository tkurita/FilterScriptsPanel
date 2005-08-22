
#import <Cocoa/Cocoa.h>
#import "PaletteWindowController.h"

@interface ScriptListController : PaletteWindowController 
{
    IBOutlet id errorPanel;
    IBOutlet id errorTextView;
    IBOutlet id newScriptPanel;
    IBOutlet id progressIndicator;
	IBOutlet id scriptList;
}

- (IBAction)errorOK:(id)sender;
- (IBAction)newScriptCancel:(id)sender;
- (IBAction)newScriptOK:(id)sender;
- (IBAction)showPrefsWindow:(id)sender;
- (void)showErrorMessage:(NSString *)errorText;

@end
