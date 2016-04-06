#import "InsightsPostingActivityCollectionViewController.h"
#import "InsightsPostingActivityCollectionViewCell.h"
#import "InsightsContributionGraphFooterView.h"

@interface InsightsPostingActivityCollectionViewController ()

@end

@implementation InsightsPostingActivityCollectionViewController

static NSString * const reuseIdentifier = @"PostingActivityCollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];    
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
    InsightsPostingActivityCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
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
    if (kind == UICollectionElementKindSectionFooter){
        InsightsContributionGraphFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"PostingActivityCollectionFooterView" forIndexPath:indexPath];
        return footer;
    }

}

@end
