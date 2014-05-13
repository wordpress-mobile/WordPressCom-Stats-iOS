#import "WPStatsStyleGuide.h"

@implementation WPStatsStyleGuide

#pragma mark - UIFonts
+ (UIFont *)largePostTitleFont
{
    return [UIFont fontWithName:@"OpenSans-Light" size:32.0];
}

+ (NSDictionary *)regularTextAttributes
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = 24;
    paragraphStyle.maximumLineHeight = 24;
    return @{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName : [self regularTextFont]};
}

+ (UIFont *)regularTextFont
{
    return [UIFont fontWithName:@"OpenSans" size:16.0];
}

+ (UIFont *)regularTextFontBold
{
    return [UIFont fontWithName:@"OpenSans-Bold" size:16.0];
}

+ (UIFont *)subtitleFont
{
    return [UIFont fontWithName:@"OpenSans" size:12.0];
}

+ (UIFont *)subtitleFontBold
{
    return [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
}

+ (UIFont *)tableviewSectionHeaderFont
{
    return [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
}

+ (UIFont *)tableviewSubtitleFont
{
    return [UIFont fontWithName:@"OpenSans-Light" size:18.0];
}

#pragma mark - UIColors

+ (UIColor *)allTAllShadeGrey
{
	return  [UIColor colorWithRed:153/255.0f green:153/255.0f blue:153/255.0f alpha:1.0f];
}

+ (UIColor *)baseLighterBlue
{
    return [UIColor colorWithRed:30/255.0f green:140/255.0f blue:190/255.0f alpha:1.0f];
}

+ (UIColor *)baseDarkerBlue
{
    return [UIColor colorWithRed:0/255.0f green:116/255.0f blue:162/255.0f alpha:1.0f];
}

+ (UIColor *)itsEverywhereGrey
{
	return [UIColor colorWithRed:238/255.0f green:238/255.0f blue:238/255.0f alpha:1.0f];
}

+ (UIColor *)littleEddieGrey
{
	return [UIColor colorWithRed:51/255.0f green:51/255.0f blue:51/255.0f alpha:1.0f];
}

+ (UIColor *)newKidOnTheBlockBlue
{
	return [UIColor colorWithRed:46/255.0f green:162/255.0f blue:204/255.0f alpha:1.0f];
}

+ (UIColor *)readGrey
{
	return [UIColor colorWithRed:221/255.0f green:221/255.0f blue:221/255.0f alpha:1.0f];
}

+ (UIColor *)whisperGrey
{
    return  [UIColor colorWithRed:102/255.0f green:102/255.0f blue:102/255.0f alpha:1.0f];
}

+ (UIColor *)statsLighterBlue {
    return [UIColor colorWithRed:143.0f/255.0f green:186.0f/255.0f blue:203.0f/255.0f alpha:1.0f];
}

+ (UIColor *)statsDarkerBlue {
    return [UIColor colorWithRed:25.0f/255.0f green:88.0f/255.0f blue:137.0f/255.0f alpha:1.0f];
}

+ (void)configureColorsForView:(UIView *)view andTableView:(UITableView *)tableView
{
    tableView.backgroundView = nil;
    view.backgroundColor = [self itsEverywhereGrey];
    tableView.backgroundColor = [self itsEverywhereGrey];
    tableView.separatorColor = [self readGrey];
}


@end
