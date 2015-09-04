#import <UIKit/UIKit.h>

@interface StatsSelectableTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *categoryIconLabel;
@property (nonatomic, weak) IBOutlet UILabel *categoryLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@property (nonatomic, assign) BOOL selectedIsLighter;

@property (nonatomic, strong) UIColor *selectedCellTextColor;
@property (nonatomic, strong) UIColor *selectedCellValueZeroColor;
@property (nonatomic, strong) UIColor *selectedCellValueColor;
@property (nonatomic, strong) UIColor *unselectedCellTextColor;
@property (nonatomic, strong) UIColor *unselectedCellValueZeroColor;
@property (nonatomic, strong) UIColor *unselectedCellValueColor;

@end
