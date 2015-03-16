//
//  TDBrowseView.m
//  TDCameraSample
//
//  Created by WangYa on 15-3-9.
//  Copyright (c) 2015年 TD. All rights reserved.
//

#import "TDBrowseView.h"

@import CoreMotion;



@interface UIImage (ContentMode)
@end

@implementation UIImage (ContentMode)

- (void)drawInRect:(CGRect)rect contentMode:(UIViewContentMode)contentMode alpha:(CGFloat)alpha{
    BOOL clip = NO;
    CGRect originalRect = rect;
    if (self.size.width != rect.size.width || self.size.height != rect.size.height) {
        if (contentMode == UIViewContentModeLeft) {
            rect = CGRectMake(rect.origin.x,
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
            clip = YES;
        } else if (contentMode == UIViewContentModeRight) {
            rect = CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
            clip = YES;
        } else if (contentMode == UIViewContentModeTop) {
            rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y,
                              self.size.width, self.size.height);
            clip = YES;
        } else if (contentMode == UIViewContentModeBottom) {
            rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y + floor(rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            clip = YES;
        } else if (contentMode == UIViewContentModeCenter) {
            rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - self.size.width/2),
                              rect.origin.y + floor(rect.size.height/2 - self.size.height/2),
                              self.size.width, self.size.height);
        } else if (contentMode == UIViewContentModeBottomLeft) {
            rect = CGRectMake(rect.origin.x,
                              rect.origin.y + floor(rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            clip = YES;
        } else if (contentMode == UIViewContentModeBottomRight) {
            rect = CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y + (rect.size.height - self.size.height),
                              self.size.width, self.size.height);
            clip = YES;
        } else if (contentMode == UIViewContentModeTopLeft) {
            rect = CGRectMake(rect.origin.x,
                              rect.origin.y,
                              self.size.width, self.size.height);
            clip = YES;
        } else if (contentMode == UIViewContentModeTopRight) {
            rect = CGRectMake(rect.origin.x + (rect.size.width - self.size.width),
                              rect.origin.y,
                              self.size.width, self.size.height);
            clip = YES;
        } else if (contentMode == UIViewContentModeScaleAspectFit) {
            CGSize imageSize = CGSizeMake(self.size.width, self.size.height);
            if (imageSize.height < imageSize.width) {
                imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
                imageSize.height = rect.size.height;
            } else {
                imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
                imageSize.width = rect.size.width;
            }
            rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
                              rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
                              imageSize.width, imageSize.height);
        } else if (contentMode == UIViewContentModeScaleAspectFill) {
            CGSize imageSize = CGSizeMake(self.size.width, self.size.height);
            if (imageSize.height < imageSize.width) {
                imageSize.height = floor((imageSize.height/imageSize.width) * rect.size.width);
                imageSize.width = rect.size.width;
            } else {
                imageSize.width = floor((imageSize.width/imageSize.height) * rect.size.height);
                imageSize.height = rect.size.height;
            }
            rect = CGRectMake(rect.origin.x + floor(rect.size.width/2 - imageSize.width/2),
                              rect.origin.y + floor(rect.size.height/2 - imageSize.height/2),
                              imageSize.width, imageSize.height);
        }
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (clip) {
        CGContextSaveGState(context);
        CGContextAddRect(context, originalRect);
        CGContextClip(context);
    }
    
    //	[self drawInRect:rect];
    //TODO expose the operation and fraction values, in Mac only
#if TARGET_OS_IPHONE
    [self drawInRect:rect blendMode:kCGBlendModeNormal alpha:alpha];
#else
    [self drawInRect:NSRectFromCGRect(rect)
            fromRect:NSMakeRect(0, 0, self.size.width, self.size.height)
           operation:NSCompositeSourceOver
            fraction:1.0];
#endif
    
    if (clip) {
        CGContextRestoreGState(context);
    }
}


@end

@interface TDBrowseView (){
    NSArray* _images;
    NSNumber* _roll;
}
@end

@implementation TDBrowseView

static CMMotionManager* _TDMotionManager = nil;
static NSUInteger _TDBrowseViewCount = 0;

- (instancetype)initWithImages:(NSArray*)images
{
    self = [super init];
    if (self) {
        NSAssert(images.count >= 1, @"参数 异常");
        _images = images;
        
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            _TDMotionManager = [[CMMotionManager alloc] init];
            if (![_TDMotionManager isDeviceMotionAvailable]) {
                _TDMotionManager = nil;
                NSLog(@"设备不支持该功能");
            }
            _TDMotionManager.deviceMotionUpdateInterval = 0.1;
        });
        
        _TDBrowseViewCount ++;
        if (_TDBrowseViewCount > 0 && ![_TDMotionManager isDeviceMotionActive]) {
            [_TDMotionManager startDeviceMotionUpdates];
            NSLog(@"开启 陀螺仪 记录");
        }
        
        CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

- (void)render:(CADisplayLink*)displayLink {
#warning 渲染帧数过低
    [self setNeedsDisplay];
}

#define TD_ANGLE (double)M_PI_4
#define TD_ALPHA_COUNT 2

- (void)drawRect:(CGRect)rect {
    if (_roll == nil && _TDMotionManager.deviceMotion != nil) {
        _roll = [NSNumber numberWithDouble:_TDMotionManager.deviceMotion.attitude.roll];
    }
#warning 图片渲染顺序错误
    double roll = [_roll doubleValue];
    double roll_new = _TDMotionManager.deviceMotion.attitude.roll;
    double difference_roll = roll_new - roll;
    // 超出范围
    if (fabs(difference_roll) >= TD_ANGLE / 2) {
        UIImage* image = difference_roll > 0 ? [_images lastObject] : [_images firstObject];
        [image drawInRect:rect contentMode:self.contentMode alpha:1.0];
        _roll = [NSNumber numberWithDouble:difference_roll > 0 ? roll_new - TD_ANGLE / 2 : roll_new + TD_ANGLE / 2];
        return;
    }
    // 只有一张图片
    if (_images.count == 1) {
        UIImage* image = [_images lastObject];
        [image drawInRect:rect contentMode:self.contentMode alpha:1.0];
        return;
    }

    
    double roll_begin = TD_ANGLE / 2 + difference_roll;
    double roll_for_a_image = TD_ANGLE / (_images.count - 1);
    NSInteger index_image = roll_begin / roll_for_a_image;
    double roll_little = roll_begin - index_image * roll_for_a_image;

    UIImage* first_image = [_images objectAtIndex:index_image];
    [first_image drawInRect:rect contentMode:self.contentMode alpha:1.0];
    
    if (index_image + 1 <= _images.count - 1) {
        UIImage* second_image = [_images objectAtIndex:index_image+1];
        CGFloat alpha = ((NSInteger)(roll_little / roll_for_a_image) / (1.0 / TD_ALPHA_COUNT)) * (1.0 / TD_ALPHA_COUNT + 1);
        [second_image drawInRect:rect contentMode:self.contentMode alpha:alpha];
    }
}

-(void)dealloc{
#warning 内存不会释放
    //TODO: 内存不会释放
    _TDBrowseViewCount --;
    if (_TDBrowseViewCount <= 0 && [_TDMotionManager isDeviceMotionActive]) {
        [_TDMotionManager stopDeviceMotionUpdates];
        NSLog(@"停止 陀螺仪 记录");
    }
}

@end
