#import "WPSAppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import <WPStyleGuide.h>
#import <WPFontManager.h>
#import <UIImage+Util.h>
#import <UIColor+Helpers.h>

int ddLogLevel = DDLogLevelVerbose;

@interface WPSAppDelegate () <BITHockeyManagerDelegate>

@end

@implementation WPSAppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Copied the WPiOS styling setup
    self.window.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    self.window.tintColor = [WPStyleGuide wordPressBlue];
    
    [[UINavigationBar appearance] setBarTintColor:[WPStyleGuide wordPressBlue]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    [[UITabBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor colorWithRed:210.0/255.0 green:222.0/255.0 blue:230.0/255.0 alpha:1.0]]];
    [[UITabBar appearance] setTintColor:[WPStyleGuide newKidOnTheBlockBlue]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor], NSFontAttributeName: [WPFontManager openSansBoldFontOfSize:16.0]} ];
    
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:[WPStyleGuide wordPressBlue]] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor UIColorFromHex:0x007eb1]]];
    
    [[UIBarButtonItem appearance] setTintColor:[UIColor whiteColor]];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [WPStyleGuide regularTextFont], NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [WPStyleGuide regularTextFont], NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.25]} forState:UIControlStateDisabled];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName: [WPStyleGuide regularTextFont]} forState:UIControlStateNormal];
    
    [[UIToolbar appearance] setBarTintColor:[WPStyleGuide wordPressBlue]];
    [[UISwitch appearance] setOnTintColor:[WPStyleGuide wordPressBlue]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSFontAttributeName: [WPFontManager openSansRegularFontOfSize:10.0]} forState:UIControlStateNormal];
    
    [[UINavigationBar appearanceWhenContainedIn:[UIReferenceLibraryViewController class], nil] setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearanceWhenContainedIn:[UIReferenceLibraryViewController class], nil] setBarTintColor:[WPStyleGuide wordPressBlue]];
    [[UIToolbar appearanceWhenContainedIn:[UIReferenceLibraryViewController class], nil] setBarTintColor:[UIColor darkGrayColor]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

#ifndef DEBUG
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"070b75fd7cb3b4f5068c9d59d7052ec4"];
    [[BITHockeyManager sharedHockeyManager].authenticator setIdentificationType:BITAuthenticatorIdentificationTypeDevice];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
#endif
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    BOOL returnValue = NO;
    
    if ([[BITHockeyManager sharedHockeyManager].authenticator handleOpenURL:url
                                                          sourceApplication:sourceApplication
                                                                 annotation:annotation]) {
        returnValue = YES;
    }

    return returnValue;
}
@end
