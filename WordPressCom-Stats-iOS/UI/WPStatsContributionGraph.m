#import "WPStatsContributionGraph.h"
#import "WPStyleGuide+Stats.h"
#import <WordPressShared/WPFontManager.h>
#import <objc/runtime.h>

static const NSInteger kDefaultGradeCount = 5;

@interface WPStatsContributionGraph ()

@property (nonatomic) NSUInteger gradeCount;
@property (nonatomic, strong) NSMutableArray *gradeMinCutoff;
@property (nonatomic, strong) NSDate *graphMonth;
@property (nonatomic, strong) NSMutableArray *colors;

@end


@implementation WPStatsContributionGraph


- (void)loadDefaults
{
    self.opaque = NO;
    
    // Load one-time data from the delegate
    
    // Get the total number of grades
    if ([_delegate respondsToSelector:@selector(numberOfGrades)]) {
        _gradeCount = [_delegate numberOfGrades];
    }
    else {
        _gradeCount = kDefaultGradeCount;
    }
    
    // Load all of the colors from the delegate
    if ([_delegate respondsToSelector:@selector(colorForGrade:)]) {
        _colors = [[NSMutableArray alloc] initWithCapacity:_gradeCount];
        for (int i = 0; i < _gradeCount; i++) {
            [_colors addObject:[_delegate colorForGrade:i]];
        }
    }
    else {
        // Use the defaults
        _colors = [[NSMutableArray alloc] initWithObjects:
                   [UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1],
                   [UIColor colorWithRed:0.839 green:0.902 blue:0.522 alpha:1],
                   [UIColor colorWithRed:0.549 green:0.776 blue:0.396 alpha:1],
                   [UIColor colorWithRed:0.267 green:0.639 blue:0.251 alpha:1],
                   [UIColor colorWithRed:0.118 green:0.408 blue:0.137 alpha:1], nil];
        // Check if there is the correct number of colors
        if (_gradeCount != kDefaultGradeCount) {
            [[NSException exceptionWithName:@"Invalid Data" reason:@"The number of grades does not match the number of colors. Implement colorForGrade: to define a different number of colors than the default 5" userInfo:NULL] raise];
        }
    }
    
    // Get the minimum cutoff for each grade
    if ([_delegate respondsToSelector:@selector(minimumValueForGrade:)]) {
        _gradeMinCutoff = [[NSMutableArray alloc] initWithCapacity:_gradeCount];
        for (int i = 0; i < _gradeCount; i++) {
            // Convert each value to a NSNumber
            [_gradeMinCutoff addObject:@([_delegate minimumValueForGrade:i])];
        }
    }
    else {
        // Use the default values
        _gradeMinCutoff = [[NSMutableArray alloc] initWithObjects:
                           @0,
                           @1,
                           @3,
                           @6,
                           @8, nil];
        
        if (_gradeCount != kDefaultGradeCount) {
            [[NSException exceptionWithName:@"Invalid Data" reason:@"The number of grades does not match the number of grade cutoffs. Implement minimumValueForGrade: to define the correct number of cutoff values" userInfo:NULL] raise];
        }
    }
    
    if ([_delegate respondsToSelector:@selector(monthForGraph)]) {
        _graphMonth = [_delegate monthForGraph];
    }
    else {
        // Use the current month by default
        _graphMonth = [NSDate date];
    }
    
    _cellSpacing = floor(CGRectGetWidth(self.frame) / 20);
    _cellSize = _cellSpacing * 2;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    NSInteger columnCount = 0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setFirstWeekday:2]; // Sunday == 1, Saturday == 7...Make the first day of the week Monday
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:_graphMonth];
    comp.day = 1;
    NSDate *firstDay = [calendar dateFromComponents:comp];
    comp.month = comp.month + 1;
    NSDate *nextMonth = [calendar dateFromComponents:comp];
    
    NSDictionary *dayNumberTextAttributes = nil;
    if (self.showDayNumbers) {
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        dayNumberTextAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:self.cellSize * 0.4], NSParagraphStyleAttributeName: paragraphStyle};
    }
    
    for (NSDate *date = firstDay; [date compare:nextMonth] == NSOrderedAscending; date = [self getDateAfterDate:date]) {
        NSDateComponents *comp = [calendar components:NSCalendarUnitDay fromDate:date];
        NSInteger day = comp.day;
        // These two calls will ensure the proper values for weekday & week of month are returned
        // given we are starting the week on a Monday instead of a Sunday
        NSInteger weekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:date];;
        NSInteger weekOfMonth = [calendar ordinalityOfUnit:NSCalendarUnitWeekOfMonth inUnit:NSCalendarUnitMonth forDate:date];;
        
        NSInteger grade = 0;
        NSInteger contributions = 0;
        if ([self.delegate respondsToSelector:@selector(valueForDay:)]) {
            contributions = [self.delegate valueForDay:date];
        }
        
        // Get the grade from the minimum cutoffs
        for (int i = 0; i < _gradeCount; i++) {
            if ([_gradeMinCutoff[i] integerValue] <= contributions) {
                grade = i;
            }
        }
        
        [self.colors[grade] setFill];
        
        CGFloat column = (weekOfMonth - 1) * (self.cellSize + self.cellSpacing);
        CGFloat row = (weekday - 1) * (self.cellSize + self.cellSpacing);
        CGRect backgroundRect = CGRectMake(column, row, self.cellSize, self.cellSize);
        CGContextFillRect(context, backgroundRect);
        
        if (self.showDayNumbers) {
            NSString *string = [NSString stringWithFormat:@"%ld", (long)day];
            [string drawInRect:backgroundRect withAttributes:dayNumberTextAttributes];
        }
        
        columnCount = (columnCount < weekOfMonth) ? weekOfMonth : columnCount;
    }

    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setDateFormat:@"MMM"];
    NSString *monthName = [formatter stringFromDate:_graphMonth];
    CGRect labelRect = CGRectMake( (((self.cellSize * columnCount)/2.0)-(self.cellSize/2.0)), self.cellSize * 9.0, self.cellSize * 3.0, self.cellSize * 1.2);
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByClipping;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [WPFontManager systemRegularFontOfSize:13.0],
                                 NSForegroundColorAttributeName: [WPStyleGuide statsDarkGray],
                                 NSParagraphStyleAttributeName: paragraphStyle,
                                 };
    [[monthName uppercaseString] drawInRect:labelRect withAttributes:attributes];
}

#pragma mark Setters

- (void)setDelegate:(id<WPStatsContributionGraphDataSource>)delegate
{
    _delegate = delegate;
    [self loadDefaults];
    [self setNeedsDisplay];
}

- (void)setCellSize:(CGFloat)cellSize
{
    _cellSize = cellSize;
    [self setNeedsDisplay];
}

- (void)setCellSpacing:(CGFloat)cellSpacing
{
    _cellSpacing = cellSpacing;
    [self setNeedsDisplay];
}

#pragma Privates

- (NSDate *)getDateAfterDate:(NSDate *)date
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = 1;
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    return [calendar dateByAddingComponents:components toDate:date options:0];
}

@end
