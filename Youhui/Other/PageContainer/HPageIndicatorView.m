//
//  HPageIndicatorView.m
//  Youhui
//
//  Created by xujunwu on 15/2/6.
//  Copyright (c) 2015年 ___xujun___. All rights reserved.
//

#import "HPageIndicatorView.h"

@implementation HPageIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        _color = [UIColor blackColor];
    }
    return self;
}

#pragma mark - Public

- (void)setColor:(UIColor *)color
{
    if (![_color isEqual:color]) {
        _color = color;
        [self setNeedsDisplay];
    }
}

#pragma mark - Private

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, rect);
    
    CGContextBeginPath(context);
    CGContextMoveToPoint   (context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(context, CGRectGetMidX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextClosePath(context);
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillPath(context);
}

@end
