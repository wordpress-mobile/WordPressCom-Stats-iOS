#import "StatsTableSectionHeaderView.h"
#import "WPStyleGuide+Stats.h"
#import <WordPress-iOS-Shared/WPTableViewCell.h>

@interface StatsTableSectionHeaderView ()

@property (nonatomic, strong) UIView *theBoxView;

@end

@implementation StatsTableSectionHeaderView


- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [WPStyleGuide statsLightGray];
        
        _theBoxView = [[UIView alloc] initWithFrame:CGRectZero];
        _theBoxView.backgroundColor = [UIColor colorWithRed:210.0/255.0 green:222.0/255.0 blue:238.0/255.0 alpha:1.0];
        [self.contentView addSubview:_theBoxView];
    }
    return self;
}


- (void)setFrame:(CGRect)frame {
    CGFloat width = self.superview.frame.size.width;
    // On iPad, add a margin around tables
    if (IS_IPAD && width > WPTableViewFixedWidth) {
        CGFloat x = (width - WPTableViewFixedWidth) / 2;
        // If origin.x is not equal to x we add the value.
        // This is a semi-fix / work around for an issue positioning cells on
        // iOS 8 when editing a table view and the delete button is visible.
        if (x != frame.origin.x) {
            frame.origin.x += x;
        } else {
            frame.origin.x = x;
        }
        frame.size.width = WPTableViewFixedWidth;
    }
    [super setFrame:frame];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Need to set the origin again on iPad (for margins)
    CGFloat width = self.superview.frame.size.width;
    if (IS_IPAD && width > WPTableViewFixedWidth) {
        CGRect frame = self.frame;
        frame.origin.x = (width - WPTableViewFixedWidth) / 2;
        self.frame = frame;
    }

    CGFloat borderSidePadding = StatsVCHorizontalOuterPadding - 1.0f; // Just to the left of the container
    self.theBoxView.frame = CGRectMake(borderSidePadding, self.isFooter ? -1.0f : 0.0f, CGRectGetWidth(self.frame) - 2.0 * borderSidePadding, 1.0f);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.footer = NO;
}


@end