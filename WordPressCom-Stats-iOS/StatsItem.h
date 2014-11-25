#import <Foundation/Foundation.h>

@interface StatsItem : NSObject

@property (nonatomic, strong)   NSNumber *itemID;
@property (nonatomic, strong)   NSString *value;    // This should be formatted/localized
@property (nonatomic, copy)     NSString *label;
@property (nonatomic, strong)   NSURL *iconURL;
@property (nonatomic, strong)   NSArray *actions;   // @[StatsItemAction]
@property (nonatomic, strong)   NSArray *children;  // @[StatsItem]

@end
