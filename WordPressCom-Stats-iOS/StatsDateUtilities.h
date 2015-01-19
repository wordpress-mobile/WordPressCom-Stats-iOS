#import <Foundation/Foundation.h>
#import "StatsSummary.h"

@interface StatsDateUtilities : NSObject

- (NSDate *)calculateEndDateForPeriodUnit:(StatsPeriodUnit)unit withDateWithinPeriod:(NSDate *)date;

@end
