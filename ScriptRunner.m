#import "ScriptRunner.h"

#define useLog 0

@implementation ScriptRunner

#pragma mark init and dealloc

- (id)initWithScriptFile:(NSString *)path withCommand:(NSString *)command;
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
	command = [command stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	NSScanner *commandScanner = [NSScanner scannerWithString:command]; 
	NSCharacterSet *chSet = [NSCharacterSet whitespaceCharacterSet];
	NSString *commandPath;
	[commandScanner scanUpToCharactersFromSet:chSet intoString:&commandPath];
	
	if (![commandPath isAbsolutePath]) {
		commandPath = [self findCommandPath:commandPath];
		if (commandPath == nil) {
			return nil;
		}
	}
	
	[scriptTask setLaunchPath:commandPath];
	
	//set arguments
	NSString *argString;
	NSMutableArray *argArray = [NSMutableArray array];
	while (![commandScanner isAtEnd]) {
		[commandScanner scanCharactersFromSet:chSet intoString:nil];
		if ([commandScanner scanUpToCharactersFromSet:chSet intoString:&argString]) {
			[argArray addObject:argString];
		}
	}
	[argArray addObject:path];
	[scriptTask setArguments:argArray];
	
	//setup notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndTask:) name:NSTaskDidTerminateNotification object:scriptTask];
	
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
	if ([whichResult startWith:@"no "]) {
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
	[string replaceOccurrencesOfString:@"\r" withString:@"\n" options:nil range: NSMakeRange(0, [inputString length])];

	NSData *inputData = [string dataUsingEncoding:NSUTF8StringEncoding];
	@try {
		NSFileHandle *inputHandle = [[scriptTask standardInput] fileHandleForWriting];
		[inputHandle writeData:inputData];
		[inputHandle closeFile];
	}
	@catch (NSException *exception) {
		NSLog(@"main: Caught %@: %@", [exception name], [exception reason]);
	}
	[pool release];
#if useLog
	NSLog(@"end of sendData");
#endif
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
    }
}

- (void)didEndTask:(NSNotification *)aNotification
{
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
		theData = [outHandle availableData];
		if ([theData length]) {
			[outputData appendData:theData];
		}
	}

	NSPipe *errorPipe = [scriptTask standardError];
	NSFileHandle *errorHandle = [errorPipe fileHandleForReading];
	theData = [errorHandle availableData];
	if ([theData length]) {
		[errorData appendData:theData];
	}
	
	NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
	[notiCenter postNotificationName:@"ScriptRunnerDidEndNotification" object:self];
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
	 
#if useLog
	NSLog(@"task will launch");
#endif
	[scriptTask launch];
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
	NSMutableString *string = [[[NSMutableString alloc] initWithData:errorData encoding:NSUTF8StringEncoding] autorelease];
	return string;
}

- (NSString *)outputString
{
	NSMutableString *string = [[[NSMutableString alloc] initWithData:outputData encoding:NSUTF8StringEncoding] autorelease];
	[string replaceOccurrencesOfString:@"\n" withString:@"\r" options:nil range: NSMakeRange(0, [string length])];
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
