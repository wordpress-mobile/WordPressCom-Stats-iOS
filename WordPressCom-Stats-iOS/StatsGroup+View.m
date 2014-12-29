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


- (void)setOffsetRows:(NSUInteger)offsetRows
{
    NSNumber *number = [NSNumber numberWithUnsignedInteger:offsetRows];
    objc_setAssociatedObject(self, @selector(offsetRows), number, OBJC_ASSOCIATION_RETAIN);
}


- (NSUInteger)offsetRows
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(offsetRows));
    return [number unsignedIntegerValue];
}


- (NSUInteger)numberOfRows
{
    NSUInteger itemCount = 0;

    for (StatsItem *item in self.items) {
        itemCount += [item numberOfRows];
    }
    
    return itemCount;
}

- (StatsItem *)statsItemForTableViewRow:(NSInteger)row
{
    NSInteger index = row - self.offsetRows;
    
    NSInteger currentIndex = 0;

    // TODO - This doesn't account for nesting beyond one level
    for (StatsItem *item in self.items) {
        if (currentIndex == index) {
            return item;
        }
        
        if (item.isExpanded == YES) {
            for (StatsItem *subItem in item.children) {
                currentIndex++;
                
                if (currentIndex == index) {
                    return subItem;
                }
            }
        }
        
        currentIndex++;
    }
    
    return nil;
}

@end
