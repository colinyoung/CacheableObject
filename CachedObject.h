/*
 Don't use this or require it in your project. It's only used by the cache.
*/

#import <Foundation/Foundation.h>

@interface CachedObject : NSObject <NSCoding> {
    id _object;
    NSDate *_expirationDate;
}

@property (nonatomic, retain) id object;
@property (nonatomic, retain) NSDate *expirationDate;

+(CachedObject*)object:(NSObject*)_object expirationDate:(NSDate*)_expirationDate;
-(id)initWithObject:(NSObject*)object expirationDate:(NSDate*)expirationDate;

// Properties
-(BOOL)isExpired;

@end
