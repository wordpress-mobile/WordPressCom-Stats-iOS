#import "StatsTwoColumnTableViewCell.h"
#import "WPStyleGuide+Stats.h"
#import <WPImageSource.h>
#import "StatsBorderedCellBackgroundView.h"

@interface StatsTwoColumnTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *spaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingEdgeConstraint;

@end

@implementation StatsTwoColumnTableViewCell

- (void)doneSettingProperties
{
    self.leftLabel.text = self.leftText;
    self.rightLabel.text = self.rightText;

    if (self.selectable) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
    }
    
    self.iconImageView.image = nil;

    // Hide the image if one isn't set
    if (self.imageURL) {
        [[WPImageSource sharedSource] downloadImageForURL:self.imageURL withSuccess:^(UIImage *image) {
            self.iconImageView.image = image;
            self.iconImageView.backgroundColor = [UIColor clearColor];
        } failure:^(NSError *error) {
            DDLogWarn(@"Unable to download icon %@", error);
        }];
    } else {
        self.widthConstraint.constant = 0.0f;
        self.spaceConstraint.constant = 0.0f;
    }
    
    BOOL isNestedRow = self.indentLevel > 1;
    if (isNestedRow) {
        self.backgroundColor = [WPStyleGuide itsEverywhereGrey];
    }
    
    CGFloat indentWidth = self.indentLevel * 7.0f;
    self.leadingEdgeConstraint.constant = indentWidth;
    
    [self setNeedsLayout];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.leftLabel.text = nil;
    self.rightLabel.text = nil;
    self.iconImageView.image = nil;
    
    self.widthConstraint.constant = 20.0f;
    self.spaceConstraint.constant = 8.0f;
    self.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
