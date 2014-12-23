#import "StatsItem.h"

@interface StatsItem (View)

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, readonly) NSUInteger numberOfRows;

@end
