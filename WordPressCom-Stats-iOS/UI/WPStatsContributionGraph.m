#import "WPStatsContributionGraph.h"
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
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:_graphMonth];
    comp.day = 1;
    NSDate *firstDay = [calendar dateFromComponents:comp];
    
    comp.month = comp.month + 1;
    NSDate *nextMonth = [calendar dateFromComponents:comp];
    
    NSArray *weekdayNames = @[@"S", @"M", @"T", @"W", @"T", @"F", @"S"];
    
    [[UIColor colorWithWhite:0.56 alpha:1] setFill];
    NSInteger textHeight = self.cellSize * 1.2;
    for (NSInteger i = 0; i < 7; i += 1) {
        CGRect rect = CGRectMake(i * (self.cellSize + self.cellSpacing), 0, self.cellSize, self.cellSize);
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
        paragraphStyle.lineBreakMode = NSLineBreakByClipping;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSDictionary *attributes = @{
                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Light" size:self.cellSize * 0.65],
                                     NSParagraphStyleAttributeName: paragraphStyle,
                                     };
        [weekdayNames[i] drawInRect:rect withAttributes:attributes];
    }
    
    for (NSDate *date = firstDay; [date compare:nextMonth] == NSOrderedAscending; date = [self getDateAfterDate:date]) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *comp = [calendar components:NSCalendarUnitWeekday | NSCalendarUnitWeekOfMonth | NSCalendarUnitDay fromDate:date];
        NSInteger weekday = comp.weekday;
        NSInteger weekOfMonth = comp.weekOfMonth;
        NSInteger day = comp.day;
        
        NSInteger grade = 0;
        NSInteger contributions = 0;
        if ([self.delegate respondsToSelector:@selector(valueForDay:)]) {
            contributions = [self.delegate valueForDay:day];
        }
        
        // Get the grade from the minimum cutoffs
        for (int i = 0; i < _gradeCount; i++) {
            if ([_gradeMinCutoff[i] integerValue] <= contributions) {
                grade = i;
            }
        }
        
        [self.colors[grade] setFill];
        
        CGRect backgroundRect = CGRectMake((weekday - 1) * (self.cellSize + self.cellSpacing),
                                           (weekOfMonth - 1) * (self.cellSize + self.cellSpacing) + textHeight,
                                           self.cellSize, self.cellSize);
        CGContextFillRect(context, backgroundRect);
        
        if ([self.delegate respondsToSelector:@selector(dateTapped:)]) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = backgroundRect;
            [button addTarget:self action:@selector(daySelected:) forControlEvents:UIControlEventTouchUpInside];
            
            NSDictionary *data = @{
                                   @"date": [self getDateAfterDate:date],
                                   @"value": @([self.delegate valueForDay:day])
                                   };
            objc_setAssociatedObject(button, @"dynamic_key", data, OBJC_ASSOCIATION_COPY);
            [self addSubview:button];
        }
    }
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
