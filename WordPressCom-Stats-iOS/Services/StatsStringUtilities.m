#import "StatsStringUtilities.h"
#import <WordPressShared/NSString+XMLExtensions.h>

@implementation StatsStringUtilities

- (NSString *)sanitizePostTitle:(NSString *) postTitle {
        NSString *result = [postTitle stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
        result = [result stringByDecodingXMLCharacters];

        return result;
}

@end
