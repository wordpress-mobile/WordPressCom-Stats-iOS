#import "StatsItem.h"

@implementation StatsItem

- (instancetype)init
{
    self = [super init];
    if (self) {
        _children = [NSMutableArray new];
    }
    return self;
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"StatsItem - itemID: %@, label: %@, value: %@", self.itemID, self.label, self.value];
}


- (void)addChildStatsItem:(StatsItem *)statsItem
{
    statsItem.parent = self;
    [self.children addObject:statsItem];
}

@end
