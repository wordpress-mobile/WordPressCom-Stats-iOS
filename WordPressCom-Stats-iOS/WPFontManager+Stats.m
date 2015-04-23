#import "WPFontManager+Stats.h"
#import <CoreText/CoreText.h>

@implementation WPFontManager (Stats)

static NSString * const kBundle = @"WordPressCom-Stats-iOS.bundle";

+ (UIFont *)noticonsReguarFontOfSize:(CGFloat)size
{
    NSString *resourceName = @"Noticons-Regular";
    NSString *fontName = @"Noticons";
    UIFont *font = [UIFont fontWithName:fontName size:size];
    if (!font) {
        [[super class] dynamicallyLoadStatsFontResourceNamed:resourceName];
        font = [UIFont fontWithName:fontName size:size];
        
        // safe fallback
        if (!font) {
            font = [UIFont systemFontOfSize:size];
        }
    }
    
    return font;
}

+ (void)dynamicallyLoadStatsFontResourceNamed:(NSString *)name
{
    NSString *resourceName = [NSString stringWithFormat:@"%@/%@", kBundle, name];
    NSURL *url = [[NSBundle bundleForClass:self] URLForResource:resourceName withExtension:@"otf"];
    NSData *fontData = [NSData dataWithContentsOfURL:url];
    
    if (fontData) {
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (!CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            DDLogError(@"Failed to load font: %@", errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

@end
