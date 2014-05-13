#import <UIKit/UIKit.h>

@interface StatsCounterCell : UITableViewCell

+ (CGFloat)heightForRow;

- (void)setTitle:(NSString *)title;
- (void)addCount:(NSNumber *)count withLabel:(NSString *)label;

@end
