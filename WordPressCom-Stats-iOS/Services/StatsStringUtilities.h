#import <Foundation/Foundation.h>

@interface StatsStringUtilities : NSObject

- (NSString *)sanitizePostTitle:(NSString *) postTitle;

// Sanitizes a post title and, if the title is empty, returns a
// displayable title of the form '#postId (untitled)' following what Calypso does
- (NSString *)displayablePostTitle:(NSString *)postTitle withId:(NSNumber *)postId;

@end
