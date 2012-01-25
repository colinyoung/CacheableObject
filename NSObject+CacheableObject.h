#import <Foundation/Foundation.h>

@interface NSObject (CacheableObject)

-(BOOL)cache;
-(BOOL)cacheUntil:(NSDate*)expirationDate;
-(BOOL)cacheFor:(NSTimeInterval)timeInterval;

@end
