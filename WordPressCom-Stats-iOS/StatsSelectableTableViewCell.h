#import <UIKit/UIKit.h>
#import <WordPress-iOS-Shared/WPTableViewCell.h>

@interface StatsSelectableTableViewCell : WPTableViewCell

@property (nonatomic, weak) IBOutlet UILabel *categoryIconLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@end
