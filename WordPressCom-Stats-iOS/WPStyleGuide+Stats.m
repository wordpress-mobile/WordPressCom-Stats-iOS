#import "WPStyleGuide+Stats.h"
#import <WPFontManager.h>

const CGFloat RPTVCHorizontalOuterPadding = 8.0f;
const CGFloat RPTVCVerticalOuterPadding = 16.0f;

@implementation WPStyleGuide (Stats)

+ (UIFont *)axisLabelFont {
    return [WPFontManager openSansRegularFontOfSize:8.0];
}

+ (UIColor *)statsLighterOrange
{
    return [UIColor colorWithRed:0.965 green:0.718 blue:0.494 alpha:1]; /*#f6b77e*/
}

+ (UIColor *)statsLighterOrangeTransparent
{
    return [UIColor colorWithRed:0.965 green:0.718 blue:0.494 alpha:0.3]; /*#f6b77e*/
}

+ (UIColor *)statsMediumBlue
{
    return [UIColor colorWithRed:0 green:0.667 blue:0.863 alpha:1]; /*#00aadc*/
}

+ (UIColor *)statsDarkerOrange
{
    return [self jazzyOrange];
}

+ (UIColor *)statsLightGray
{
    return [UIColor colorWithRed:0.91 green:0.941 blue:0.961 alpha:1]; /*#e8f0f5*/
}

+ (UIColor *)statsUltraLightGray
{
    return [UIColor colorWithRed:0.957 green:0.973 blue:0.98 alpha:1]; /*#f4f8fa*/
}

+ (UIFont *)subtitleFontBoldItalic
{
    return [WPFontManager openSansBoldItalicFontOfSize:12.0];
}

@end
