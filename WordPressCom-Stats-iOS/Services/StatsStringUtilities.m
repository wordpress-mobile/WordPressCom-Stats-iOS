#import "StatsStringUtilities.h"
#import <WordPressShared/NSString+XMLExtensions.h>

@implementation StatsStringUtilities

- (NSString *)sanitizePostTitle:(NSString *) postTitle
{
    NSString *result = [postTitle stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    result = [result stringByDecodingXMLCharacters];
    return result;
}

- (NSString *)displayablePostTitle:(NSString *)postTitle withId:(NSNumber *)postId
{
    NSString *result = [self sanitizePostTitle:postTitle];
    if (result.length == 0) {
        result = [NSString stringWithFormat:@"#%@ %@",
                                            postId,
                                            NSLocalizedString(@"(untitled)", @"Title for an untitled post, should match WP core")];
    }
    return result;
}

@end
