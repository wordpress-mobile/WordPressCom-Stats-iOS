#import <UIKit/UIKit.h>

@interface StatsTableViewController : UITableViewController

@property (nonatomic, strong) NSNumber *siteID;
@property (nonatomic, copy)   NSString *oauth2Token;
@property (nonatomic, strong) NSTimeZone *siteTimeZone;

@end
