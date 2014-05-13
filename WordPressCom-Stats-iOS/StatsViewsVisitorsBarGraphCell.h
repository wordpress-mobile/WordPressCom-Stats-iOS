#import <UIKit/UIKit.h>
#import "StatsViewsVisitors.h"

@interface StatsViewsVisitorsBarGraphCell : UITableViewCell

+ (CGFloat)heightForRow;

- (void)setViewsVisitors:(StatsViewsVisitors *)viewsVisitors;
- (void)showGraphForUnit:(StatsViewsVisitorsUnit)unit;

@end
