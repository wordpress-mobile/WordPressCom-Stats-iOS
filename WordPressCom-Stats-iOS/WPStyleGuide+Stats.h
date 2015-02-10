#import "WPStyleGuide.h"

extern const CGFloat StatsVCHorizontalOuterPadding;
extern const CGFloat StatsCVerticalOuterPadding;

@interface WPStyleGuide (Stats)

+ (UIFont *)axisLabelFont;

+ (UIColor *)statsLighterOrangeTransparent;
+ (UIColor *)statsLighterOrange;
+ (UIColor *)statsDarkerOrange;

+ (UIColor *)statsMediumBlue;
+ (UIColor *)statsMediumGray;
+ (UIColor *)statsLightGray;
+ (UIColor *)statsUltraLightGray;
+ (UIColor *)statsDarkGray;
+ (UIColor *)statsLessDarkGrey;
+ (UIColor *)statsLightGrayZeroValue;

+ (UIColor *)statsNestedCellBackground;

+ (UIFont *)subtitleFontBoldItalic;

@end
