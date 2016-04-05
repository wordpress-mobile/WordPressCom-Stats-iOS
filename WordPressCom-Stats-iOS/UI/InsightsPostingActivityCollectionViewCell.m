#import "InsightsPostingActivityCollectionViewCell.h"

@implementation InsightsPostingActivityCollectionViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.contributionGraph setDelegate:self];
}

#pragma mark - WPStatsContributionGraphDelegate methods

- (NSUInteger)numberOfGrades
{
    return 5;
}

- (UIColor *)colorForGrade:(NSUInteger)grade
{
    switch (grade) {
        case 0:
            return [UIColor colorWithRed:0.784 green:0.843 blue:0.882 alpha:1]; // #c8d7e1
            break;
        case 1:
            return [UIColor colorWithRed:0.569 green:0.886 blue:0.984 alpha:1]; // #91e2fb
            break;
        case 2:
            return [UIColor colorWithRed:0 green:0.745 blue:0.965 alpha:1]; // #00bef6
            break;
        case 3:
            return [UIColor colorWithRed:0 green:0.514 blue:0.663 alpha:1]; // #0083a9
            break;
        case 4:
            return [UIColor colorWithRed:0 green:0.204 blue:0.263 alpha:1]; // #003443
            break;
        default:
            return [UIColor colorWithRed:0.784 green:0.843 blue:0.882 alpha:1]; //Default grey #c8d7e1
            break;
    }
}

@end
