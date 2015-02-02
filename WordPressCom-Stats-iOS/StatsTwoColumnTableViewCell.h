#import "StatsSelectableTableViewCell.h"
#import "StatsStandardBorderedTableViewCell.h"

@interface StatsTwoColumnTableViewCell : StatsStandardBorderedTableViewCell

@property (nonatomic, copy) NSString *leftText;
@property (nonatomic, copy) NSString *rightText;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) NSUInteger indentLevel;
@property (nonatomic, assign) BOOL selectable;

- (void)doneSettingProperties;

@end
