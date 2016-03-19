#import "InsightsPostingActivityTableViewCell.h"

@implementation InsightsPostingActivityTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.contributionGraph setDelegate:self];
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

//- (UIColor *)colorForGrade:(NSUInteger)grade
//{
//    
//}

//- (NSInteger)minimumValueForGrade:(NSUInteger)grade
//{
//    return 0;
//}

@end
