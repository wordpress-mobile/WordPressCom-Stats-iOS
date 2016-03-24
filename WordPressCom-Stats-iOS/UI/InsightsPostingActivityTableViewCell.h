#import <UIKit/UIKit.h>
#import "StatsStandardBorderedTableViewCell.h"
#import "WPStatsContributionGraph.h"
#import "StatsStreak.h"

@interface InsightsPostingActivityTableViewCell : StatsStandardBorderedTableViewCell <WPStatsContributionGraphDataSource>

@property (nonatomic, strong) StatsStreak *statsStreak;

@property (nonatomic, weak) IBOutlet WPStatsContributionGraph *contributionGraphLeft;
@property (nonatomic, weak) IBOutlet WPStatsContributionGraph *contributionGraphCenter;
@property (nonatomic, weak) IBOutlet WPStatsContributionGraph *contributionGraphRight;

@end
