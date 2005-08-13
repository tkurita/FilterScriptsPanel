/* PrefsWindowController */

#import <Cocoa/Cocoa.h>

@interface PrefsWindowController : NSWindowController
{
    IBOutlet id envVariableTable;
    IBOutlet id OKButton;
	
	id envVariables;
	BOOL isTableDataChanged;
}
- (IBAction)okAction:(id)sender;
- (IBAction)addRecrodAction:(id)sender;
- (IBAction)removeRecrodAction:(id)sender;
- (IBAction)cancelAction:(id)sender;

- (void)setEnvVariables:(id)theArray;

@end
