#import "InsightsContributionGraphHeaderView.h"
#import "WPStyleGuide+Stats.h"
@import NSObject_SafeExpectations;

static NSString *const DidTouchPostActivityDateNotification = @"DidTouchPostActivityDate";

@implementation InsightsContributionGraphHeaderView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.backgroundColor = [WPStyleGuide statsUltraLightGray];
    [self.dateLabel setText:NSLocalizedString(@"Touch a square to see the date", @"Contribution graph default header label prompting user to tap on a date.")];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    __weak __typeof(self) weakSelf = self;
    [nc addObserverForName: DidTouchPostActivityDateNotification
                        object: nil
                         queue: [NSOperationQueue mainQueue]
                    usingBlock: ^(NSNotification *notification) {
                        NSDictionary *dict = [notification userInfo];
                        if (dict) {
                            NSDate *date = [dict valueForKey:@"date"];
                            NSString *posts = [dict stringForKey:@"value"];
                            if (date && posts) {
                                NSDateFormatter *dateFormatter = [NSDateFormatter new];
                                dateFormatter.dateStyle = NSDateFormatterMediumStyle;
                                dateFormatter.timeStyle = NSDateFormatterNoStyle;
                                [weakSelf.dateLabel setText:[NSString stringWithFormat:NSLocalizedString(@"%@ posts on %@", @"Contribution graph values: number of posts on a specific date."), posts, [dateFormatter stringFromDate:date]]];
                            }
                        }
                    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
