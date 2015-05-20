#import <Foundation/Foundation.h>

@interface StatsInsights : NSObject

@property (nonatomic, strong) NSDate *highestHour;
@property (nonatomic, strong) NSDate *highestDayOfWeek;
@property (nonatomic, copy) NSString *highestDayPercent;
@property (nonatomic, strong) NSNumber *highestDayPercentValue;

@end
