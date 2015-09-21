#import "UIViewController+SizeClass.h"

@implementation UIViewController (SizeClass)

- (BOOL)isViewHorizontallyCompact
{
    // iOS <= 8:
    // We'll just consider 'Compact' all of non iPad Devices
    if ([self respondsToSelector:@selector(traitCollection)] == false) {
        return IS_IPAD == false;
    }
    
    return self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact;
}

@end
