#import "StatsTwoColumnTableViewCell.h"
#import "WPStyleGuide+Stats.h"
#import <WordPress-iOS-Shared/WPImageSource.h>
#import "StatsBorderedCellBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@interface StatsTwoColumnTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *indentChevronLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *spaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingEdgeConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightEdgeConstraint;

@end

@implementation StatsTwoColumnTableViewCell

- (void)doneSettingProperties
{
    self.leftLabel.text = self.leftText;
    self.rightLabel.text = self.rightText;
    self.indentChevronLabel.hidden = !self.expandable;

    if (self.selectable) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if (self.expandable == NO) {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.rightEdgeConstraint.constant = -10.0f;
        } else {
            self.leftLabel.textColor = [WPStyleGuide wordPressBlue];
        }
    }
    
    self.iconImageView.image = nil;

    // Hide the image if one isn't set
    if (self.imageURL) {
        if (self.showCircularIcon) {
            self.iconImageView.layer.cornerRadius = 10.0f;
            self.iconImageView.layer.masksToBounds = YES;
            [self.iconImageView.layer setNeedsDisplay];
        }

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
    if (isNestedRow || self.expanded) {
        StatsBorderedCellBackgroundView *backgroundView = (StatsBorderedCellBackgroundView *)self.backgroundView;
        backgroundView.contentBackgroundView.backgroundColor = [WPStyleGuide statsNestedCellBackground];
    }
    
    if (self.expanded) {
        self.indentChevronLabel.text = @"";
    } else {
        self.indentChevronLabel.text = @"";
    }
    
    CGFloat indentWidth = self.indentable ? self.indentLevel * 8.0f + 7.0f : 15.0f;
    indentWidth += self.expandable || self.indentLevel > 1 ? 28.0f : 0.0f;
    self.leadingEdgeConstraint.constant = indentWidth;
    
    [self setNeedsLayout];
}


- (void)prepareForReuse
{
    [super prepareForReuse];

    self.leftLabel.text = nil;
    self.rightLabel.text = nil;
    self.leftLabel.textColor = [UIColor blackColor];
    self.iconImageView.image = nil;
    
    self.widthConstraint.constant = 20.0f;
    self.spaceConstraint.constant = 8.0f;
    self.leadingEdgeConstraint.constant = 43.0f;
    self.rightEdgeConstraint.constant = 15.0f;
    StatsBorderedCellBackgroundView *backgroundView = (StatsBorderedCellBackgroundView *)self.backgroundView;
    backgroundView.contentBackgroundView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
 
    self.showCircularIcon = NO;
    self.iconImageView.layer.cornerRadius = 0.0f;
    self.iconImageView.layer.masksToBounds = NO;
    [self.iconImageView.layer setNeedsDisplay];
}


- (void)setExpanded:(BOOL)expanded
{
    _expanded = expanded;
    
    self.topBorderDarkEnabled = expanded;
}

@end
