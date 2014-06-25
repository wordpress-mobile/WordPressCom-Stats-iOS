#import "WPStatsGraphViewController.h"
#import "WPStatsGraphLegendView.h"
#import <WPStyleGuide.h>

@interface WPStatsGraphViewController () <UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;

@end

static NSString *const CategoryBarCell = @"CategoryBarCell";
static NSString *const LegendView = @"LegendView";

@implementation WPStatsGraphViewController

- (instancetype)init
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        _flowLayout = layout;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    
    self.flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CategoryBarCell];
    [self.collectionView registerClass:[WPStatsGraphLegendView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:LegendView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [self.flowLayout invalidateLayout];
}

#pragma mark - UICollectionViewDelegate methods

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.viewsVisitors viewsVisitorsForUnit:self.currentUnit][StatsViewsCategory] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CategoryBarCell forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        WPStatsGraphLegendView *legend = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:LegendView forIndexPath:indexPath];
        // FIXME - These category titles ARE NOT LOCALIZABLE
        [legend addCategory:StatsViewsCategory withColor:[WPStyleGuide statsLighterBlue]];
        [legend addCategory:StatsVisitorsCategory withColor:[WPStyleGuide statsDarkerBlue]];
        [legend finishedAddingCategories];

        return legend;
    }
    
    UICollectionReusableView *supplementaryView = [[UICollectionReusableView alloc] init];
    
    return supplementaryView;
}

#pragma mark - UICollectionViewDelegateFlowLayout methods

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake(10, 150);//CGRectGetHeight(collectionView.frame));
    
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(CGRectGetWidth(collectionView.frame), 25.0);
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
//{
//    
//}


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;



@end
