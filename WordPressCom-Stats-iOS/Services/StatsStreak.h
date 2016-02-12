#import <Foundation/Foundation.h>

@interface StatsStreak : NSObject

@property (nonatomic, strong) NSNumber *longestStreakLength;
@property (nonatomic, strong) NSDate   *longestStreakStartDate;
@property (nonatomic, strong) NSDate   *longestStreakEndDate;

@property (nonatomic, strong) NSNumber *currentStreakLength;
@property (nonatomic, strong) NSDate   *currentStreakStartDate;
@property (nonatomic, strong) NSDate   *currentStreakEndDate;

@property (nonatomic, strong) NSArray *items; // StatsStreakItem

@end
