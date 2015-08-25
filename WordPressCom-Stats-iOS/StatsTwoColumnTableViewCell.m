#import "StatsTwoColumnTableViewCell.h"
#import "WPStyleGuide+Stats.h"
#import <WordPress-iOS-Shared/WPImageSource.h>
#import "StatsBorderedCellBackgroundView.h"
#import <QuartzCore/QuartzCore.h>
#import "WPStyleGuide+Stats.h"

@interface StatsTwoColumnTableViewCell ()

@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;
@property (nonatomic, weak) IBOutlet UIImageView *iconImageView;
@property (nonatomic, weak) IBOutlet UILabel *leftHandGlyphLabel;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *widthConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *spaceConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *leadingEdgeConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *rightEdgeConstraint;

@end

static NSString *const StatsTwoColumnCellChevronExpanded = @"";
static NSString *const StatsTwoColumnCellChevronCollapsed = @"";
static NSString *const StatsTwoColumnCellLink = @"";
static NSString *const StatsTwoColumnCellTag = @"";
static NSString *const StatsTwoColumnCellCategory = @"";

@implementation StatsTwoColumnTableViewCell

- (void)doneSettingProperties
{
    self.leftLabel.text = self.leftText;
    self.rightLabel.text = self.rightText;
    self.leftHandGlyphLabel.hidden = !self.expandable && self.selectType == StatsTwoColumnTableViewCellSelectTypeDetail;

    if (self.selectable) {
        self.selectionStyle = UITableViewCellSelectionStyleDefault;
        self.rightEdgeConstraint.constant = 8.0f;
        
        if (self.selectType == StatsTwoColumnTableViewCellSelectTypeURL) {
            self.leftLabel.textColor = [WPStyleGuide wordPressBlue];
        }
        
        if (self.expandable == NO) {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.rightEdgeConstraint.constant = -2.0f;
        } else {
            self.accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8.0f, 13.0f)];
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
    } else if (self.selectType == StatsTwoColumnTableViewCellSelectTypeURL) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"WordPressCom-Stats-iOS" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        
        if ([[UIImage class] respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
            self.iconImageView.image = [UIImage imageNamed:@"world.png" inBundle:bundle compatibleWithTraitCollection:nil];
        } else {
            NSString *imagePath = [bundle pathForResource:@"world" ofType:@"png"];
            self.iconImageView.image = [UIImage imageWithContentsOfFile:imagePath];
        }
    } else {
        self.iconImageView.hidden = YES;
        self.widthConstraint.constant = 0.0f;
        self.spaceConstraint.constant = 0.0f;
    }
    
    BOOL isNestedRow = self.indentLevel > 1;
    if (isNestedRow || self.expanded) {
        StatsBorderedCellBackgroundView *backgroundView = (StatsBorderedCellBackgroundView *)self.backgroundView;
        backgroundView.contentBackgroundView.backgroundColor = [WPStyleGuide statsNestedCellBackground];
    }
    
    self.leftHandGlyphLabel.textColor = [WPStyleGuide grey];
    if (self.expandable && self.expanded) {
        self.leftHandGlyphLabel.text = StatsTwoColumnCellChevronExpanded;
    } else if (self.expandable && !self.expanded){
        self.leftHandGlyphLabel.text = StatsTwoColumnCellChevronCollapsed;
    } else if (self.selectType == StatsTwoColumnTableViewCellSelectTypeURL) {
        self.leftHandGlyphLabel.text = StatsTwoColumnCellLink;
    } else if (self.selectType == StatsTwoColumnTableViewCellSelectTypeTag) {
        self.leftHandGlyphLabel.text = StatsTwoColumnCellTag;
    } else if (self.selectType == StatsTwoColumnTableViewCellSelectTypeCategory) {
        self.leftHandGlyphLabel.text = StatsTwoColumnCellCategory;
    }
    
    CGFloat indentWidth = self.indentable ? self.indentLevel * 8.0f + 15.0f : 23.0f;
    // Account for chevron or link icon or if its a nested row
    indentWidth += !self.leftHandGlyphLabel.hidden || self.indentLevel > 1 ? 28.0f : 0.0f;
    self.leadingEdgeConstraint.constant = indentWidth;
    
    [self setNeedsUpdateConstraints];
}


- (void)prepareForReuse
{
    [super prepareForReuse];

    self.leftLabel.text = nil;
    self.rightLabel.text = nil;
    self.leftLabel.textColor = [UIColor blackColor];
    self.iconImageView.image = nil;
    
    self.iconImageView.hidden = NO;
    self.widthConstraint.constant = 20.0f;
    self.spaceConstraint.constant = 8.0f;
    self.leadingEdgeConstraint.constant = 43.0f;
    self.rightEdgeConstraint.constant = 23.0f;
    StatsBorderedCellBackgroundView *backgroundView = (StatsBorderedCellBackgroundView *)self.backgroundView;
    backgroundView.contentBackgroundView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.accessoryView = nil;
    self.selectType = StatsTwoColumnTableViewCellSelectTypeDetail;
 
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
