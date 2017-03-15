#import <Foundation/Foundation.h>

@interface StatsStringUtilities : NSObject

- (NSString *)sanitizePostTitle:(NSString *) postTitle;
+ (NSString *)emojiFlagForCountryCode:(NSString *)countryCode;

@end
