#import <UIKit/UIKit.h>

@interface InsightsAllTimeTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *heightConstraint;

@property (nonatomic, weak) IBOutlet UILabel *allTimePostsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeViewsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeVisitorsLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsLabel;

@property (nonatomic, weak) IBOutlet UILabel *allTimePostsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeViewsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeVisitorsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsValueLabel;
@property (nonatomic, weak) IBOutlet UILabel *allTimeBestViewsOnValueLabel;

@end
