#import <UIKit/UIKit.h>

@interface WPStatsStyleGuide : NSObject

// Fonts
+ (UIFont *)largePostTitleFont;
+ (NSDictionary *)regularTextAttributes;
+ (UIFont *)regularTextFont;
+ (UIFont *)regularTextFontBold;
+ (UIFont *)subtitleFont;
+ (UIFont *)subtitleFontBold;
+ (UIFont *)tableviewSubtitleFont;


// Colors
+ (UIColor *)baseLighterBlue;
+ (UIColor *)baseDarkerBlue;
+ (UIColor *)itsEverywhereGrey;
+ (UIColor *)littleEddieGrey;
+ (UIColor *)newKidOnTheBlockBlue;
+ (UIColor *)readGrey;
+ (UIColor *)whisperGrey;
+ (UIColor *)statsLighterBlue;
+ (UIColor *)statsDarkerBlue;

// Utilities
+ (void)configureColorsForView:(UIView *)view andTableView:(UITableView *)tableView;

@end
