#import "StatsDateUtilities.h"

@implementation StatsDateUtilities

- (NSDate *)calculateEndDateForPeriodUnit:(StatsPeriodUnit)unit withDateWithinPeriod:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    if (unit == StatsPeriodUnitDay) {
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        date = [calendar dateFromComponents:dateComponents];
        
        return date;
    } else if (unit == StatsPeriodUnitMonth) {
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:date];
        date = [calendar dateFromComponents:dateComponents];
        
        dateComponents = [NSDateComponents new];
        dateComponents.day = -1;
        dateComponents.month = +1;
        date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
        
        return date;
    } else if (unit == StatsPeriodUnitWeek) {
        // Weeks are Monday - Sunday
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYearForWeekOfYear | NSCalendarUnitWeekday | NSCalendarUnitWeekOfYear fromDate:date];
        NSInteger weekDay = dateComponents.weekday;
        
        if (weekDay > 1) {
            dateComponents = [NSDateComponents new];
            dateComponents.weekday = 8 - weekDay;
            date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
        }
        
        // Strip time
        dateComponents = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
        date = [calendar dateFromComponents:dateComponents];
        
        return date;
    } else if (unit == StatsPeriodUnitYear) {
        NSDateComponents *dateComponents = [calendar components:NSCalendarUnitYear fromDate:date];
        date = [calendar dateFromComponents:dateComponents];
        
        dateComponents = [NSDateComponents new];
        dateComponents.day = -1;
        dateComponents.year = +1;
        date = [calendar dateByAddingComponents:dateComponents toDate:date options:0];
        
        return date;
    }
    
    return nil;
}


@end
