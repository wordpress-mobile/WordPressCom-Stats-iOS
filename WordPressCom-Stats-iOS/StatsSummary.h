#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, StatsPeriodUnit) {
    StatsPeriodUnitDay,
    StatsPeriodUnitWeek,
    StatsPeriodUnitMonth,
    StatsPeriodUnitYear
};

@interface StatsSummary : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) StatsPeriodUnit periodUnit;
@property (nonatomic, strong) NSNumber *views;
@property (nonatomic, strong) NSNumber *visitors;
@property (nonatomic, strong) NSNumber *likes;
@property (nonatomic, strong) NSNumber *reblogs;
@property (nonatomic, strong) NSNumber *comments;

@end
