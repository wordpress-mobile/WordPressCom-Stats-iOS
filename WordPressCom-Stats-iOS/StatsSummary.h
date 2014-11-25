#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StatsPeriodUnit) {
    StatsPeriodUnitDay,
    StatsPeriodUnitWeek,
    StatsPeriodUnitMonth,
    StatsPeriodUnitYear
};

typedef NS_ENUM(NSInteger, StatsSummaryType) {
    StatsSummaryTypeViews,
    StatsSummaryTypeVisitors,
    StatsSummaryTypeLikes,
    StatsSummaryTypeComments
};

@interface StatsSummary : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) StatsPeriodUnit periodUnit;
@property (nonatomic, strong) NSNumber *views;
@property (nonatomic, strong) NSNumber *visitors;
@property (nonatomic, strong) NSNumber *likes;
@property (nonatomic, strong) NSNumber *comments;

@end
