#import <UIKit/UIKit.h>

@interface WPStatsContainerViewController : UIViewController

@property (nonatomic, weak) IBOutlet UISegmentedControl *periodSegmentControl;

- (IBAction)periodUnitControlDidChange:(UISegmentedControl *)control;

@end
