#import "CachedObject.h"

@implementation CachedObject

@synthesize object = _object;
@synthesize expirationDate = _expirationDate;

+(CachedObject*)object:(NSObject*)object expirationDate:(NSDate*)expirationDate {
    return [[self alloc] initWithObject:object expirationDate:expirationDate];
}

-(id)initWithObject:(NSObject*)object expirationDate:(NSDate*)expirationDate {
    self = [super init];
    if (self) {
        self.object = object;
        self.expirationDate = expirationDate;
    }
    return self;
}

-(void)dealloc {
    [_object release];          _object = nil;
    [_expirationDate release];  _expirationDate = nil;
    [super dealloc];
}

#pragma mark - Properties
-(BOOL)isExpired {
    return [_expirationDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970] >= 0;
}

@end
