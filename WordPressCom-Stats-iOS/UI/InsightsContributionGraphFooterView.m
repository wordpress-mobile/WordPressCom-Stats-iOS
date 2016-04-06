#import "InsightsContributionGraphFooterView.h"

@implementation InsightsContributionGraphFooterView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //TODO: consolodate this
    [self.firstScaleSquare setBackgroundColor:[UIColor colorWithRed:0.784 green:0.843 blue:0.882 alpha:1]];     // Default grey #c8d7e1
    [self.secondScaleSquare setBackgroundColor:[UIColor colorWithRed:0.569 green:0.886 blue:0.984 alpha:1]];    // #91e2fb
    [self.thirdScaleSquare setBackgroundColor:[UIColor colorWithRed:0 green:0.745 blue:0.965 alpha:1]];         // #00bef6
    [self.fourthScaleSquare setBackgroundColor:[UIColor colorWithRed:0 green:0.514 blue:0.663 alpha:1]];        // #0083a9
    [self.fifthScaleSquare setBackgroundColor:[UIColor colorWithRed:0 green:0.204 blue:0.263 alpha:1]];         // #003443
    
    [self.leftLabel setText:NSLocalizedString(@"LESS POSTS", @"Contribution graph footer label for left side of scale - less posts")];
    [self.rightLabel setText:NSLocalizedString(@"MORE POSTS", @"Contribution graph footer label for right side of scale - more posts")];
}

@end
