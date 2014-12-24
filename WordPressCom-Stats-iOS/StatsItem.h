#import <Foundation/Foundation.h>

@interface StatsItem : NSObject

@property (nonatomic, strong)   NSNumber *itemID;
@property (nonatomic, strong)   NSString *value;    // This should be formatted/localized
@property (nonatomic, strong)   NSDate *date;       // Used for age calculations
@property (nonatomic, copy)     NSString *label;
@property (nonatomic, strong)   NSURL *iconURL;
@property (nonatomic, strong)   NSArray *actions;   // @[StatsItemAction]

@property (nonatomic, weak)     StatsItem *parent;
@property (nonatomic, readonly) NSMutableArray *children;  // @[StatsItem]

- (void)addChildStatsItem:(StatsItem *)statsItem;

@end
