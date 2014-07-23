#import "WPStatsGraphToastView.h"

#import "WPStyleGuide+Stats.h"

@interface WPStatsGraphToastTriangleView : UIView

@end

@implementation WPStatsGraphToastTriangleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat height = CGRectGetHeight(self.frame);
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat xOffset = width / 2.0f;
    
    // Drawing code
    UIBezierPath *trianglePath = [UIBezierPath bezierPath];
    [trianglePath moveToPoint:CGPointMake(xOffset, 0.0f)];
    [trianglePath addLineToPoint:CGPointMake(xOffset * 2.0, height)];
    [trianglePath addLineToPoint:CGPointMake(0.0, height)];
    [trianglePath closePath];
    
    [[WPStyleGuide itsEverywhereGrey] setFill];
    [trianglePath fill];
}

@end

@interface WPStatsGraphToastView ()

@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *viewsLabel;
@property (nonatomic, strong) UILabel *visitorsLabel;
@property (nonatomic, strong) UILabel *viewsPerVisitorLabel;
@property (nonatomic, strong) NSNumberFormatter *numberFormatter;
@property (nonatomic, strong) WPStatsGraphToastTriangleView *triangleView;

@end

@implementation WPStatsGraphToastView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _xOffset = 10.0f;
        
        _numberFormatter = [[NSNumberFormatter alloc] init];
        _numberFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        
        UIView *blueView = [[UIView alloc] initWithFrame:CGRectMake(0, 10.0f, CGRectGetWidth(frame), CGRectGetHeight(frame) - 10.0f)];
        blueView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        blueView.backgroundColor = [WPStyleGuide itsEverywhereGrey];
        [self addSubview:blueView];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 20.0f, 0.0f, 0.0f)];
        _dateLabel.font = [WPStyleGuide subtitleFontBoldItalic];
        _dateLabel.textColor = [WPStyleGuide darkAsNightGrey];
        [_dateLabel sizeToFit];
        [self addSubview:_dateLabel];
        
        _viewsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 40.0f, 0.0f, 0.0f)];
        _viewsLabel.font = [WPStyleGuide subtitleFontBold];
        _viewsLabel.textColor = [WPStyleGuide darkAsNightGrey];
        [_viewsLabel sizeToFit];
        [self addSubview:_viewsLabel];
        
        _visitorsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 55.0f, 0.0f, 0.0f)];
        _visitorsLabel.font = [WPStyleGuide subtitleFontBold];
        _visitorsLabel.textColor = [WPStyleGuide darkAsNightGrey];
        [_visitorsLabel sizeToFit];
        [self addSubview:_visitorsLabel];
        
        _viewsPerVisitorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 70.0f, 0.0f, 0.0f)];
        _viewsPerVisitorLabel.font = [WPStyleGuide subtitleFontBold];
        _viewsPerVisitorLabel.textColor = [WPStyleGuide darkAsNightGrey];
        [_viewsPerVisitorLabel sizeToFit];
        [self addSubview:_viewsPerVisitorLabel];
        
        _triangleView = [[WPStatsGraphToastTriangleView alloc] initWithFrame:CGRectMake(0, 0, 20.0f, 11.0f)];
        [self addSubview:_triangleView];
        
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

- (void)setXOffset:(CGFloat)xOffset
{
    _xOffset = xOffset;
    CGPoint center = self.triangleView.center;
    center.x = xOffset;
    
    [UIView animateWithDuration:0.25 animations:^{
        self.triangleView.center = center;
    }];
}

- (void)setDateText:(NSString *)dateText
{
    _dateText = dateText;
    
    self.dateLabel.text = _dateText;
    [self.dateLabel sizeToFit];
}

- (void)setViewCount:(NSUInteger)viewCount
{
    _viewCount = viewCount;
    
    self.numberFormatter.maximumFractionDigits = 0;
    NSString *count = [self.numberFormatter stringFromNumber:@(_viewCount)];
    
    self.viewsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Views: %@", @"Views graph label"), count];
    [self.viewsLabel sizeToFit];

    [self updateViewsPerVisitorsCalculation];
}

- (void)setVisitorsCount:(NSUInteger)visitorsCount
{
    _visitorsCount = visitorsCount;
    
    self.numberFormatter.maximumFractionDigits = 0;
    NSString *count = [self.numberFormatter stringFromNumber:@(_visitorsCount)];

    self.visitorsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Visitors: %@", @"Visitors graph label"), count];
    [self.visitorsLabel sizeToFit];
    
    [self updateViewsPerVisitorsCalculation];
}

- (void)updateViewsPerVisitorsCalculation
{
    CGFloat ratio = (CGFloat)_viewCount / (CGFloat)_visitorsCount;
    
    self.numberFormatter.maximumFractionDigits = 2;
    self.numberFormatter.minimumFractionDigits = 2;
    NSString *ratioString = [self.numberFormatter stringFromNumber:@(ratio)];
    
    self.viewsPerVisitorLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Views per Visitor: %@", @"Views per Visitor graph label"), ratioString];
    [self.viewsPerVisitorLabel sizeToFit];
}

@end

