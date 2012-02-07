#import "NSObject+CacheableObject.h"

#define kDefaultCacheInterval (60 * 60 * 24) // 24 hours

// Fix some type warnings
@interface __CacheWarningsFix : ObjectCache
-(BOOL)cacheObject:(NSObject *)obj withID:(NSString *)ID untilExpirationDate:(NSDate*)expirationDate;
@end

@implementation NSObject (CacheableObject)

-(BOOL)cache {
    return [self cacheFor:kDefaultCacheInterval];
}

-(BOOL)cacheFor:(NSTimeInterval)timeInterval {
    return [self cacheUntil:[NSDate dateWithTimeIntervalSinceNow:timeInterval]];
}

-(BOOL)cacheUntil:(NSDate*)expirationDate {
    __CacheWarningsFix *cache = (__CacheWarningsFix*)[ObjectCache sharedCache];
    if (![self respondsToSelector:@selector(id)]) {
        NSString *exceptionStr = @"You must implement an -(NSString*)id on an object to cache it.";
        NSLog(@"%@", exceptionStr);
        [NSException raise:exceptionStr format:@"%@", exceptionStr];
    }
    
    // Ensure id is valid
    NSString *ID = [(id <CacheableObject>)self id];
    if (ID.length == 0 || [ID rangeOfString:@"(null)"].location != NSNotFound)
        return NO;
    
    return (BOOL)[cache cacheObject:self withID:[(id <CacheableObject>)self id] untilExpirationDate:expirationDate];
}

@end
