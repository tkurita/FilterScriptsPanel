#import "ListWindowController.h"
#import "ScriptRunner.h"
#import "PathExtra.h"

#define useLog 0

@implementation ListWindowController

- (void)sheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    [sheet orderOut:self];
}


#pragma mark methods for sheets

- (void)templateSheetDidEnd:(NSWindow*)sheet returnCode:(int)returnCode contextInfo:(void*)contextInfo
{
    [sheet orderOut:self];
}

- (IBAction)newScriptCancel:(id)sender
{
	[NSApp endSheet:[sender window] returnCode:[sender tag]];
}

- (IBAction)newScriptOK:(id)sender
{
	[NSApp endSheet:[sender window] returnCode:[sender tag]];
	NSString *new_name = [newScriptNameField stringValue];

	NSString *template_path = [[templateTreeViewController selectedPaths] lastObject];
	NSLog(@"template path : %@", template_path);
	[scriptTreeViewController insertCopyingPath:template_path
									   withName:new_name];
	 
}

- (IBAction)showNewScriptSheet:(id)sender
{
	[[NSApplication sharedApplication] beginSheet:newScriptPanel 
								   modalForWindow:[self window]
									modalDelegate:self 
								   didEndSelector:@selector(templateSheetDidEnd:returnCode:contextInfo:) 
									  contextInfo:nil];
}

- (void)saveDefaults
{

	NSArray *selection_indexpaths = [treeController selectionIndexPaths];
#if useLog
	NSLog(@"selection indexpaths : %@", selection_indexpaths);
#endif	
	NSUserDefaults *user_defaults = [NSUserDefaults standardUserDefaults];
	[user_defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:selection_indexpaths]
					  forKey:@"selectionIndexPaths"];
	[super saveDefaults];
}

- (NSURL *)findmiFolder
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *error = nil;
	NSURL *app_support_folder = [fm URLForDirectory:NSApplicationSupportDirectory
										   inDomain:NSUserDomainMask
								  appropriateForURL:nil
											 create:NO error:&error];
	NSURL *mi_support_folder = [app_support_folder URLByAppendingPathComponent:@"mi3"];
	NSString *mi_support_folder_path = [mi_support_folder path];
#if useLog
	//return mi_support_folder; // for debug
#endif	
	NSString *fspanel_path = [[NSBundle mainBundle] bundlePath];
	
	if ([mi_support_folder_path fileExists]) {
		if ([fspanel_path hasPrefix:mi_support_folder_path]) {
			return mi_support_folder;
		}
	}
	
	mi_support_folder = [app_support_folder URLByAppendingPathComponent:@"mi"];
	mi_support_folder_path = [mi_support_folder path];
	if ([mi_support_folder_path fileExists]) {
		// if ([fspanel_path hasPrefix:mi_support_folder_path])
			return mi_support_folder;
	}
	// mi folder under preferences folder is not supported.
	// 2.1.11b3 or later is required.
	
	return nil;
}

- (NSString *)resolveFolderPath:(NSString *)folderName directory:(NSString *)dirPath;
{

	
	NSString *filter_scripts_folder = [dirPath stringByAppendingPathComponent:@"FilterScripts"];
	NSString *scripts_in_filterscripts = [filter_scripts_folder stringByAppendingPathComponent:folderName];
	if ([scripts_in_filterscripts fileExists]) return scripts_in_filterscripts;
	
	NSString *script_zip_path = [[NSBundle mainBundle] pathForResource:folderName 
																ofType:@"zip"];
	if (!script_zip_path) {
		NSLog(@"Can't find Scripts.zip in the main bundle.");
		return nil;
	}
	NSTask *task = [NSTask launchedTaskWithLaunchPath:@"/usr/bin/ditto"
											arguments:@[@"--sequesterRsrc", @"-x", @"-k",
													   script_zip_path, filter_scripts_folder]];
	[task waitUntilExit];
	if ([task terminationStatus] != 0) {
		goto bail;
	}
	
	if ([scripts_in_filterscripts fileExists]) return scripts_in_filterscripts; 
bail:
	NSLog(@"Fail to make a Scripts folder");
	return nil;
}

- (void)awakeFromNib
{
#if useLog
	NSLog(@"start awakeFromNib in ListWindowController");
#endif
	[self setFrameName:@"FilterScriptsPanel"];
	//[self setApplicationsFloatingOnFromDefaultName:@"applicationsFloatingOn"];
	[self bindApplicationsFloatingOnForKey:@"applicationsFloatingOn"];
	[self useFloating];
	[self useWindowCollapse];
	
	NSURL *mi_folder = [self findmiFolder];
	if (!mi_folder) return;
	
	
	[scriptTreeViewController setRootDirPath:
			[self resolveFolderPath:@"Scripts" directory:[mi_folder path]]];
	[templateTreeViewController setRootDirPath:
	 [self resolveFolderPath:@"Templates" directory:[mi_folder path]]];
	
	NSData *ud_data = [[NSUserDefaults standardUserDefaults] objectForKey:@"selectionIndexPaths"];
	if (ud_data) {
		NSArray *selection_indexpath = [NSKeyedUnarchiver unarchiveObjectWithData:ud_data];
		if ([selection_indexpath count]) {
			[treeController setSelectionIndexPaths:selection_indexpath];
		}
	}
}



@end
