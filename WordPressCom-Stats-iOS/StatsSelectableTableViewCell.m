#import "StatsSelectableTableViewCell.h"
#import <UIImage+Util.h>
#import <WPStyleGuide.h>
#import "WPStyleGuide+Stats.h"

@interface StatsBorderedCellBackgroundView : UIView

- (instancetype)initWithFrame:(CGRect)frame andSelected:(BOOL)selected;

@property (nonatomic, strong) UIView *theBoxView;
@property (nonatomic, strong) UIView *contentBackgroundView;
@property (nonatomic, strong) UIView *dividerView;

@end

@implementation StatsBorderedCellBackgroundView

- (instancetype)initWithFrame:(CGRect)frame andSelected:(BOOL)selected
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [WPStyleGuide itsEverywhereGrey];
        
        _theBoxView = [[UIView alloc] initWithFrame:CGRectZero];
        _theBoxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _theBoxView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:222.0/255.0 blue:238.0/255.0 alpha:1.0];
        [self addSubview:_theBoxView];
        
        _contentBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _contentBackgroundView.backgroundColor = selected ? [UIColor whiteColor] : [WPStyleGuide statsUltraLightGray];
        [self addSubview:_contentBackgroundView];
        
        _dividerView = [[UIView alloc] initWithFrame:CGRectZero];
        _dividerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _dividerView.backgroundColor = [WPStyleGuide statsLightGray];
        [self addSubview:_dividerView];
    }
    
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.theBoxView.frame = CGRectMake(7.0, 0.0, CGRectGetWidth(self.frame) - 14.0, CGRectGetHeight(self.frame));
    self.contentBackgroundView.frame = CGRectMake(8.0, 0.0, CGRectGetWidth(self.frame) - 16.0, CGRectGetHeight(self.frame));
    self.dividerView.frame = CGRectMake(CGRectGetMinX(self.contentBackgroundView.frame), CGRectGetHeight(self.frame) - 1.0f, CGRectGetWidth(self.contentBackgroundView.frame), 1.0f);
}

@end

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
