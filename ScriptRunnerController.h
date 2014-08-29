#import <Cocoa/Cocoa.h>
#import "ScriptRunner.h"
#import <ScriptingBridge/ScriptingBridge.h>
#import "mi.h"

@interface ScriptRunnerController : NSObject {
	IBOutlet id workingIndicator;
	IBOutlet id scriptListView;
	IBOutlet id treeController;
	IBOutlet id window;
	IBOutlet id errorPanel;
	IBOutlet id errorTextView;
	SBObject *replaceTarget;
	miApplication *miApp;
	ScriptRunner *currentTask;
	NSString *currentScriptFile;
}

@property (retain) SBObject *replaceTarget;
@property (retain) ScriptRunner *currentTask;
@property (retain) miApplication *miApp;
@property (retain) NSString *currentScriptFile;

- (IBAction)errorOK:(id)sender;

@end
