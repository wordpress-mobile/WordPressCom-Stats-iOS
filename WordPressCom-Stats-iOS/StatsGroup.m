#import "StatsGroup.h"

@implementation StatsGroup

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
    return [self statsItemForIndex:index withItems:self.items andCurrentIndex:&currentIndex];
}


- (StatsItem *)statsItemForIndex:(NSInteger)index withItems:(NSArray *)items andCurrentIndex:(NSInteger *)currentIndex
{
    for (StatsItem *item in items) {
        if ((*currentIndex) == index) {
            return item;
        }
        
        if (item.isExpanded == YES) {
            (*currentIndex)++;
            StatsItem *subItem = [self statsItemForIndex:index withItems:item.children andCurrentIndex:currentIndex];
            if (subItem) {
                return subItem;
            } else {
                (*currentIndex)--;
            }
        }
        
        (*currentIndex)++;
    }
    
    return nil;
}

@end

