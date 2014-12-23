#import "StatsGroup+View.h"
#import "StatsItem+View.h"
#import <objc/runtime.h>

@implementation StatsGroup (View)

@dynamic expanded;

- (void)setExpanded:(BOOL)expandedValue
{
    NSNumber *number = [NSNumber numberWithBool: expandedValue];
    objc_setAssociatedObject(self, @selector(isExpanded), number, OBJC_ASSOCIATION_RETAIN);
}

- (BOOL)isExpanded
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(isExpanded));
    return [number boolValue];
}

- (NSUInteger)numberOfRows
{
    NSUInteger itemCount = 0;

    for (StatsItem *item in self.items) {
        itemCount += [item numberOfRows];
    }
    
    return itemCount;
}

@end
