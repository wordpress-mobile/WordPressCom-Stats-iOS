#import <UIKit/UIKit.h>
#import "StatsStandardBorderedTableViewCell.h"
#import "WPStatsContributionGraph.h"

@interface InsightsPostingActivityTableViewCell : StatsStandardBorderedTableViewCell

@property (nonatomic, weak) IBOutlet WPStatsContributionGraph *contributionGraphLeft;
@property (nonatomic, weak) IBOutlet WPStatsContributionGraph *contributionGraphCenter;
@property (nonatomic, weak) IBOutlet WPStatsContributionGraph *contributionGraphRight;

@end
