#import "ScriptRunner.h"
#include <unistd.h>
#include <stdio.h>

#define useLog 0

@implementation ScriptRunner

NSString *readShebang(NSString *path, NSError **error)
{
	unsigned int bsize = 2048;
	char s[bsize];
	
	FILE *fp = fopen([path fileSystemRepresentation], "r" );
	if(fp == NULL){
		NSString *errmsg = [NSString stringWithCString:strerror(errno)];
		*error = [NSError errorWithDomain:@"FilterScriptsErrorDomain"
									 code:errno
								 userInfo:[NSDictionary dictionaryWithObject:errmsg
												  forKey:NSLocalizedDescriptionKey]];
		return nil;
	}
	
	if (fgets(s, bsize, fp) == NULL) {
		NSString *errmsg = [NSString stringWithCString:strerror(errno)];
		*error = [NSError errorWithDomain:@"FilterScriptsErrorDomain"
									 code:errno
								 userInfo:[NSDictionary dictionaryWithObject:errmsg
																	  forKey:NSLocalizedDescriptionKey]];
		return nil;
	}	
	fclose(fp);
	NSString *first_line = [NSString stringWithCString:s];
	NSString *command = nil;
	if ([first_line hasPrefix:@"#!"]) {
		command = [first_line substringWithRange:NSMakeRange(2, [first_line length]-3)];
	}
	return command;
}

#pragma mark init and dealloc
+ (id)scriptRunnerWithFile:(NSString *)path error:(NSError **)error
{
	NSString *command = nil;
	switch (access([path fileSystemRepresentation], X_OK)) {
		case -1:
			if (errno != EACCES) {
				NSString *errmsg = [NSString stringWithCString:strerror(errno)];
				*error = [NSError errorWithDomain:@"FilterScriptsErrorDomain"
											 code:errno
										 userInfo:[NSDictionary dictionaryWithObject:errmsg
													  forKey:NSLocalizedDescriptionKey]];
				return nil;
			}
			command = readShebang(path, error);
			if (!command) {
				if (!error) {
					NSString *errmsg = NSLocalizedString(@"The document does not start with #!.",
														 @"");
					*error = [NSError errorWithDomain:@"FilterScriptsErrorDomain"
												 code:1620
											 userInfo:[NSDictionary dictionaryWithObject:errmsg
														  forKey:NSLocalizedDescriptionKey]];
				}
				return nil;
			}
			break;
		case 0:
			break;
		default:
			return nil;
			break;
	};
	
	return [[[self alloc] initWithLoginShellAndScriptFile:path withCommand:command] autorelease];
}

- (id)init
{
	self = [super init];
	isTaskEnded = NO;
	isGetDataEnded = NO;
	isGetErrorDataEnded = NO;
	return self;
}

- (id)initWithLoginShellAndScriptFile:(NSString *)path withCommand:(NSString *)command
{
#if useLog
	NSLog(@"start initWithLoginShellAndScriptFile");
#endif	
	[self init];
	[self setScriptTask:[[NSTask new] autorelease]];
	NSString *dir_path = [path stringByDeletingLastPathComponent];
	[scriptTask setCurrentDirectoryPath:dir_path];
	
	[scriptTask setStandardError:[NSPipe pipe]];
	[scriptTask setStandardOutput:[NSPipe pipe]];
	
	
	char *ls = getenv("SHELL");
	NSString *login_shell = [NSString stringWithUTF8String:ls];
	[scriptTask setLaunchPath:login_shell];
	NSMutableArray *arguments = [NSMutableArray arrayWithObject:@"-lc"];
	if (command) {
		[arguments addObject:
			[NSString stringWithFormat:@"%@ \"$0\"", command]];
		[arguments addObject:path];
	} else {
		[arguments addObject:@"\"$0\""]; // to allow path contain '"'.
		[arguments addObject:path];
	}

	[scriptTask setArguments:arguments];
#if useLog
	NSLog(@"arguments : %@", arguments);
#endif	
	outputData = [[NSMutableData data] retain];
	errorData = [[NSMutableData data] retain];
	
	return self;
}

