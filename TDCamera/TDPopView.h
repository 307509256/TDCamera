//
//  TDPopView.h
//  TDCameraSample
//
//  Created by WangYa on 14-11-26.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TD_CAMERA_QUALITY) {
    TD_CAMERA_QUALITY_NORMAL,
    TD_CAMERA_QUALITY_HIGH
};

typedef NS_ENUM(NSInteger, TD_CAMERA_FPS) {
    TD_CAMERA_FPS_1,
    TD_CAMERA_FPS_2,
    TD_CAMERA_FPS_4,
    TD_CAMERA_FPS_5,
    TD_CAMERA_FPS_7,
    TD_CAMERA_FPS_10,
    TD_CAMERA_FPS_15
};

@class TDPopView;

@protocol TDPopViewDelegate <NSObject>

@optional
-(void) popView:(TDPopView*) popView ghost:(BOOL) isGhost;
-(void) popView:(TDPopView*) popView front:(BOOL) isFront;
-(void) popView:(TDPopView*) popView hasGrid:(BOOL) hasGrid;
-(void) popView:(TDPopView*) popView quality:(TD_CAMERA_QUALITY) quality;
-(void) popView:(TDPopView*) popView fps:(TD_CAMERA_FPS) fps;
-(void) popViewReset:(TDPopView*) popView;

@end

@interface TDPopView : UIView
@property (weak) id<TDPopViewDelegate> delegate;
- (instancetype)initWithDelegate:(id<TDPopViewDelegate>)delegate;

@property (nonatomic)BOOL isGhost;
@property (nonatomic)BOOL isFront;
@property (nonatomic)BOOL hasGrid;
@property (nonatomic)TD_CAMERA_QUALITY quality;
@property (nonatomic)TD_CAMERA_FPS fps;

@end
