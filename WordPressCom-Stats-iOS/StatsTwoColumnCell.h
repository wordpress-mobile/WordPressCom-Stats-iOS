#import <UIKit/UIKit.h>
#import "StatsTitleCountItem.h"
//#import "WPTableViewCell.h"


// TODO - Figure out how to replace WPTableViewCell
//@interface StatsTwoColumnCell : WPTableViewCell
@interface StatsTwoColumnCell : UITableViewCell

@property (nonatomic, assign) BOOL linkEnabled;

+ (CGFloat)heightForRow;

- (void)insertData:(StatsTitleCountItem *)cellData;
- (void)setLeft:(NSString *)left withImageUrl:(NSURL *)imageUrl right:(NSString *)right titleCell:(BOOL)titleCell;

@end
