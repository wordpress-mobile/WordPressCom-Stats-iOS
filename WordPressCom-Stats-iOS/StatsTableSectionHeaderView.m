#import "StatsTableSectionHeaderView.h"
#import "WPStyleGuide+Stats.h"

@implementation StatsTableSectionHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin |UIViewAutoresizingFlexibleTopMargin |UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
        
        UIView *theBoxView = [[UIView alloc] initWithFrame:CGRectZero];
        theBoxView.translatesAutoresizingMaskIntoConstraints = NO;
        theBoxView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        theBoxView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:222.0/255.0 blue:238.0/255.0 alpha:1.0];
        [self.contentView addSubview:theBoxView];
        
        NSNumber *borderSidePadding = IS_IPHONE ? @(RPTVCHorizontalOuterPadding - 1.0f) : @0; // Just to the left of the container
        NSNumber *borderBottomPadding = @(0);
        
        NSDictionary *metrics =  @{@"borderSidePadding":borderSidePadding,
                                   @"borderBottomPadding":borderBottomPadding};
        
        UIView *contentView = self.contentView;
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView, theBoxView);
        // Border View
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"|-(borderSidePadding)-[theBoxView]-(borderSidePadding)-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:views]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(borderBottomPadding)-[theBoxView]-(borderBottomPadding)-|"
                                                                                 options:0
                                                                                 metrics:metrics
                                                                                   views:views]];
    }
    return self;
}

@end
