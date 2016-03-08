#import <UIKit/UIKit.h>

@protocol WPStatsContributionGraphDataSource <NSObject>

@required

/**
 @discussion    For the current date, return [NSDate date]
 @returns   A NSDate in month that the graph should display
 */
- (NSDate *)monthForGraph;

/**
 @discussion    If there is no value, return nil
 @param     day Defined from 1 to the last day of the month in the graph.
 @returns   The value to display for each day of the month.
 */
- (NSInteger)valueForDay:(NSUInteger)day;

@optional
/**
 @description If this method isn't implemented, the default value of 5 is used.
 @returns  Returns the number of color divides in the graph.
 */
- (NSUInteger)numberOfGrades;

/**
 @description   Each grade requires exactly one color.
 If this method isn't implemented, the default 5 color scheme is used.
 @param grade   The grade index. From 0-numberOfGrades
 @returns   A UIColor for the specified grade.
 */
- (UIColor *)colorForGrade:(NSUInteger)grade;

/**
 @description   defines how values are translated into grades
 If this method isn't implemented, the default values are used.
 @param grade   The grade from 0-numberOfGrades
 @returns   An NSUInteger that specifies the minimum cutoff for a grade
 */
- (NSInteger)minimumValueForGrade:(NSUInteger)grade;

@end

@interface WPStatsContributionGraph : UIView

#pragma mark - Properties

// If you want to fine tune the size, override these two properties.
@property (nonatomic) CGFloat cellSize;
@property (nonatomic) CGFloat cellSpacing;
@property (nonatomic, weak) IBOutlet id<WPStatsContributionGraphDataSource> delegate;

@end
