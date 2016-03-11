#import <Cocoa/Cocoa.h>
#import "StringExtra.h"

@interface ScriptRunner : NSObject {
	BOOL isTaskEnded;
	BOOL isGetDataEnded;
	BOOL isGetErrorDataEnded;
}

@property (nonatomic) NSTask *scriptTask;
@property (nonatomic) NSMutableData *outputData;
@property (nonatomic) NSMutableData *errorData;

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

@end
