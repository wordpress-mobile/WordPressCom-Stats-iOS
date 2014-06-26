#import <UIKit/UIKit.h>

@interface WPStatsGraphBarCell : UICollectionViewCell

@property (nonatomic, assign) CGFloat maximumY;

// @[ @{ @"color" : UIColor, @"value" : CGFloat }, @{ ... } ]
@property (nonatomic, strong) NSArray *categoryBars;

@property (nonatomic, copy) NSString *categoryName;

- (void)finishedSettingProperties;

@end
