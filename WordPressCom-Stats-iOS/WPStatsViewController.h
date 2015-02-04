#import <UIKit/UIKit.h>

@class WPStatsViewController;

@protocol WPStatsViewControllerDelegate <NSObject>

@optional

- (void)statsViewController:(WPStatsViewController *)controller didSelectViewWebStatsForSiteID:(NSNumber *)siteID;
- (void)statsViewController:(WPStatsViewController *)controller openURL:(NSURL *)url;

@end

@interface WPStatsViewController : UINavigationController

@property (nonatomic, strong) NSNumber *siteID;
@property (nonatomic, copy)   NSString *oauth2Token;
@property (nonatomic, strong) NSTimeZone *siteTimeZone;
@property (nonatomic, weak) id<WPStatsViewControllerDelegate> statsDelegate;

@end
