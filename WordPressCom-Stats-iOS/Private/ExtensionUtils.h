#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ExtensionUtils : NSObject

+ (void)openURL:(NSURL *)url fromController:(UIViewController *)viewController;

+ (void)setNetworkActivityIndicatorVisible:(BOOL)active fromController:(UIViewController *)viewController;

@end
