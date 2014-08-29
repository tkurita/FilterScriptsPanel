#import "ScriptRunnerController.h"
#import "FileDatum.h"

#define useLog 0

static const int DIALOG_OK		= 128;
//static const int DIALOG_ABORT	= 129;

@implementation ScriptRunnerController

@synthesize replaceTarget;
@synthesize currentTask;
@synthesize miApp;
@synthesize currentScriptFile;

- (void)dealloc
{
	[currentTask release];
	[replaceTarget release];
	[miApp release];
	[currentScriptFile release];
	[super dealloc];
}

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
							[currentScriptFile lastPathComponent], date_str];
			props = [NSDictionary dictionaryWithObjectsAndKeys:
							window_title, @"name", aText, @"content", nil];
			doc = [[[miApp classForScriptingClass:@"document"] alloc] initWithProperties:props];
			[[miApp documents] addObject:doc];
			[doc autorelease];
			break;
		default:
			[replaceTarget setTo:aText];
			break;
	};
}

#pragma mark methods for error message sheets
- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode 
										contextInfo:(void *)contextInfo {
    [alert release];	 
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
	if (a_script) [a_script autorelease];
	if (err_dict) {
		NSLog(@"Failed to load script file %@ with error :%@", aPath, err_dict);
		*error = [NSError errorWithDomain:@"FilterScriptsErrorDomain"
									 code:[[err_dict objectForKey:NSAppleScriptErrorNumber] intValue]
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
									 code:[[err_dict objectForKey:NSAppleScriptErrorNumber] intValue]
								 userInfo:err_dict];
		return NO;
	}
#if useLog
	NSLog(@"result : %@", [result_desc stringValue]);
#endif
	return [result_desc stringValue];
}

- (IBAction)doubleAction:(id)sender
{
	[workingIndicator setHidden:NO];
	[workingIndicator startAnimation:self];
	
	self.miApp = [SBApplication applicationWithBundleIdentifier:@"net.mimikaki.mi"];
	miDocument *front_doc = nil;
	NSError *error = nil;
	if ([[[miApp documents] objectAtIndex:0] exists]) {
		front_doc = [[miApp documents] objectAtIndex:0];
	} else {
		NSString *reason = @"noDocument";
		error = [NSError errorWithDomain:@"FilterScriptsErrorDomain" code:1240 
								 userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(reason, @"")
																	  forKey:NSLocalizedDescriptionKey]];
		goto bail;
	}
	
	self.replaceTarget = [[[front_doc selectionObjects] objectAtIndex:0] propertyWithCode:'pcnt'];
	NSString *selected_text = [replaceTarget get];
	if (![selected_text length]) {
		self.replaceTarget = [front_doc propertyWithCode:'pcnt'];
		selected_text = [replaceTarget get];
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
	NSString *uti = [workspace typeOfFile:currentScriptFile error:&error];
	if (error) {
		goto bail;
	}
#if useLog
	NSLog(@"name : %@, UTI : %@", [fd name], uti);
#endif		
	if ([workspace type:uti conformsToType:@"com.apple.applescript.script"]) {
#if useLog
		NSLog(@"confirm to applescript");	
#endif			
		NSString *result = [self performAppleScript:currentScriptFile withText:selected_text 
											  error:&error];
		if (result) {
			[self sendDataTomi:result];
		}
		goto bail;
	}
	
	ScriptRunner *sr = [ScriptRunner scriptRunnerWithFile:currentScriptFile
													error:&error];
	if (error) {
		goto bail;
	}
	
	[sr launchTaskWithString:selected_text];
	self.currentTask = sr;
	return;
bail:
	[workingIndicator stopAnimation:self];
	[workingIndicator setHidden:YES];

	if (error) {
		NSAlert *alert = [[NSAlert alertWithError:error] retain];
		[alert beginSheetModalForWindow:window
						  modalDelegate:self 
						 didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
							contextInfo:nil];
	}
}


- (void)awakeFromNib
{
	NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
	[notiCenter addObserver:self selector:@selector(didEndScriptRunner:) 
					   name:@"ScriptRunnerDidEndNotification" object:nil];
}

@end
