#import <Foundation/Foundation.h>

@interface StatsGroup : NSObject

@property (nonatomic, strong)   NSArray *items; // StatsItem
@property (nonatomic, assign)   BOOL moreItemsExist;
@property (nonatomic, copy)     NSString *titlePrimary;
@property (nonatomic, copy)     NSString *titleSecondary;
@property (nonatomic, strong)   NSURL *iconUrl;

@end
