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
        } else if (contentMode == UIViewContentModeScaleAspectFill) {
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
        } else if (contentMode == UIViewContentModeScaleAspectFit) {
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
    double _roll;
}
@end

@implementation TDBrowseView

static CMMotionManager* _TDMotionManager = nil;
static NSUInteger _TDBrowseViewCount = 0;

- (instancetype)initWithImages:(NSArray*)images
{
    self = [super init];
    if (self) {
        _images = images;
        
        static dispatch_once_t token;
        dispatch_once(&token, ^{
            _TDMotionManager = [[CMMotionManager alloc] init];
            if (![_TDMotionManager isDeviceMotionAvailable]) {
                _TDMotionManager = nil;
                NSLog(@"设备不支持该功能");
            }
            _TDMotionManager.deviceMotionUpdateInterval = 1.0/60;
        });
        
        _TDBrowseViewCount ++;
        if (_TDBrowseViewCount > 0 && ![_TDMotionManager isDeviceMotionActive]) {
            [_TDMotionManager startDeviceMotionUpdates];
            NSLog(@"开启 陀螺仪 记录");
        }
        
        _roll = _TDMotionManager.deviceMotion.attitude.roll;
        
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSAssert(NO, @"请使用 initWithImages 初始化");
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        NSAssert(NO, @"请使用 initWithImages 初始化");
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSAssert(NO, @"请使用 initWithImages 初始化");
    }
    return self;
}

static CFAbsoluteTime log_begin = 0;
static NSInteger log_count = 0;

- (void)drawRect:(CGRect)rect {
    double roll_new = _TDMotionManager.deviceMotion.attitude.roll;
    double difference_roll = roll_new - _roll;
    if (fabs(difference_roll) >= M_PI_4 / 2) {
        UIImage* image = difference_roll > 0 ? [_images lastObject] : [_images firstObject];
        [image drawInRect:rect contentMode:self.contentMode alpha:1.0];
        _roll = roll_new;
        return;
    }
    
    
    
    double roll_for_a_image = M_PI_4 / _images.count;
    NSInteger index_image = difference_roll / roll_for_a_image;
    double roll_little = difference_roll - index_image * roll_for_a_image;
    
    
    
    
    
    
    // log
    log_count ++;
    if (log_begin == 0) {
        log_begin = CFAbsoluteTimeGetCurrent();
    }else{
        CFAbsoluteTime log_end = CFAbsoluteTimeGetCurrent();
        if (log_end - log_begin >= 1.0) {
            NSLog(@"帧数 = %0.f",log_count / (log_end - log_begin));
            log_count = 0;
            log_begin = log_end;
        }
    }
}

-(void)dealloc{
    _TDBrowseViewCount --;
    if (_TDBrowseViewCount <= 0 && [_TDMotionManager isDeviceMotionActive]) {
        [_TDMotionManager stopDeviceMotionUpdates];
        NSLog(@"停止 陀螺仪 记录");
    }
}

@end
