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

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, readonly) NSUInteger numberOfRows;
@property (nonatomic, readonly) NSUInteger depth;

- (void)addChildStatsItem:(StatsItem *)statsItem;

@end
