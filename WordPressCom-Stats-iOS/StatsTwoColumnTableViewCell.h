#import "StatsSelectableTableViewCell.h"
#import "StatsStandardBorderedTableViewCell.h"

@interface StatsTwoColumnTableViewCell : StatsStandardBorderedTableViewCell

@property (nonatomic, copy) NSString *leftText;
@property (nonatomic, copy) NSString *rightText;
@property (nonatomic, strong) NSURL *imageURL;
@property (nonatomic, assign) BOOL showCircularIcon;
@property (nonatomic, assign) NSUInteger indentLevel;
@property (nonatomic, assign) BOOL selectable;
@property (nonatomic, assign) BOOL indentable;
@property (nonatomic, assign) BOOL expandable;
@property (nonatomic, assign) BOOL expanded;

- (void)doneSettingProperties;

@end
