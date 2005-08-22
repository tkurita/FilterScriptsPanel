#import "ScriptRunner.h"

#define useLog 0

@implementation ScriptRunner
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
#if useLog
	NSLog(@"end initWithScriptFile");
#endif
	return self;
}

- (void)dealloc
{
	[scriptTask release];
	[super dealloc];
}

//internal methods
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

// public methods
- (void)launchTaskWithString:(NSString *)inputString;
{
#if useLog
	NSLog(@"start launchTaskWithString");
#endif
	NSPipe *inputPipe = [NSPipe pipe];
	NSFileHandle *inputHandle = [inputPipe fileHandleForWriting];
	[scriptTask setStandardInput:inputPipe];
	[scriptTask launch];
	NSData *inputData = [inputString dataUsingEncoding:NSUTF8StringEncoding];
	[inputHandle writeData:inputData];
	[inputHandle closeFile];
	//NSLog([self standardOutput]);
	
	if ([scriptTask isRunning]) {
		[scriptTask waitUntilExit];
	}
	
	if ([scriptTask terminationStatus] != 0 ) {
		NSNotificationCenter *notiCenter = [NSNotificationCenter defaultCenter];
		[notiCenter postNotificationName:@"ScriputRunnerDidEndWithError" object:self];
	}
#if useLog	
	NSLog(@"end launchTaskWithString");
#endif
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

//accessor methods
- (void)setScriptTask:(NSTask *)aTask
{
	[aTask retain];
	[scriptTask release];
	scriptTask = aTask;
}

@end
