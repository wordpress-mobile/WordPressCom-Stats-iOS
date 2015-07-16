#import <UIKit/UIKit.h>

@interface InsightsTodaysStatsTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *todayViewsButton;
@property (nonatomic, weak) IBOutlet UIButton *todayVisitorsButton;
@property (nonatomic, weak) IBOutlet UIButton *todayLikesButton;
@property (nonatomic, weak) IBOutlet UIButton *todayCommentsButton;

@property (nonatomic, weak) IBOutlet UIButton *todayViewsValueButton;
@property (nonatomic, weak) IBOutlet UIButton *todayVisitorsValueButton;
@property (nonatomic, weak) IBOutlet UIButton *todayLikesValueButton;
@property (nonatomic, weak) IBOutlet UIButton *todayCommentsValueButton;

@end
