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
@property (nonatomic) NSMutableArray* imageViews;
@property (nonatomic) CMMotionManager *motionManager;
@property (nonatomic) NSInteger index;
@property (nonatomic) double roll;
@end

@implementation TDLookView
-(instancetype)initWithImages:(NSArray*)images{
    self = [super init];
    if (self) {
        self.images = images;
        self.imageViews = [[NSMutableArray alloc] initWithCapacity:self.images.count];
        [self.images bk_all:^BOOL(id obj) {
            UIImageView* imageView = [[UIImageView alloc] initWithImage:obj];
            [self addSubview:imageView];
            [self.imageViews addObject:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.left.equalTo(@0);
                make.right.equalTo(@0);
                make.bottom.equalTo(@0);
            }];
            return YES;
        }];
        self.index = 0;
        [self bringSubviewToFront:self.imageViews[self.index]];
        [self startMonitoring];
    }
    return self;
}
-(void)dealloc{
#warning 检测是否调用此方法
    [self stopMonitoring];
}


#pragma mark - Core Motion

#define TD_ROLL_INTERVAL 0.014

- (void)startMonitoring
{
    if (!_motionManager) {
//        _motionManager = [[CMMotionManager alloc] init];
    }
    if (![_motionManager isDeviceMotionActive] && [_motionManager isDeviceMotionAvailable] ) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            double roll = motion.attitude.roll;
            if (fabs(roll - self.roll) >= TD_ROLL_INTERVAL) {
                if (self.roll < roll) {
                    if (self.index + 1< self.images.count) {
                        self.index++;
                        [self bringSubviewToFront:self.imageViews[self.index]];
                        NSLog(@"%ld",self.index);
                    }
                    self.roll += TD_ROLL_INTERVAL;
                }else if(self.roll >= roll){
                    if (self.index > 0) {
                        self.index--;
                        [self bringSubviewToFront:self.imageViews[self.index]];
                        NSLog(@"%ld",self.index);
                    }
                    self.roll -= TD_ROLL_INTERVAL;
                }
            }
        }];
    } else {
        NSLog(@"There is not available gyro.");
    }
}

- (void)stopMonitoring
{
    [_motionManager stopDeviceMotionUpdates];
}

@end
