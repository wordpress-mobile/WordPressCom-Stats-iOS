#import "StatsSelectableTableViewCell.h"
#import <UIImage+Util.h>
#import <WPStyleGuide.h>
#import "WPStyleGuide+Stats.h"
#import "StatsBorderedCellBackgroundView.h"

@interface StatsSelectableTableViewCell ()

@property (nonatomic, strong) UIView *sideBorderView;

@end

@implementation StatsSelectableTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.backgroundView = [[StatsBorderedCellBackgroundView alloc] initWithFrame:self.bounds andSelected:NO];
    self.selectedBackgroundView = [[StatsBorderedCellBackgroundView alloc] initWithFrame:self.bounds andSelected:YES];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
    self.selectedBackgroundView.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    if (selected) {
        self.valueLabel.textColor = [WPStyleGuide jazzyOrange];
    } else {
        self.valueLabel.textColor = [WPStyleGuide littleEddieGrey];
    }
}

@end
