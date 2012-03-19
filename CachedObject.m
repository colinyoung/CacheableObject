#import "CachedObject.h"
#import "CacheableObject-p.h"

@implementation CachedObject

@synthesize object = _object;
@synthesize expirationDate = _expirationDate;

+(CachedObject*)object:(NSObject*)object expirationDate:(NSDate*)expirationDate {
    return [[[self alloc] initWithObject:object expirationDate:expirationDate] autorelease];
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

-(NSString *)index {
    return [(id<CacheableObject>)_object index];
}

#pragma mark - Properties
-(BOOL)isExpired {
    return [_expirationDate timeIntervalSince1970] - [[NSDate date] timeIntervalSince1970] < 0;
}

#pragma mark - NSCoding protocol
-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.object = [aDecoder decodeObjectForKey:@"object"];
        self.expirationDate = [aDecoder decodeObjectForKey:@"expirationDate"];        
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.object forKey:@"object"];
    [aCoder encodeObject:self.expirationDate forKey:@"expirationDate"];    
}

@end
