#import "InsightsPostingActivityCollectionViewController.h"
#import "InsightsPostingActivityCollectionViewCell.h"
#import "InsightsContributionGraphHeaderView.h"
#import "InsightsContributionGraphFooterView.h"

static NSString *const PostActivityCollectionCellIdentifier = @"PostActivityCollectionViewCell";
static NSString *const PostActivityCollectionHeaderIdentifier = @"PostingActivityCollectionHeaderView";
static NSString *const PostActivityCollectionFooterIdentifier = @"PostingActivityCollectionFooterView";

@interface InsightsPostingActivityCollectionViewController ()

@end

@implementation InsightsPostingActivityCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make the header sticky
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    layout.sectionHeadersPinToVisibleBounds = YES;
    layout.sectionFootersPinToVisibleBounds = YES;
    layout.minimumInteritemSpacing = 1;
    layout.minimumLineSpacing = 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 12;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InsightsPostingActivityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PostActivityCollectionCellIdentifier
                                                                                                forIndexPath:indexPath];
    
    NSInteger monthIndex = (-1*indexPath.item);
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *graphMonth = [cal dateByAddingUnit:NSCalendarUnitMonth value:monthIndex toDate:[NSDate date] options:0];
    cell.contributionGraph.monthForGraph = graphMonth;
    cell.contributionGraph.graphData = self.streakData;
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        InsightsContributionGraphHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                         withReuseIdentifier:PostActivityCollectionHeaderIdentifier
                                                                                                forIndexPath:indexPath];
        return header;
    } else if (kind == UICollectionElementKindSectionFooter) {
        InsightsContributionGraphFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                                                                         withReuseIdentifier:PostActivityCollectionFooterIdentifier
                                                                                                forIndexPath:indexPath];
        return footer;
    }
}

@end
