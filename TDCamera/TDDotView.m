//
//  TDDotView.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-11.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "TDDotView.h"

@implementation TDDotView
- (instancetype)initWithDotCount:(NSInteger)count{
    self = [super init];
    if (self) {
        _count = count;
    }
    return self;
}

- (void) setIndex:(NSInteger)index{
    _index = index;
    [self setNeedsDisplay];
}

// 点的直径
#define TD_DOT_DIA 4.f
#define TD_DOT_DIA_BIG 6.f

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGFloat dia = TD_DOT_DIA_BIG;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0 green:204/255.0 blue:1 alpha:1] CGColor]));
    
    for (int i = 0; i < self.count; i++) {

        if (i == self.index) {
            CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:1 green:1 blue:1 alpha:1] CGColor]));
            dia = TD_DOT_DIA;
        }
        
        CGRect docFrame = CGRectMake(rect.size.width/self.count*i + rect.size.width/self.count/2 - dia/2, rect.size.height/2 - dia/2, dia, dia);
        CGContextAddEllipseInRect(ctx, docFrame);
        CGContextFillPath(ctx);
    }
}
@end
