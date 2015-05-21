#import "StatsGaugeView.h"
#import "WPStyleGuide+Stats.h"

@implementation StatsGaugeView


- (instancetype)init
{
    self = [super init];
    if (self) {
        _percentageFilled = 0.0f;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    UIBezierPath *backgroundPath = [UIBezierPath bezierPath];
    backgroundPath.lineWidth = 8.0f;
    backgroundPath.lineCapStyle = kCGLineCapRound;
    [backgroundPath addArcWithCenter:center
                          radius:(CGRectGetWidth(rect) / 2.0 - 4.0)
                      startAngle:(0.75 * M_PI)
                        endAngle:(0.25 * M_PI)
                       clockwise:YES];
    
    [[WPStyleGuide greyLighten30] setStroke];
    [backgroundPath stroke];
    
    UIBezierPath *completedPath = [UIBezierPath bezierPath];
    completedPath.lineWidth = 8.0f;
    completedPath.lineCapStyle = kCGLineCapRound;
    [completedPath addArcWithCenter:center
                          radius:(CGRectGetWidth(rect) / 2.0 - 4.0)
                      startAngle:(0.75 * M_PI)
                        endAngle:(1.5 * M_PI * self.percentageFilled) + (0.75 * M_PI)
                       clockwise:YES];
    
    [[WPStyleGuide mediumBlue] setStroke];
    [completedPath stroke];
    
}

-(void)setPercentageFilled:(CGFloat)percentageFilled
{
    if (percentageFilled != _percentageFilled) {
        _percentageFilled = percentageFilled;
        [self setNeedsDisplay];
    }
}

@end
