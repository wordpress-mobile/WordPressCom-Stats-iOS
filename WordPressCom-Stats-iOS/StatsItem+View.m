#import "StatsItem+View.h"
#import <objc/runtime.h>

@implementation StatsItem (View)

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
    NSUInteger itemCount = self.children.count;

    if (itemCount == 0 || self.isExpanded == NO) {
        return 1;
    }
    
    for (StatsItem *item in self.children) {
        itemCount += [item numberOfRows];
    }
    
    return itemCount;
}

@end
