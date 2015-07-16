#import <UIKit/UIKit.h>

@interface InsightsMostPopularTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *popularSectionHeaderLabel;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularDayLabel;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularDayPercentWeeklyViews;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularHourLabel;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularHourPercentDailyViews;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularDay;
@property (nonatomic, weak) IBOutlet UILabel *mostPopularHour;

@end
