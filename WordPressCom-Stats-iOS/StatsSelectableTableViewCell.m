#import "StatsSelectableTableViewCell.h"
#import <WordPress-iOS-Shared/UIImage+Util.h>
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
        self.categoryIconLabel.textColor = [WPStyleGuide statsDarkGray];
        self.categoryLabel.textColor = [WPStyleGuide statsDarkGray];
        self.valueLabel.textColor = [WPStyleGuide jazzyOrange];
    } else {
        self.categoryIconLabel.textColor = [WPStyleGuide statsLessDarkGrey];
        self.categoryLabel.textColor = [WPStyleGuide statsLessDarkGrey];
        
        if ([self.valueLabel.text isEqualToString:@"0"]) {
            self.valueLabel.textColor = [WPStyleGuide statsLightGrayZeroValue];
        } else {
            self.valueLabel.textColor = [WPStyleGuide littleEddieGrey];
        }
    }
}

@end
