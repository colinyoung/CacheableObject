#import "NSThread+BlocksAdditions.h"

@implementation NSThread (BlocksAdditions)
+ (void)performBlockInBackground:(void (^)())block
{
	[NSThread performSelectorInBackground:@selector(ng_runBlock:)
	                           withObject:[[block copy] autorelease]];
}

+ (void)ng_runBlock:(void (^)())block
{
	block();
}

@end
