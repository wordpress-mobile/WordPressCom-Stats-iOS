#import "WPStatsGraphViewController.h"
#import "WPStatsGraphLegendView.h"
#import "WPStatsGraphBarCell.h"
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
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.scrollEnabled = NO;
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0f, 40.0f, 0.0f, 5.0f);
    
    [self.collectionView registerClass:[WPStatsGraphBarCell class] forCellWithReuseIdentifier:CategoryBarCell];
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
    
    [self.collectionView performBatchUpdates:nil completion:nil];
}

#pragma mark - UICollectionViewDelegate methods

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [[self.viewsVisitors viewsVisitorsForUnit:self.currentUnit][StatsViewsCategory] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WPStatsGraphBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CategoryBarCell forIndexPath:indexPath];
    NSDictionary *categoryData = [self.viewsVisitors viewsVisitorsForUnit:self.currentUnit];
    NSArray *barData = @[@{ @"color" : [WPStyleGuide statsLighterBlue],
                            @"value" : categoryData[StatsViewsCategory][indexPath.row][@"count"],
                            @"name" : categoryData[StatsViewsCategory][indexPath.row][@"name"]
                            },
                         @{ @"color" : [WPStyleGuide statsDarkerBlue],
                            @"value" : categoryData[StatsVisitorsCategory][indexPath.row][@"count"],
                            @"name" : categoryData[StatsVisitorsCategory][indexPath.row][@"name"],
                            }
                         ];

    // TODO - Move this to be calculated once per data set
    CGFloat maximumY = 0.0f;
    for (NSDictionary *dict in categoryData[StatsViewsCategory]) {
        NSNumber *number = dict[@"count"];
        if (maximumY < [number floatValue]) {
            maximumY = [number floatValue];
        }
    }
    for (NSDictionary *dict in categoryData[StatsVisitorsCategory]) {
        NSNumber *number = dict[@"count"];
        if (maximumY < [number floatValue]) {
            maximumY = [number floatValue];
        }
    }
    
    [cell setMaximumY:maximumY];
    [cell setCategoryBars:barData];
    // TODO :: Name is the same for all points - should put this somewhere better
    [cell setCategoryName:barData[0][@"name"]];
    [cell finishedSettingProperties];
    
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
    CGFloat width = 30.0f;
    CGFloat height = CGRectGetHeight(collectionView.frame) - 25.0;
    
    CGSize size = CGSizeMake(width, height);
    
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


//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
//{
//    return UIEdgeInsetsMake(0.0, 40.0, 0.0, 0.0);
//}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    CGFloat spacing = floorf((CGRectGetWidth(collectionView.frame) - 45 - (30.0 * 7)) / 7);
    
    return spacing;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;



@end
