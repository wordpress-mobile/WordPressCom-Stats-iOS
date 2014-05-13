#import <UIKit/UIKit.h>
#import "StatsViewController.h"

@protocol StatsButtonCellDelegate;

@interface StatsButtonCell : UITableViewCell

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, weak) id<StatsButtonCellDelegate> delegate;

+ (CGFloat)heightForRow;

- (void)addSegmentWithTitle:(NSString *)title;
- (void)segmentChanged:(UISegmentedControl *)sender;

@end

@protocol StatsButtonCellDelegate  <NSObject>

- (void)statsButtonCell:(StatsButtonCell *)statsButtonCell didSelectIndex:(NSUInteger)index;

@end