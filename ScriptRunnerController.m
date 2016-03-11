#import "ScriptRunnerController.h"
#import "FileDatum.h"

#define useLog 0

static const int DIALOG_OK		= 128;
//static const int DIALOG_ABORT	= 129;

@implementation ScriptRunnerController

- (void)sendDataTomi:(NSString *)aText
{
#if useLog
	NSLog(@"start sendDataTomi with data : %@", aText);
#endif	
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	miDocument *doc = nil;
	NSDictionary *props = nil;
	NSString *window_title = nil;
	NSString *date_str = nil;
	switch ([user_defaults integerForKey:@"resultTreatment"]) {
		case 0:
			date_str = [[NSDate date] descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M:%S"
														timeZone:nil locale:nil];

			window_title = [NSString stringWithFormat:@"%@ -stdout- %@",
							[_currentScriptFile lastPathComponent], date_str];
			props = @{@"name": window_title, @"content": aText};
			doc = [[[_miApp classForScriptingClass:@"document"] alloc] initWithProperties:props];
			[[_miApp documents] addObject:doc];
			break;
		default:
			[_replaceTarget setTo:aText];
			break;
	};
}

#pragma mark methods for error message sheets
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode 
										contextInfo:(void *)contextInfo {
}

- (IBAction)errorOK:(id)sender
{
	[[NSApplication sharedApplication] endSheet:[sender window] returnCode:DIALOG_OK];
}

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    [sheet orderOut:self];
}

- (void)showErrorMessage:(NSString *)errorText
{	
#if useLog
	NSLog(@"didEndScriptRunner");
	NSLog(errorText);
#endif
	[[NSApplication sharedApplication] beginSheet:errorPanel 
								   modalForWindow:window
									modalDelegate:self 
								   didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) 
									  contextInfo:nil];
	[errorTextView setString:errorText];
}

- (void)showErrorMessageWithNotification:(NSNotification *)aNotification
{
	ScriptRunner *sr = [aNotification object];
	[self showErrorMessage:[sr errorString]];
}


- (void)didEndScriptRunner:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"didEndScriptRunner");
#endif
	[workingIndicator stopAnimation:self];
	[workingIndicator setHidden:YES];
	ScriptRunner *sr = [aNotification object];

	if ([sr hasErrorData]) {
		[self showErrorMessageWithNotification:aNotification];
	}
	
	if ([sr terminationStatus] != 0) return;
	
	[self sendDataTomi:[sr outputString]];
}

#pragma mark utilities
- (NSString *)performAppleScript:(NSString *)aPath withText:(NSString *)aText error:(NSError **)error
{
	NSDictionary *err_dict = nil;
	NSAppleScript *a_script = [[NSAppleScript alloc] initWithContentsOfURL:
										[NSURL fileURLWithPath:aPath] error:&err_dict];
	if (err_dict) {
		NSLog(@"Failed to load script file %@ with error :%@", aPath, err_dict);
		*error = [NSError errorWithDomain:@"FilterScriptsErrorDomain"
									 code:[err_dict[NSAppleScriptErrorNumber] intValue]
								 userInfo:err_dict];
		return NO;
	}
	
	ProcessSerialNumber psn = {0, kCurrentProcess};
	NSAppleEventDescriptor* target = [NSAppleEventDescriptor
									  descriptorWithDescriptorType:typeProcessSerialNumber
									  bytes:&psn
									  length:sizeof(ProcessSerialNumber)];
	
	NSAppleEventDescriptor* event =[NSAppleEventDescriptor 
									appleEventWithEventClass:kCoreEventClass
													 eventID:kAEOpenApplication
											targetDescriptor:target
													returnID:kAutoGenerateReturnID
												transactionID:kAnyTransactionID];

	NSAppleEventDescriptor* first_param = [NSAppleEventDescriptor descriptorWithString:aText];
    NSAppleEventDescriptor *parameters = [NSAppleEventDescriptor listDescriptor];
	[parameters insertDescriptor:first_param atIndex:1];
	[event setParamDescriptor:parameters forKeyword:keyDirectObject];
	
	NSAppleEventDescriptor *result_desc = [a_script executeAppleEvent:event error:&err_dict];
	if (err_dict) {
		NSLog(@"Failed to execute the script file %@ with error :%@", aPath, err_dict);
		*error = [NSError errorWithDomain:@"FilterScriptsErrorDomain"
									 code:[err_dict[NSAppleScriptErrorNumber] intValue]
								 userInfo:err_dict];
		return NO;
	}
#if useLog
	NSLog(@"result : %@", [result_desc stringValue]);
#endif
	return [result_desc stringValue];
}

- (void)aftertreatmentOfDoubleAction:(NSError *)error
{
    [workingIndicator stopAnimation:self];
	[workingIndicator setHidden:YES];
    
	if (error) {
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert beginSheetModalForWindow:window
						  modalDelegate:self
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
							contextInfo:nil];
	}
}

- (IBAction)doubleAction:(id)sender
{
	[workingIndicator setHidden:NO];
	[workingIndicator startAnimation:self];
	
	self.miApp = [SBApplication applicationWithBundleIdentifier:@"net.mimikaki.mi"];
	miDocument *front_doc = nil;
	NSError *error = nil;
	if ([[_miApp documents][0] exists]) {
		front_doc = [_miApp documents][0];
	} else {
		NSString *reason = @"noDocument";
		error = [NSError errorWithDomain:@"FilterScriptsErrorDomain" code:1240 
								 userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(reason, @"")}];
		return [self aftertreatmentOfDoubleAction:error];
	}
	
	self.replaceTarget = [[front_doc selectionObjects][0] propertyWithCode:'pcnt'];
	NSString *selected_text = [_replaceTarget get];
	if (![selected_text length]) {
		self.replaceTarget = [front_doc propertyWithCode:'pcnt'];
		selected_text = [_replaceTarget get];
	}
#if useLog
	NSLog(@"selected_text : %@", selected_text);
#endif
	
	// get selected script
	NSUInteger clicked_row = [scriptListView clickedRow];
	NSIndexPath *clicked_indexpath = [NSIndexPath indexPathWithIndex:clicked_row];
	NSTreeNode *controller_node = [[treeController arrangedObjects] 
								   descendantNodeAtIndexPath:clicked_indexpath];
	FileDatum *fd = [[controller_node representedObject] representedObject];
	self.currentScriptFile = [fd path];
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];	
	NSString *uti = [workspace typeOfFile:_currentScriptFile error:&error];
	if (error) {
		return [self aftertreatmentOfDoubleAction:error];
	}
#if useLog
	NSLog(@"name : %@, UTI : %@", [fd name], uti);
#endif		
	if ([workspace type:uti conformsToType:@"com.apple.applescript.script"]) {
#if useLog
		NSLog(@"confirm to applescript");	
#endif			
		NSString *result = [self performAppleScript:_currentScriptFile withText:selected_text
											  error:&error];
		if (result) {
			[self sendDataTomi:result];
		}
		return [self aftertreatmentOfDoubleAction:error];
	}
	
	ScriptRunner *sr = [ScriptRunner scriptRunnerWithFile:_currentScriptFile
													error:&error];
	if (error) {
		return [self aftertreatmentOfDoubleAction:error];
	}
	
	[sr launchTaskWithString:selected_text];
	self.currentTask = sr;
	return;
}


- (void)awakeFromNib
{
	NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
	[notiCenter addObserver:self selector:@selector(didEndScriptRunner:) 
					   name:@"ScriptRunnerDidEndNotification" object:nil];
}

@end
