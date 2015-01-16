#import "StatsSelectableTableViewCell.h"
#import <UIImage+Util.h>
#import <WPStyleGuide.h>

@implementation StatsSelectableTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UIView *selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = selectedBackgroundView;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    backgroundView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.backgroundView = backgroundView;
    
    // Remove seperator inset
    if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
        [self setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([self respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [self setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([self respondsToSelector:@selector(setLayoutMargins:)]) {
        [self setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.valueLabel.textColor = [WPStyleGuide jazzyOrange];
    } else {
        self.valueLabel.textColor = [UIColor blackColor];
    }
}

@end
