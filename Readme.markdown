**cacheableobject**

1. setup:
   
    ```objective-c   
    #import "CacheableObject.h"
    
    /* In your ApplicationDelegate: */
    \- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
      // ...
      [ObjectCache cacheWithStoreType:ObjectCacheStoreTypeMemory];
      //...
    }
    ```

1. usage:

    ```objective-c
    @interface Fruit : NSObject

    @end

    @implementation Fruit

    -(NSString *)id {
      /* This is the 200th apple, but obviously this is intended to be dynamic */
      return @"apple-200"; 
    }

    @end


    [myObject cache];
    [ObjectCache cachedObjectWithID:@"apple-200"];
    ```

Yay!

You can also cache objects until a certain time:

```objective-c
[myObject cacheUntil:(NSDate*)theCowsComeHome];
```

or for a certain number of seconds:

```objective-c
[myObject cacheUntil:3600];
```

don't forget to clean up when your users say bye-bye.
    
```objective-c    
/* In your ApplicationDelegate: */
- (void)applicationDidEnterBackground:(UIApplication *)application {
  int count = [ObjectCache removeExpired];
  NSLog(@"Purged %d naughty, expired objects.", count);
}
```


**backing stores**

- memory
- disk
- sqlite3 (coming later)
