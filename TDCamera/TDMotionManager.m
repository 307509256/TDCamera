//
//  TDMotionManager.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-13.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "TDMotionManager.h"

@implementation TDMotionManager

+ (instancetype) sharedInstance{
    static id obj = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        obj = [[self alloc] init];
    });
    return obj;
}

-(void) observeDeviceMotionUpdatesWithObj:(id) obj{
    
    
}

-(void) unObserveDeviceMotionUpdatesWithObj:(id) obj{
    
    
}

@end
