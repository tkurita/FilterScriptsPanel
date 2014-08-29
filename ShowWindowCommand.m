#import "ShowWindowCommand.h"


@implementation ShowWindowCommand
- (id)performDefaultImplementation
{
	[[NSApp delegate] showWindow:self];
	return nil;
}
@end
