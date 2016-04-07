#import "InsightsContributionGraphHeaderView.h"
#import "WPStyleGuide+Stats.h"

@implementation InsightsContributionGraphHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [WPStyleGuide statsUltraLightGray];
    [self.dateLabel setText:NSLocalizedString(@"Touch a square to see the date", @"Contribution graph default header label prompting user to tap on a date.")];
}

@end
