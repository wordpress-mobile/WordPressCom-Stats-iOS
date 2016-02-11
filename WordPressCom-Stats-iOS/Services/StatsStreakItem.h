#import <Foundation/Foundation.h>

@interface StatsStreakItem : NSObject

@property (nonatomic, strong)   NSString *value;
@property (nonatomic, strong)   NSString *timeStamp;
@property (nonatomic, readonly) NSDate   *date;

@end
