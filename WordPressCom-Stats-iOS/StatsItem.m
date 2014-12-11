#import "StatsItem.h"

@implementation StatsItem

- (NSString *)description
{
    return [NSString stringWithFormat:@"StatsItem - itemID: %@, label: %@, value: %@", self.itemID, self.label, self.value];
}

@end
