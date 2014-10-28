#import <Foundation/Foundation.h>

@interface StatsItem : NSObject

@property (nonatomic, strong)   NSNumber *value;
@property (nonatomic, copy)     NSString *label;
@property (nonatomic, strong)   NSURL *iconURL;
@property (nonatomic, strong)   NSArray *actions;     // StatsItemAction
@property (nonatomic, strong)   NSArray *children;    // StatsItem

@end
