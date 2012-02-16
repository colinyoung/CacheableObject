#import <Foundation/Foundation.h>
#import "kvdb.h"

typedef enum {
    ObjectCacheStoreTypeMemory = 0,
    ObjectCacheStoreTypeDisk,
    ObjectCacheStoreTypeSQLite // Not yet.
} ObjectCacheStoreType;

@interface ObjectCache : NSObject {
    ObjectCacheStoreType _storeType;
    
    NSMutableDictionary *_memoryStore;
    KVDB *_dbStore;
}

// Initialization
+(ObjectCache*)cacheWithStoreType:(ObjectCacheStoreType)storeType;
-(id)initWithStoreType:(ObjectCacheStoreType)storeType;

// Usage
+(ObjectCache*)sharedCache;

// Get objects
-(id)cachedObjectWithID:(NSString *)objectID;
-(NSArray*)objectsMatchingSearch:(NSString*)search;
-(id)firstResultForSearch:(NSString*)search;

// Delete objects
-(int)removeAll;
-(int)removeExpired;
-(int)removeOldest:(int)numObjectsToRemove;

// Properties
-(ObjectCacheStoreType)storeType;

@end
