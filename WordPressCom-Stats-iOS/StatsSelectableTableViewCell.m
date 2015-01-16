#import "StatsSelectableTableViewCell.h"
#import <UIImage+Util.h>
#import <WPStyleGuide.h>
#import "WPStyleGuide+Stats.h"

@interface StatsBorderedCellBackgroundView : UIView

- (instancetype)initWithFrame:(CGRect)frame andSelected:(BOOL)selected;

@end

@implementation StatsBorderedCellBackgroundView

- (instancetype)initWithFrame:(CGRect)frame andSelected:(BOOL)selected
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [WPStyleGuide itsEverywhereGrey];
        self.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        UIView *theBoxView = [[UIView alloc] initWithFrame:CGRectZero];
        theBoxView.translatesAutoresizingMaskIntoConstraints = NO;
        theBoxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        theBoxView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:222.0/255.0 blue:238.0/255.0 alpha:1.0];
        [self addSubview:theBoxView];
        
        UIView *contentBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        contentBackgroundView.translatesAutoresizingMaskIntoConstraints = NO;
        contentBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        contentBackgroundView.backgroundColor = selected ? [UIColor whiteColor] : [WPStyleGuide statsUltraLightGray];
        [self addSubview:contentBackgroundView];
        
        NSNumber *borderSidePadding = IS_IPHONE ? @(RPTVCHorizontalOuterPadding - 1.0f) : @0; // Just to the left of the container
        NSNumber *borderBottomPadding = @(0);
        NSNumber *bottomPadding = @(1.0f);
        NSNumber *sidePadding = IS_IPHONE ? @(RPTVCHorizontalOuterPadding) : @0.0f;

        NSDictionary *metrics =  @{@"borderSidePadding":borderSidePadding,
                                   @"borderBottomPadding":borderBottomPadding,
                                   @"sidePadding":sidePadding,
                                   @"bottomPadding":bottomPadding};
        
        NSDictionary *views = NSDictionaryOfVariableBindings(theBoxView, contentBackgroundView);
        // Border View
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(borderSidePadding)-[theBoxView]-(borderSidePadding)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(borderBottomPadding)-[theBoxView]-(borderBottomPadding)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        
        // Post View
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(sidePadding)-[contentBackgroundView]-(sidePadding)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[contentBackgroundView]-(bottomPadding)-|"
                                                                     options:0
                                                                     metrics:metrics
                                                                       views:views]];

    }
    
    return self;
}

@end

@interface StatsSelectableTableViewCell ()

@property (nonatomic, strong) UIView *sideBorderView;

@end

@implementation StatsSelectableTableViewCell

- (void)awakeFromNib {
    self.backgroundView = [[StatsBorderedCellBackgroundView alloc] initWithFrame:self.bounds andSelected:NO];
    self.selectedBackgroundView = [[StatsBorderedCellBackgroundView alloc] initWithFrame:self.bounds andSelected:YES];
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
