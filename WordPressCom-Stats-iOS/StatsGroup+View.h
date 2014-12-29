#import "StatsGroup.h"
#import "StatsItem.h"

@interface StatsGroup (View)

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, readonly) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger offsetRows;

- (StatsItem *)statsItemForTableViewRow:(NSInteger)row;

@end
