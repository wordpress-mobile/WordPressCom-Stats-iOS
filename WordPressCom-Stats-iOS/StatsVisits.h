#import <Foundation/Foundation.h>

@interface StatsVisits : NSObject

@property (nonatomic, strong) NSDate *date;

// NSArray of StatsSummary objects
@property (nonatomic, strong) NSArray *statsData;

@end
