//
//  TDCameraView.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-6.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "TDCameraView.h"
#import "BlocksKit+UIKit.h"

@interface TDCameraView ()
@property (nonatomic) CALayer *focusExposeBox;
@end

@implementation TDCameraView

+ (id) initWithFrame:(CGRect)frame
{
    TDCameraView* cameraView = [super initWithFrame:frame];
    __weak TDCameraView* wCameraView = cameraView;
    
    // 单击对焦调整曝光效果 初始化
    cameraView.focusExposeBox = [[CALayer alloc] init];
    [cameraView.focusExposeBox setCornerRadius:45.0f];
    [cameraView.focusExposeBox setBounds:CGRectMake(0.0f, 0.0f, 90, 90)];
    [cameraView.focusExposeBox setBorderWidth:5.f];
    [cameraView.focusExposeBox setBorderColor:[[UIColor whiteColor] CGColor]];
    [cameraView.focusExposeBox setOpacity:0];
    
    // 单击对焦调整曝光效果
    [cameraView.previewLayer addSublayer:cameraView.focusExposeBox];
    
    // 对焦，曝光手势
    UITapGestureRecognizer *singleTap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        // 对焦
        if ([wCameraView.delegate respondsToSelector:@selector(cameraView:focusAtPoint:)] && CGRectContainsPoint(wCameraView.previewLayer.frame, location)) {
            [wCameraView.delegate cameraView:wCameraView focusAtPoint:(CGPoint){ location.x, location.y - CGRectGetMinY(wCameraView.previewLayer.frame)}];
        }
        // 曝光
        if ([wCameraView.delegate respondsToSelector:@selector(cameraView:exposeAtPoint:)] && CGRectContainsPoint(wCameraView.previewLayer.frame, location)) {
            [wCameraView.delegate cameraView:wCameraView exposeAtPoint:(CGPoint){ location.x, location.y - CGRectGetMinY(wCameraView.previewLayer.frame)}];
        }
        // 绘制ui效果
        [wCameraView draw:wCameraView.focusExposeBox atPointOfInterest:location andRemove:YES];
    }];
    [cameraView addGestureRecognizer:singleTap];
    
    return cameraView;
}

- (void) drawFocusBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [super draw:self.focusExposeBox atPointOfInterest:point andRemove:remove];
}

- (void) drawExposeBoxAtPointOfInterest:(CGPoint)point andRemove:(BOOL)remove
{
    [super draw:self.focusExposeBox atPointOfInterest:point andRemove:remove];
}
@end
