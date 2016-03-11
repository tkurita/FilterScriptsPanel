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
}

@property (strong) SBObject *replaceTarget;
@property (strong) ScriptRunner *currentTask;
@property (strong) miApplication *miApp;
@property (strong) NSString *currentScriptFile;

- (IBAction)errorOK:(id)sender;

@end
