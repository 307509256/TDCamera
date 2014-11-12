//
//  TDCameraViewController.h
//  TDCameraSample
//
//  Created by WangYa on 14-11-6.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "DBCameraViewController.h"

@protocol TDCameraViewControllerDelegate <NSObject>

@optional
- (void) camera:(id)cameraViewController didFinishWithImageArray:(NSArray *)images withMetadata:(NSDictionary *)metadata;
- (void) dismissCamera:(id)cameraViewController;

@end

@interface TDCameraViewController : DBCameraViewController
-(instancetype)initWithDelegate:(id<TDCameraViewControllerDelegate>)delegate;
@end
