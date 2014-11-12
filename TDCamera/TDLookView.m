//
//  TDLookView.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-12.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "TDLookView.h"
#import "BlocksKit.h"
#import "Masonry.h"
@import CoreMotion;

@interface TDLookView ()
@property (nonatomic) NSArray* images;
@property (nonatomic, strong) CMMotionManager *motionManager;
@property (nonatomic) NSInteger index;
@end

@implementation TDLookView
-(instancetype)initWithImages:(NSArray*)images{
    self = [super init];
    if (self) {
        self.images = images;
        [self.images bk_all:^BOOL(id obj) {
            UIImageView* imageView = [[UIImageView alloc] initWithImage:obj];
            [self addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.left.equalTo(@0);
                make.right.equalTo(@0);
                make.bottom.equalTo(@0);
            }];
            return YES;
        }];
        self.index = 0;
        [self startMonitoring];
    }
    return self;
}
-(void)dealloc{
#warning 检测是否调用此方法
    [self stopMonitoring];
}

static NSTimeInterval td_time_last;
#define TD_TIME_INTERVAL 0.5f
-(void)updateUI:(BOOL)up{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    if (td_time_last == 0) {
        td_time_last = now;
        up?self.index++:self.index--;
        [self bringSubviewToFront:[self subviews][self.index]];
    }else{
        if (now - td_time_last > TD_TIME_INTERVAL) {
            td_time_last = now;
            up?self.index++:self.index--;
            [self bringSubviewToFront:[self subviews][self.index]];
        }
    }
    
}


#pragma mark - Core Motion

- (void)startMonitoring
{
    if (!_motionManager) {
        _motionManager = [[CMMotionManager alloc] init];
        _motionManager.gyroUpdateInterval = 0.01;
    }
    
    if (![_motionManager isGyroActive] && [_motionManager isGyroAvailable] ) {
        [_motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue]
                                    withHandler:^(CMGyroData *gyroData, NSError *error) {
                                        CGFloat rotationRate = gyroData.rotationRate.y;
                                        if (fabs(rotationRate) >= 0.1) {
                                            if (rotationRate > 0 && self.index + 1< self.images.count) {
                                                [self updateUI:YES];
                                            }else if(rotationRate < 0 && self.index > 0){
                                                [self updateUI:NO];
                                            }
                                        }
                                    }];
    } else {
        NSLog(@"There is not available gyro.");
    }
}

- (void)stopMonitoring
{
    [_motionManager stopGyroUpdates];
}

@end
