#import "StatsStringUtilities.h"
#import <WordPressShared/NSString+XMLExtensions.h>

@implementation StatsStringUtilities

- (NSString *)sanitizePostTitle:(NSString *) postTitle {
        NSString *result = [postTitle stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        result = [result stringByDecodingXMLCharacters];

        return result;
}

- (NSString *)emojiFlagForCountryCode:(NSString *)countryCode
{
    if (countryCode.length != 2) {
        return @"";
    }

    int base = 127397;

    wchar_t bytes[2] = {
        base + [countryCode characterAtIndex:0],
        base + [countryCode characterAtIndex:1]
    };

    return [[NSString alloc] initWithBytes:bytes
                                    length:countryCode.length * sizeof(wchar_t)
                                  encoding:NSUTF32LittleEndianStringEncoding];
}

@end
