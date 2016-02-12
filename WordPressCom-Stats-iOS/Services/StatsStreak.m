#import "StatsStreak.h"

@implementation StatsStreak

- (NSString *)description
{
    return [NSString stringWithFormat:@"StatsStreak- longest length: %@, longest start date: %@, longest end date: %@ -- current length: %@, current start date: %@, current end date: %@",
            self.longestStreakLength,
            self.longestStreakStartDate,
            self.longestStreakEndDate,
            self.currentStreakLength,
            self.currentStreakStartDate,
            self.currentStreakEndDate];
}

@end
