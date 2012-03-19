#import "NSObject+CacheableObject.h"
#import "ObjectCache.h"
#import "CacheableObject-p.h"

#define kDefaultCacheInterval (60 * 60 * 24) // 24 hours
#define kFarFutureCacheInterval (kDefaultCacheInterval * 365 * 10) // 10 years

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

-(BOOL)cacheForever {
    return [self cacheFor:kFarFutureCacheInterval];
}

-(BOOL)cacheUntil:(NSDate*)expirationDate {
    __CacheWarningsFix *cache = (__CacheWarningsFix*)[ObjectCache sharedCache];
    if (![self respondsToSelector:@selector(id)]) {
        NSString *exceptionStr = @"You must implement an -(NSString*)id on an object to cache it.";
        NSLog(@"%@", exceptionStr);
        [NSException raise:exceptionStr format:@"%@", exceptionStr];
    }
    
    NSString *ID = [(id <CacheableObject>)self id];
    return (BOOL)[cache cacheObject:self withID:ID untilExpirationDate:expirationDate];
}

@end
