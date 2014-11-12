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
#define TD_DOT_DIA 7.f

-(void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0 green:204/255.0 blue:1 alpha:1] CGColor]));
    
    for (int i = 0; i < self.count; i++) {

        if (i == self.index) {
            CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:190/255.0 green:190/255.0 blue:190/255.0 alpha:1] CGColor]));
        }
        
        CGRect docFrame = CGRectMake(rect.size.width/self.count*i + rect.size.width/self.count/2 - TD_DOT_DIA/2, rect.size.height/2 - TD_DOT_DIA/2, TD_DOT_DIA, TD_DOT_DIA);
        CGContextAddEllipseInRect(ctx, docFrame);
        CGContextFillPath(ctx);
    }
}
@end
