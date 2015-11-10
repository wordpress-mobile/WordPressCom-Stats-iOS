#import "StatsSelectableTableViewCell.h"
#import <WordPressShared/UIImage+Util.h>
#import "WPStyleGuide+Stats.h"
#import "StatsBorderedCellBackgroundView.h"

@interface StatsSelectableTableViewCell ()

@property (nonatomic, strong) UIView *sideBorderView;
@property (nonatomic, strong) UIView *darkerBackgroundView;
@property (nonatomic, strong) UIView *lighterBackgroundView;

@end

@implementation StatsSelectableTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectedIsLighter = YES;
    
    // Standard colors for use in the graph view
    self.selectedCellTextColor = [WPStyleGuide darkGrey];
    self.selectedCellValueColor = [WPStyleGuide jazzyOrange];
    self.selectedCellValueZeroColor = [WPStyleGuide jazzyOrange];
    self.unselectedCellTextColor = [WPStyleGuide darkGrey];
    self.unselectedCellValueColor = [WPStyleGuide littleEddieGrey];
    self.unselectedCellValueZeroColor = [WPStyleGuide statsLightGrayZeroValue];
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
        self.categoryIconLabel.textColor = self.selectedCellTextColor;
        self.categoryLabel.textColor = self.selectedCellTextColor;
        self.valueLabel.textColor = self.selectedCellValueColor;
    } else {
        self.categoryIconLabel.textColor = self.unselectedCellTextColor;
        self.categoryLabel.textColor = self.unselectedCellTextColor;
        
        if ([self.valueLabel.text isEqualToString:@"0"]) {
            self.valueLabel.textColor = self.unselectedCellValueZeroColor;
        } else {
            self.valueLabel.textColor = self.unselectedCellValueColor;
        }
    }
}

- (void)setSelectedIsLighter:(BOOL)selectedIsLighter
{
    _selectedIsLighter = selectedIsLighter;
    
    if (selectedIsLighter) {
        self.backgroundView = [[StatsBorderedCellBackgroundView alloc] initWithFrame:self.bounds andSelected:NO];
        self.selectedBackgroundView = [[StatsBorderedCellBackgroundView alloc] initWithFrame:self.bounds andSelected:YES];
    } else {
        self.backgroundView = [[StatsBorderedCellBackgroundView alloc] initWithFrame:self.bounds andSelected:YES];
        self.selectedBackgroundView = [[StatsBorderedCellBackgroundView alloc] initWithFrame:self.bounds andSelected:NO];
    }
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.selectedIsLighter = NO;
}

@end
