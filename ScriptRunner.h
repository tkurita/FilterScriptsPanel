#import <Cocoa/Cocoa.h>
#import "stringExtra.h"

@interface ScriptRunner : NSObject {
	NSTask *scriptTask;
	NSMutableData *outputData;
	NSMutableData *errorData;
}

- (id)initWithScriptFile:(NSString *)path withCommand:(NSString *)command;
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
