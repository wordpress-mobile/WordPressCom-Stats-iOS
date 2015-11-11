#import "NSObject+StatsBundleHelper.h"

@implementation NSObject (StatsBundleHelper)

- (NSBundle *)statsBundle
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"WordPressCom-Stats-iOS" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    return bundle;
}

@end