- (id)initWithScriptFile:(NSString *)path withCommand:(NSString *)command
{
#if useLog
	NSLog(@"start initWithScriptFile");
#endif
	[self init];
	[self setScriptTask:[self taskWithEnviroments]];
	NSString *dirPath = [path stringByDeletingLastPathComponent];
	[scriptTask setCurrentDirectoryPath:dirPath];
	
	[scriptTask setStandardError:[NSPipe pipe]];
	[scriptTask setStandardOutput:[NSPipe pipe]];
	
	//set launch path
	NSString *command_path;
	
	if (command) {
		command = [command stringByTrimmingCharactersInSet:
				   [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		
		NSScanner *command_scanner = [NSScanner scannerWithString:command]; 
		NSCharacterSet *chSet = [NSCharacterSet whitespaceCharacterSet];
		
		[command_scanner scanUpToCharactersFromSet:chSet intoString:&command_path];
		
		if (![command_path isAbsolutePath]) {
			command_path = [self findCommandPath:command_path];
			if (command_path == nil) {
				return nil;
			}
		}
		//set arguments
		NSString *argString;
		NSMutableArray *argArray = [NSMutableArray array];
		while (![command_scanner isAtEnd]) {
			[command_scanner scanCharactersFromSet:chSet intoString:nil];
			if ([command_scanner scanUpToCharactersFromSet:chSet intoString:&argString]) {
				[argArray addObject:argString];
			}
		}
		[argArray addObject:path];
		[scriptTask setArguments:argArray];		
	} else {
		command_path = path;
	}
	
	[scriptTask setLaunchPath:command_path];
	
	outputData = [[NSMutableData data] retain];
	errorData = [[NSMutableData data] retain];
#if useLog
	NSLog(@"end initWithScriptFile");
#endif
	return self;
}

- (void)dealloc
{
	[scriptTask release];
	[outputData release];
	[errorData release];
	[super dealloc];
}

#pragma mark internal methods of setup task
- (NSString *)findCommandPath:(NSString *)commandPath
{
	NSTask *whichTask = [self taskWithEnviroments];
	NSPipe *outputPipe = [NSPipe pipe];
	
	[whichTask setLaunchPath:@"/usr/bin/which"];
	[whichTask setArguments:[NSArray arrayWithObject:commandPath]];
	[whichTask setStandardOutput:outputPipe];
	[whichTask launch];
	[whichTask waitUntilExit];
	
	NSFileHandle *outHandle = [outputPipe fileHandleForReading];
	NSData *outData = [outHandle availableData];
	NSString *whichResult = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
	[whichResult autorelease];
	if ([whichResult hasPrefix:@"no "]) {
		return nil;
	}
	else {
		return [whichResult stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	}
}

- (NSTask *)taskWithEnviroments
{
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	NSArray *enviromentVariables = [userDefaults arrayForKey:@"enviromentVariables"];
	NSEnumerator *envVarEnumerator = [enviromentVariables objectEnumerator];
	NSMutableDictionary *envDict = [NSMutableDictionary dictionaryWithCapacity:[enviromentVariables count]];
	
	NSDictionary *theDict;
	while (theDict = [envVarEnumerator nextObject]) {
		NSString *theValue = [theDict objectForKey:@"value"];
		NSString *theName = [theDict objectForKey:@"name"];
		[envDict setObject:theValue forKey:theName];
	}
	//NSDictionary *envDict = [NSDictionary dictionaryWithObjectsAndKeys:@"/usr/local/bin:/usr/bin:/bin",@"PATH",nil];
	
	NSTask *aTask = [[NSTask alloc] init];	
	[aTask setEnvironment:envDict];
	return aTask;
}

#pragma mark read wirte data

- (void)sendData:(NSString *)inputString
{
#if useLog
	NSLog(@"start sendData");
#endif
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
   	NSMutableString *string = [inputString mutableCopy];
	[string replaceOccurrencesOfString:@"\r" withString:@"\n" options:0 
								 range: NSMakeRange(0, [inputString length])];
#if useLog
	NSLog(@"sending data : %@", string);
#endif	
	NSData *inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
	NSFileHandle *inputHandle;
	inputHandle = [[scriptTask standardInput] fileHandleForWriting];
	@try {
		[inputHandle writeData:inputData];
	}
	@catch (NSException *exception) {
		NSLog(@"sendData: Caught %@: %@", [exception name], [exception reason]);
	}
	[inputHandle closeFile];
	[pool release];
#if useLog
	NSLog(@"end of sendData");
#endif
}

- (void)afterDidEndTask:(NSNotification *)aNotification
{
	NSNotificationCenter *notification_center = [NSNotificationCenter defaultCenter];
	[notification_center removeObserver:self];
	[notification_center postNotificationName:@"ScriptRunnerDidEndNotification" object:self];
}

- (void)getData: (NSNotification *)aNotification
{
#if useLog
	NSLog(@"start getData");
#endif
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length])
    {
		[outputData appendData:data];
		[[aNotification object] readInBackgroundAndNotify];
    } else {
#if useLog
        NSLog(@"No output data");
#endif
		isGetDataEnded = YES;
		if (isGetDataEnded & isGetErrorDataEnded & isTaskEnded) {
			[self afterDidEndTask:aNotification];
		}
    }
}

-(void)getErrorData: (NSNotification *)aNotification
{
#if useLog
	NSLog(@"start getErrorData");
#endif
    NSData *data = [[aNotification userInfo] objectForKey:NSFileHandleNotificationDataItem];
    if ([data length])
    {
		[errorData appendData:data];
		[[aNotification object] readInBackgroundAndNotify];
    } else {
#if useLog
        NSLog(@"No  errorData");
#endif
		isGetErrorDataEnded = YES;
		if (isGetDataEnded & isGetErrorDataEnded & isTaskEnded) {
			[self afterDidEndTask:aNotification];
		}
    }
}

- (void)didEndTask:(NSNotification *)aNotification
{
#if useLog
	NSLog(@"start didEndTask");
#endif
	/*
	[[NSNotificationCenter defaultCenter] removeObserver:self 
										name:NSFileHandleReadCompletionNotification 
										object: [[scriptTask standardOutput] fileHandleForReading]];
	 
	int status = [[aNotification object] terminationStatus];

    NSData *theData;
	if (status == 0) {
#if useLog
		NSLog(@"task finished with status 0");
#endif
		NSPipe *outPipe = [scriptTask standardOutput];
		NSFileHandle *outHandle = [outPipe fileHandleForReading];
		//theData = [outHandle availableData];
		theData = [outHandle readDataToEndOfFile];
		if ([theData length]) {
			[outputData appendData:theData];
		}
	}
	else {
#if useLog
		NSLog(@"task did not finish with status 0");
#endif
	}

	NSPipe *errorPipe = [scriptTask standardError];
	NSFileHandle *errorHandle = [errorPipe fileHandleForReading];
	theData = [errorHandle availableData];
	if ([theData length]) {
		[errorData appendData:theData];
	}
	
	NSNotificationCenter *notification_center = [NSNotificationCenter defaultCenter];
	[notification_center postNotificationName:@"ScriptRunnerDidEndNotification" object:self];
	//[notification_center removeObserver:self];
	 */
	isTaskEnded = YES;
	if (isGetDataEnded & isGetErrorDataEnded & isTaskEnded) {
		[self afterDidEndTask:aNotification];
	}
#if useLog
	NSLog(@"end of didEndTask");
#endif
}

#pragma mark public methods
- (void)launchTaskWithString:(NSString *)inputString;
{
#if useLog
	NSLog(@"start launchTaskWithString");
#endif
	NSPipe *inputPipe = [NSPipe pipe];
	[scriptTask setStandardInput:inputPipe];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(getData:) 
												 name: NSFileHandleReadCompletionNotification 
											   object: [[scriptTask standardOutput] fileHandleForReading]];
	 [[[scriptTask standardOutput] fileHandleForReading] readInBackgroundAndNotify];
	 
	 [[NSNotificationCenter defaultCenter] addObserver:self 
											  selector:@selector(getErrorData:) 
												  name: NSFileHandleReadCompletionNotification 
												object: [[scriptTask standardError] fileHandleForReading]];
	 [[[scriptTask standardError] fileHandleForReading] readInBackgroundAndNotify];
	 
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndTask:) 
												 name:NSTaskDidTerminateNotification object:scriptTask];
	
