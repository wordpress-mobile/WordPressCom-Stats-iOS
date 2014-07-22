#import "WPStyleGuide+Stats.h"
#import <WPFontManager.h>

@implementation WPStyleGuide (Stats)

+ (UIFont *)axisLabelFont {
    return [UIFont fontWithName:@"OpenSans" size:8.0f];
}

+ (UIColor *)statsLighterOrange
{
    return [UIColor colorWithRed:0.965 green:0.718 blue:0.494 alpha:1]; /*#f6b77e*/
}

+ (UIColor *)statsDarkerOrange
{
    return [UIColor colorWithRed:0.941 green:0.51 blue:0.118 alpha:1]; /*#f0821e*/
}

+ (UIFont *)subtitleFontBoldItalic
{
    return [WPFontManager openSansBoldItalicFontOfSize:12.0];
}

@end
