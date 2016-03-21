#import "InsightsPostingActivityTableViewCell.h"

@implementation InsightsPostingActivityTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.contributionGraphLeft setDelegate:self];
    [self.contributionGraphCenter setDelegate:self];
    [self.contributionGraphRight setDelegate:self];
    
    self.contributionGraphLeft.cellSpacing = 3.0;
    self.contributionGraphLeft.cellSize = 12.0;
    
    self.contributionGraphCenter.cellSpacing = 3.0;
    self.contributionGraphCenter.cellSize = 12.0;
    
    self.contributionGraphRight.cellSpacing = 3.0;
    self.contributionGraphRight.cellSize = 12.0;
}


#pragma mark - WPStatsContributionGraphDataSource methods

- (NSDate *)monthForGraph
{
    return [NSDate date];
}

- (NSInteger)valueForDay:(NSUInteger)day
{
    return day % 6;
}

- (NSUInteger)numberOfGrades
{
    return 5;
}

- (UIColor *)colorForGrade:(NSUInteger)grade
{
    switch (grade) {
        case 1:
            return [UIColor colorWithRed:0.784 green:0.843 blue:0.882 alpha:1]; // #c8d7e1
            break;
        case 2:
            return [UIColor colorWithRed:0.569 green:0.886 blue:0.984 alpha:1]; // #91e2fb
            break;
        case 3:
            return [UIColor colorWithRed:0 green:0.745 blue:0.965 alpha:1]; // #00bef6
            break;
        case 4:
            return [UIColor colorWithRed:0 green:0.514 blue:0.663 alpha:1]; // #0083a9
            break;
        case 5:
            return [UIColor colorWithRed:0 green:0.204 blue:0.263 alpha:1]; // #003443
            break;
        default:
            return [UIColor colorWithRed:0.784 green:0.843 blue:0.882 alpha:1]; //Default grey #c8d7e1
            break;
    }
}

//- (NSInteger)minimumValueForGrade:(NSUInteger)grade
//{
//    return 0;
//}

@end
