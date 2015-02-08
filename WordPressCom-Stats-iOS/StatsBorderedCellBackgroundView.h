#import <UIKit/UIKit.h>

@interface StatsBorderedCellBackgroundView : UIView

- (instancetype)initWithFrame:(CGRect)frame andSelected:(BOOL)selected;

@property (nonatomic, strong) UIView *theBoxView;
@property (nonatomic, strong) UIView *contentBackgroundView;
@property (nonatomic, strong) UIView *dividerView;
@property (nonatomic, assign) BOOL bottomBorderEnabled;

@end
