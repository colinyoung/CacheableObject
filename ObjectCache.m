#import "ObjectCache.h"
#import "CachedObject.h"

static ObjectCache *sharedCache = nil;

#define kDefaultObjectCacheStoreType ObjectCacheStoreTypeDisk

#pragma mark - Private methods
@interface ObjectCache (Private)

-(BOOL)cacheObject:(NSObject *)obj withID:(NSString *)ID untilExpirationDate:(NSDate*)expirationDate;
-(NSMutableDictionary *)store;

@end

@implementation ObjectCache

#pragma mark - Initialization
+(ObjectCache*)cacheWithStoreType:(ObjectCacheStoreType)storeType {
       
    sharedCache = [[super allocWithZone:NULL] initWithStoreType:storeType];
    
    return sharedCache;
}

-(id)initWithStoreType:(ObjectCacheStoreType)storeType {
    self = [super init];
    if (self) {
        _storeType = storeType;
    }
    return self;
}

#pragma mark - Usage
+(ObjectCache*)sharedCache {
    if (sharedCache != nil) {
        return sharedCache;
    }
    
    static dispatch_once_t pred; // Lock
    dispatch_once(&pred, ^{ // This code is called at most once per app
        sharedCache = [self cacheWithStoreType:kDefaultObjectCacheStoreType];
    });
    return sharedCache;
}

#pragma mark - Get objects
-(id)cachedObjectWithID:(NSString *)objectID {
    CachedObject *obj = [[self store] objectForKey:objectID];

    // Return valid object
    if (![obj isExpired]) return [obj object];
    
    // Remove expired object
    [[self store] removeObjectForKey:objectID];
    return nil;
}

-(NSDictionary *)allObjects {
    return [NSDictionary dictionaryWithDictionary:[self store]];
}

#pragma mark - Delete objects
-(int)removeAll {
    if (_storeType == ObjectCacheStoreTypeMemory) {
        int ct = [_memoryStore count];
        [_memoryStore release]; _memoryStore = nil;
        return ct;
    }
#warning Not implemented for other cache types
    return -1;
}
-(int)removeExpired {
#warning Not implemented for other cache types
    int ct = 0;
    NSDictionary *allObjects = [self allObjects];
    
    for (NSString *key in allObjects) {
        id obj = [allObjects objectForKey:key];
        if ([obj isExpired]) {
            [[self store] removeObjectForKey:key];
            ct++;
        }
    }
    
    return ct;
}

#pragma mark - Properties
-(ObjectCacheStoreType)storeType {
    return _storeType; 
}

#pragma mark - Wonderful code I didn't write
/* Was written by John Wordsworth at http://www.johnwordsworth.com/2010/04/iphone-code-snippet-the-singleton-pattern/ */

// Your dealloc method will never be called, as the singleton survives for the duration of your app.
// However, I like to include it so I know what memory I'm using (and incase, one day, I convert away from Singleton).
-(void)dealloc
{
    // I'm never called!
    [super dealloc];
}

// We don't want to allocate a new instance, so return the current one.
+ (id)allocWithZone:(NSZone*)zone {
    return [[self sharedCache] retain];
}

// Equally, we don't want to generate multiple copies of the singleton.
- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// Once again - do nothing, as we don't have a retain counter for this object.
- (id)retain {
    return self;
}

// Replace the retain counter so we can never release this object.
- (NSUInteger)retainCount {
    return NSUIntegerMax;
}

// This function is empty, as we don't want to let the user release this object.
- (oneway void)release {
    
}

//Do nothing, other than return the shared instance - as this is expected from autorelease.
- (id)autorelease {
    return self;
}


@end

@implementation ObjectCache (Private)

#pragma mark - Set objects
-(BOOL)cacheObject:(NSObject *)obj withID:(NSString *)ID untilExpirationDate:(NSDate*)expirationDate {
    
    // Memcache
    if (_storeType == ObjectCacheStoreTypeMemory) {
        
        if (_memoryStore == nil) _memoryStore = [[NSMutableDictionary alloc] init];
        
        [_memoryStore setObject:[CachedObject object:obj expirationDate:expirationDate] forKey:ID];
        
    } else
    
    // Disk cache
    if (_storeType == ObjectCacheStoreTypeDisk) {
        
        [NSException raise:@"cacheObject:withID: not implemented for disk yet." format:nil];
        
    } else {
        [NSException raise:@"Invalid Object Cache type." format:nil];
    }
    return YES;
}
                              
-(NSMutableDictionary *)store {
    if (_storeType == ObjectCacheStoreTypeMemory) { return _memoryStore; }
#warning Not implemented for other cache types    
    return nil;
}

@end