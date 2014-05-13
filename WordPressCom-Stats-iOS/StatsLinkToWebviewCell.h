#import <UIKit/UIKit.h>
#import "StatsViewController.h"

@interface StatsLinkToWebviewCell : UITableViewCell

@property (nonatomic, copy) void (^onTappedLinkToWebview)(void);

+ (CGFloat)heightForRow;
- (void)configureForSection:(StatsSection)section;

@end
