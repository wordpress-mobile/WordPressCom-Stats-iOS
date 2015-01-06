#import <Foundation/Foundation.h>
#import "StatsSummary.h"

@interface StatsVisits : NSObject

@property (nonatomic, assign) StatsPeriodUnit unit;
@property (nonatomic, strong) NSDate *date;

// NSArray of StatsSummary objects
@property (nonatomic, strong) NSArray *statsData;
@property (nonatomic, strong) NSDictionary *statsDataByDate;

@property (nonatomic, assign) BOOL errorWhileRetrieving;

@end
