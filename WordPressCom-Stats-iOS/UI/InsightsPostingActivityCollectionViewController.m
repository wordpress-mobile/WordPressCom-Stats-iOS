#import "InsightsPostingActivityCollectionViewController.h"
#import "InsightsPostingActivityCollectionViewCell.h"

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

#pragma mark <UICollectionViewDelegate>

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
