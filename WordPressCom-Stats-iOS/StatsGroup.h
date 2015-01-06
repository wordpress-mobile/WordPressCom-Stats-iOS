#import <Foundation/Foundation.h>
#import "StatsItem.h"

@interface StatsGroup : NSObject

@property (nonatomic, strong)   NSArray *items; // StatsItem
@property (nonatomic, assign)   BOOL moreItemsExist;
@property (nonatomic, copy)     NSString *titlePrimary;
@property (nonatomic, copy)     NSString *titleSecondary;
@property (nonatomic, strong)   NSURL *iconUrl;
@property (nonatomic, copy)     NSString *totalCount;

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, readonly) NSUInteger numberOfRows;
@property (nonatomic, assign) NSUInteger offsetRows;

- (StatsItem *)statsItemForTableViewRow:(NSInteger)row;

@end
