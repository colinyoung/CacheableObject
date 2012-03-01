#import "ObjectCache.h"
#import "CachedObject.h"
#import "CacheableObject-p.h"

static ObjectCache *sharedCache = nil;
static NSOperationQueue *sharedOperationQueue = nil;

#define kDefaultObjectCacheStoreType ObjectCacheStoreTypeMemory
#define kMemoryMaxObjects 10

#pragma mark - Private methods
@interface ObjectCache (Private)

-(BOOL)cacheObject:(NSObject *)obj withID:(NSString *)ID untilExpirationDate:(NSDate*)expirationDate;
-(id)store;
-(void)setupStore;

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
        [self setupStore];
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

+(NSOperationQueue*)sharedOperationQueue {
    if (sharedOperationQueue != nil) {
        return sharedOperationQueue;
    }
    
    static dispatch_once_t pred; // Lock
    dispatch_once(&pred, ^{ // This code is called at most once per app
        sharedOperationQueue = [[NSOperationQueue alloc] init];
    });
    return sharedOperationQueue;
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

-(NSArray*)objectsMatchingSearch:(NSString*)search {

    if (_storeType == ObjectCacheStoreTypeMemory) {
        
        NSMutableArray *results = [NSMutableArray array];
        for (CachedObject *object in [[self store] allObjects]) {
            if ([[object index] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound) {
                [results addObject:object];
            }
        }
        
        return results;
    }
    
    if (_storeType == ObjectCacheStoreTypeSQLite) {
        
        return [_dbStore objectsMatchingIndex:search];
    }
    
    return nil;
}

-(id)firstResultForSearch:(NSString*)search {
    
    if (_storeType == ObjectCacheStoreTypeMemory) {
        for (CachedObject *object in [[self store] allObjects]) {
            if ([[object index] rangeOfString:search options:NSCaseInsensitiveSearch].location != NSNotFound) {
                return object;
            }
        }
    }
    
    if (_storeType == ObjectCacheStoreTypeSQLite) {
        return [_dbStore firstObjectMatchingIndex:search];
    }
    
    return nil;
}

-(NSDictionary *)allObjects {
    if (_storeType == ObjectCacheStoreTypeSQLite) return [_dbStore allObjects];
    return [NSDictionary dictionaryWithDictionary:[self store]];
}

#pragma mark - Delete objects
-(int)removeAll {
    if (_storeType == ObjectCacheStoreTypeMemory) {
        int ct = [_memoryStore count];
        [_memoryStore release]; _memoryStore = nil;
        return ct;
    }
    
    if (_storeType == ObjectCacheStoreTypeSQLite) {
        
        [[[self class] sharedOperationQueue] cancelAllOperations];
        [[[self class] sharedOperationQueue] addOperationWithBlock:^{
            [_dbStore dropDatabase];
            [_dbStore createDatabase];
        }];
        return 0;
    }
    
    [self setupStore];
    
    return -1;
}
-(int)removeExpired {
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

-(int)removeOldest:(int)numObjectsToRemove {
#warning Not implemented
    int ct = [self removeExpired];
    
//  @todo
//    NSMutableArray *values = [[[[self store] allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//        return [[(CachedObject*)obj2 expirationDate] compare:[(CachedObject*) obj1 expirationDate]];
//    }] mutableCopy];
//    
//    int toRemove = MIN(numObjectsToRemove, [values count]-1);
//    ct += toRemove;
//    for (int i = 0; i < toRemove; i++)
//        [values removeObject:[values objectAtIndex:i]];
//
    
    [self removeAll];
    
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
-(BOOL)cacheObject:(id<CacheableObject>)obj withID:(NSString *)ID untilExpirationDate:(NSDate*)expirationDate {
    
    // Ensure id is valid
    if (ID.length == 0 || [ID rangeOfString:@"(null)"].location != NSNotFound)
        return NO;
    
    /* Ensure the object doesn't have an expiration in the past. */
    if ([expirationDate timeIntervalSince1970] < [[NSDate date] timeIntervalSince1970]) { 
        return NO; 
    }
    
    CachedObject *objectToCache = [CachedObject object:obj expirationDate:expirationDate];
    
    // Memcache
    if (_storeType == ObjectCacheStoreTypeMemory) {
        
        if (_memoryStore == nil) _memoryStore = [[NSMutableDictionary alloc] init];
        
        [self removeExpired];
        if ([[_memoryStore allKeys] count] > kMemoryMaxObjects) {
            [self removeOldest:kMemoryMaxObjects/3]; // @todo remove oldest first
        }
        
        [_memoryStore setObject:objectToCache forKey:ID];
        
    } else
    
    // Disk cache
    if (_storeType == ObjectCacheStoreTypeDisk) {
        
        [NSException raise:@"cacheObject:withID: not implemented for disk yet." format:nil];
        
    } else
      
    // Sqlite cache
    if (_storeType == ObjectCacheStoreTypeSQLite) {
        
        [[[self class] sharedOperationQueue] addOperationWithBlock:^{
            [[self store] setValue:objectToCache forKey:ID];
        }];
        
    } else {
        [NSException raise:@"Invalid Object Cache type." format:nil];
    }
    return YES;
}
                              
-(id)store {
    if (_storeType == ObjectCacheStoreTypeMemory) { return _memoryStore; }
    if (_storeType == ObjectCacheStoreTypeSQLite) { return _dbStore; }    
    return nil;
}

-(void)setupStore {  
    if (_storeType == ObjectCacheStoreTypeMemory) {
        [_memoryStore release];
        _memoryStore = nil; 
        _memoryStore = [[NSMutableDictionary alloc] init]; 
    }
    
    if (_storeType == ObjectCacheStoreTypeSQLite) {
        _dbStore = [KVDB sharedDBUsingFile:@"ObjectCache.sqlite3"];
    }
}

@end