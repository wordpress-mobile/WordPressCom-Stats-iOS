#import "StatsGroup.h"

@interface StatsGroup (View)

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, readonly) NSUInteger numberOfRows;

@end
