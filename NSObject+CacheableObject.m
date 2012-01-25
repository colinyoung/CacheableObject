#import "NSObject+CacheableObject.h"
#import "ObjectCache.h"

#define kDefaultCacheInterval (60 * 60 * 24) // 24 hours

// Fix some type warnings
@interface __CacheWarningsFix : ObjectCache
-(BOOL)cacheObject:(NSObject *)obj withID:(NSString *)ID untilExpirationDate:(NSDate*)expirationDate;
@end

@interface __ObjectWarningsFix : NSObject
-(NSString *)id;
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
        @throw @"You must implement an -(NSString*)id on an object to cache it.";
    }
    return (BOOL)[cache cacheObject:self withID:[(__ObjectWarningsFix*)self id] untilExpirationDate:expirationDate];
}

@end
