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

