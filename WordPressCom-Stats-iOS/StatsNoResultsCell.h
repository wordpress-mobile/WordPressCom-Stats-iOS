#import <UIKit/UIKit.h>
#import "StatsViewController.h"

@interface StatsNoResultsCell : UITableViewCell

+ (CGFloat)heightForRowForSection:(StatsSection)section withWidth:(CGFloat)width;

- (void)configureForSection:(StatsSection)section;

@end