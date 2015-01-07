#import <Foundation/Foundation.h>

@interface StatsEphemory : NSObject

@property (nonatomic, assign, readonly) NSTimeInterval expiryInterval;

- (instancetype)initWithExpiryInterval:(NSTimeInterval)expiryInterval;

- (id)objectForKey:(id)key;
- (void)setObject:(id)obj forKey:(id)key;
- (void)removeObjectForKey:(id)key;

- (void)removeAllObjects;

@end
