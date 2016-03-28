#import "InsightsPostingActivityTableViewCell.h"
#import "StatsStreakItem.h"

@implementation InsightsPostingActivityTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.contributionGraphLeft.cellSpacing = 3.0;
    self.contributionGraphLeft.cellSize = 12.0;
    
    self.contributionGraphCenter.cellSpacing = 3.0;
    self.contributionGraphCenter.cellSize = 12.0;
    
    self.contributionGraphRight.cellSpacing = 3.0;
    self.contributionGraphRight.cellSize = 12.0;
}

@end
