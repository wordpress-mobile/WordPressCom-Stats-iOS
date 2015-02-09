#import "WPStyleGuide+Stats.h"
#import <WPFontManager.h>

const CGFloat StatsVCHorizontalOuterPadding = 8.0f;
const CGFloat StatsVCVerticalOuterPadding = 16.0f;

@implementation WPStyleGuide (Stats)

+ (UIFont *)axisLabelFont {
    return [WPFontManager openSansRegularFontOfSize:12.0];
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

+ (UIColor *)statsDarkGray
{
    return [UIColor colorWithRed:0.196 green:0.255 blue:0.333 alpha:1]; /*#324155*/
}

+ (UIColor *)statsLessDarkGrey
{
    return [UIColor colorWithRed:0.345 green:0.447 blue:0.584 alpha:1]; /*#587295*/
}

+ (UIColor *)statsLightGray
{
    return [UIColor colorWithRed:0.91 green:0.941 blue:0.961 alpha:1]; /*#e8f0f5*/
}

+ (UIColor *)statsLightGrayZeroValue
{
    return [UIColor colorWithRed:0.576 green:0.651 blue:0.753 alpha:1]; /*#93a6c0*/
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
