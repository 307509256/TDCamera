//
//  TDMotionManager.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-13.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "TDMotionManager.h"
#import "BlocksKit.h"

@import CoreMotion;

@interface TDMotionManager ()

@property (nonatomic) NSHashTable* observes;

@property (nonatomic) CMMotionManager *motionManager;

@property (nonatomic) double roll;

@end

@implementation TDMotionManager

+ (instancetype) sharedInstance{
    static id obj = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.observes = [NSHashTable weakObjectsHashTable];
        self.motionManager = [[CMMotionManager alloc] init];
        self.roll = 0;
    }
    return self;
}

-(void) observeDeviceMotionUpdatesWithObj:(id<TDMotionManagerDelegate>) obj{
    [self.observes addObject:obj];
    if (self.observes.count > 0) {
        [self startMonitoring];
    }
}

-(void) unObserveDeviceMotionUpdatesWithObj:(id<TDMotionManagerDelegate>) obj{
    [self.observes removeObject:obj];
    if (self.observes.count == 0) {
        [self stopMonitoring];
    }
}





#pragma mark - Core Motion

#define TD_ROLL_INTERVAL 0.006

- (void)startMonitoring
{
    if (![_motionManager isDeviceMotionActive] && [_motionManager isDeviceMotionAvailable] ) {
        [_motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            double roll = motion.attitude.roll;
            if (fabs(roll - self.roll) >= TD_ROLL_INTERVAL) {
                if (self.roll < roll) {
                    for (id<TDMotionManagerDelegate> object in self.observes.objectEnumerator) {
                        [object tdRightOverturnWithMotionManager:self];
                    }
                    self.roll += TD_ROLL_INTERVAL;
                }else if(self.roll >= roll){
                    for (id<TDMotionManagerDelegate> object in self.observes.objectEnumerator) {
                        [object tdLeftOverturnWithMotionManager:self];
                    }
                    self.roll -= TD_ROLL_INTERVAL;
                }
            }
        }];
        NSLog(@"TDMotionManager startMonitoring");
    } else {
        NSLog(@"TDMotionManager There is not available gyro.");
    }
}

- (void)stopMonitoring
{
    NSLog(@"TDMotionManager stopMonitoring");
    [_motionManager stopDeviceMotionUpdates];
}

@end
