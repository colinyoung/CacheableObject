#import <Foundation/Foundation.h>

typedef enum {
    ObjectCacheStoreTypeMemory = 0,
    ObjectCacheStoreTypeDisk,
    // ObjectCacheStoreTypeSQLite // Not yet.
} ObjectCacheStoreType;

@interface ObjectCache : NSObject {
    ObjectCacheStoreType _storeType;
    
    NSMutableDictionary *_memoryStore;
}

// Initialization
+(ObjectCache*)cacheWithStoreType:(ObjectCacheStoreType)storeType;
-(id)initWithStoreType:(ObjectCacheStoreType)storeType;

// Usage
+(ObjectCache*)sharedCache;

// Get objects
-(id)cachedObjectWithID:(NSString *)objectID;

// Delete objects
-(int)removeAll;
-(int)removeExpired;
-(int)removeOldest:(int)numObjectsToRemove;

// Properties
-(ObjectCacheStoreType)storeType;

@end
