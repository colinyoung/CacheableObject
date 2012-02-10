/*
NSThread additions via http://www.informit.com/blogs/blog.aspx?uk=Ask-Big-Nerd-Ranch-Blocks-in-Objective-C
*/
#import <Foundation/Foundation.h>

@interface NSThread (BlocksAdditions)

+ (void)performBlockInBackground:(void (^)())block;
+ (void)ng_runBlock:(void (^)())block;

@end
