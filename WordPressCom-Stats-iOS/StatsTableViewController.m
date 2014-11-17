#import "StatsTableViewController.h"
#import "WPStatsGraphViewController.h"

typedef NS_ENUM(NSInteger, StatsSection) {
    StatsSectionGraph,
    StatsSectionPosts,
    StatsSectionReferrers,
    StatsSectionClicks,
    StatsSectionCountry,
    StatsSectionVideos,
    StatsSectionComments,
    StatsSectionTagsCategories,
    StatsSectionFollowers
};

static CGFloat const kGraphHeight = 200.0f;

@interface StatsTableViewController ()

@property (nonatomic, strong) NSArray *sections;
@property (nonatomic, strong) WPStatsGraphViewController *graphViewController;

@end

@implementation StatsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sections = @[ @(StatsSectionGraph),
                       @(StatsSectionPosts),
                       @(StatsSectionReferrers),
                       @(StatsSectionClicks),
                       @(StatsSectionCountry),
                       @(StatsSectionVideos),
                       @(StatsSectionComments),
                       @(StatsSectionTagsCategories),
                       @(StatsSectionFollowers)];
    self.graphViewController = [WPStatsGraphViewController new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    StatsSection statsSection = (StatsSection)[self.sections[section] integerValue];
    switch (statsSection) {
        case StatsSectionGraph:
            return 6;
        case StatsSectionPosts:
            return 1;
        case StatsSectionReferrers:
            return 1;
        case StatsSectionClicks:
            return 1;
        case StatsSectionCountry:
            return 1;
        case StatsSectionVideos:
            return 1;
        case StatsSectionComments:
            return 1;
        case StatsSectionTagsCategories:
            return 1;
        case StatsSectionFollowers:
            return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [self cellIdentifierForIndexPath:indexPath];

    if ([cellIdentifier isEqualToString:@"GraphRow"]) {
        return 200.0f;
    } else if ([cellIdentifier isEqualToString:@"SelectableRow"]) {
        return 35.0f;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}

- (NSString *)cellIdentifierForIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = @"";
    
    StatsSection statsSection = (StatsSection)[self.sections[indexPath.section] integerValue];
    
    switch (statsSection) {
        case StatsSectionGraph: {
            switch (indexPath.row) {
                case 0:
                    identifier = @"GraphRow";
                    break;
                    
                default:
                    identifier = @"SelectableRow";
                    break;
            }
            break;
        }
        case StatsSectionPosts:
        case StatsSectionReferrers:
        case StatsSectionClicks:
        case StatsSectionCountry:
        case StatsSectionVideos:
        case StatsSectionComments:
        case StatsSectionTagsCategories:
        case StatsSectionFollowers: {
            switch (indexPath.row) {
                case 0:
                    identifier = @"GroupHeader";
                    break;
                case 1:
                    identifier = @"TwoColumnHeader";
                    break;
                default:
                    identifier = @"TwoColumnRow";
                    break;
            }
            break;
        }
            
        default:
            break;
    }
    
    return identifier;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = cell.reuseIdentifier;
    if ([identifier isEqualToString:@"GraphRow"]) {
        if (![[cell.contentView subviews] containsObject:self.graphViewController.view]) {
            UIView *graphView = self.graphViewController.view;
            graphView.frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(cell.contentView.bounds), kGraphHeight);
            graphView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            [cell.contentView addSubview:graphView];
        }
    }
    
}

@end
