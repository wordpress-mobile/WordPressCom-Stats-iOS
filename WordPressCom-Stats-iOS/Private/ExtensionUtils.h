#import <Foundation/Foundation.h>

@interface ExtensionUtils : NSObject

+ (void)openURL:(NSURL *)url fromController:(UIViewController *)viewController;

+ (void)setNetworkActivityIndicatorVisible:(BOOL)active fromController:(UIViewController *)viewController;

@end
