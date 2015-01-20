#import "StatsSelectableTableViewCell.h"

@interface StatsTwoColumnTableViewCell : StatsSelectableTableViewCell

@property (nonatomic, copy) NSString *leftText;
@property (nonatomic, copy) NSString *rightText;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) NSUInteger indentLevel;
@property (nonatomic, assign) BOOL selectable;

- (void)doneSettingProperties;

@end