#if useLog
	NSLog(@"task will launch");
#endif
	@try{
		[scriptTask launch];
	}
	@catch (NSException *exception) {
		NSLog(@"launchTaskWithString: Caught %@: %@", [exception name], [exception reason]);
	}
	
#if useLog
	NSLog(@"after task launch");
#endif
	[NSThread detachNewThreadSelector:@selector(sendData:)
							 toTarget:self withObject:inputString];
#if useLog	
	NSLog(@"end launchTaskWithString");
#endif
}

- (BOOL)hasErrorData
{
	return ([errorData length] != 0);
}

- (NSString *)errorString
{
	NSMutableString *string = [[[NSMutableString alloc] initWithData:errorData 
															encoding:NSUTF8StringEncoding] 
																autorelease];
	return string;
}

- (NSString *)outputString
{
	NSMutableString *string = [[[NSMutableString alloc] initWithData:outputData 
															encoding:NSUTF8StringEncoding] 
																	autorelease];
	[string replaceOccurrencesOfString:@"\n" withString:@"\r" options:0 
								 range: NSMakeRange(0, [string length])];
	return string;
}

- (int)terminationStatus
{
	return [scriptTask terminationStatus];
}

- (NSString *)standardOutput
{
	NSPipe *outPipe = [scriptTask standardOutput];
	NSFileHandle *outHandle = [outPipe fileHandleForReading];
	NSData *ouputData = [outHandle availableData];
	return [[[NSString alloc] initWithData:ouputData encoding:NSUTF8StringEncoding] autorelease];
}

- (NSString *)standardError
{
	NSData *ouputData = [[[scriptTask standardError] fileHandleForReading] readDataToEndOfFile];
	return [[[NSString alloc] initWithData:ouputData encoding:NSUTF8StringEncoding] autorelease];
}

#pragma mark accessor methods
- (void)setScriptTask:(NSTask *)aTask
{
	[aTask retain];
	[scriptTask release];
	scriptTask = aTask;
}

@end
