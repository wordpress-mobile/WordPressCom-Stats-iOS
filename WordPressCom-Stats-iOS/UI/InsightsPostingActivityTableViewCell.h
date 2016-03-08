#import <UIKit/UIKit.h>
#import "StatsStandardBorderedTableViewCell.h"
#import "WPStatsContributionGraph.h"

@interface InsightsPostingActivityTableViewCell : StatsStandardBorderedTableViewCell <WPStatsContributionGraphDataSource>

@property (nonatomic, weak) IBOutlet WPStatsContributionGraph *contributionGraph;

@end
