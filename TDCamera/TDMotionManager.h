//
//  TDMotionManager.h
//  TDCameraSample
//
//  Created by WangYa on 14-11-13.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TDMotionManagerDelegate <NSObject>

@optional
-(void) tdLeftOverturnWithMotionManager:(id) manager;
-(void) tdRightOverturnWithMotionManager:(id) manager;
@end

@interface TDMotionManager : NSObject

+ (instancetype)sharedInstance;

-(void) observeDeviceMotionUpdatesWithObj:(id<TDMotionManagerDelegate>) obj;

-(void) unObserveDeviceMotionUpdatesWithObj:(id<TDMotionManagerDelegate>) obj;

@end
