#import <Cocoa/Cocoa.h>
#import "PaletteWindowController.h"
#import "FileTreeDataController.h"

@interface ListWindowController : PaletteWindowController
{
    IBOutlet id newScriptPanel;
	IBOutlet NSTreeController *treeController;
	IBOutlet FileTreeDataController *scriptTreeViewController;
	IBOutlet FileTreeDataController *templateTreeViewController;
	IBOutlet NSTextField *newScriptNameField;
}

- (IBAction)showNewScriptSheet:(id)sender;
- (IBAction)newScriptCancel:(id)sender;
- (IBAction)newScriptOK:(id)sender;

@end
