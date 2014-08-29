#import <Cocoa/Cocoa.h>
#import "CocoaLib/StringExtra.h"

@interface ScriptRunner : NSObject {
	NSTask *scriptTask;
	NSMutableData *outputData;
	NSMutableData *errorData;
	
	BOOL isTaskEnded;
	BOOL isGetDataEnded;
	BOOL isGetErrorDataEnded;
}
+ (id)scriptRunnerWithFile:(NSString *)path error:(NSError **)error;
- (id)initWithScriptFile:(NSString *)path withCommand:(NSString *)command;
- (id)initWithLoginShellAndScriptFile:(NSString *)path withCommand:(NSString *)command;
- (void)launchTaskWithString:(NSString *)inputString;
- (int)terminationStatus;
- (NSString *)standardOutput;
- (NSString *)standardError;
- (NSTask *)taskWithEnviroments;
- (NSString *)findCommandPath:(NSString *)commandPath;
- (void)didEndTask:(NSNotification *)aNotification;
- (void)sendData:(NSString *)inputString;
- (NSString *)outputString;
- (BOOL)hasErrorData;
- (NSString *)errorString;

//accessor methods
- (void)setScriptTask:(NSTask *)aTask;

@end
