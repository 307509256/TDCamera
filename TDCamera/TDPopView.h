//
//  TDPopView.h
//  TDCameraSample
//
//  Created by WangYa on 14-11-26.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TDPopView;

@protocol TDPopViewDelegate <NSObject>

@optional
-(void) popView:(TDPopView*) popView ghost:(BOOL) isGhost;

@end

@interface TDPopView : UIView
@property (weak) id<TDPopViewDelegate> delegate;
- (instancetype)initWithDelegate:(id<TDPopViewDelegate>)delegate;

@property (nonatomic)BOOL isGhost;

@end
