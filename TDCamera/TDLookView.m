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

#define TDLookView_Alpha_Level_MAX 2

@interface TDLookView ()
@property (nonatomic) NSMutableArray* imageViews;

@property (nonatomic) NSInteger index;
// 0 - TDLookView_Alpha_Level_MAX
@property (nonatomic) NSInteger alphaLevel;

@end

@implementation TDLookView
-(instancetype)initWithImages:(NSArray*)images{
    self = [super init];
    if (self) {
        self.imageViews = [[NSMutableArray alloc] initWithCapacity:images.count * (TDLookView_Alpha_Level_MAX + 1)];
        [images bk_all:^BOOL(id obj) {
            for (int i = 0; i <= TDLookView_Alpha_Level_MAX; i++) {
                if (obj == images.lastObject && i > 0) {
                    break;
                }
                UIImageView* imageView = [[UIImageView alloc] initWithImage:obj];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.alpha = (TDLookView_Alpha_Level_MAX - i + 1.0)/(TDLookView_Alpha_Level_MAX + 1);
                [self addSubview:imageView];
                [self sendSubviewToBack:imageView];
                [self.imageViews addObject:imageView];
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@0);
                    make.left.equalTo(@0);
                    make.right.equalTo(@0);
                    make.bottom.equalTo(@0);
                }];
            }
            return YES;
        }];
        self.index = images.count/2;
        self.alphaLevel = 0;
        [self updateSelfWithNewIndex:self.index alphaLevel:self.alphaLevel];
        [[TDMotionManager sharedInstance] observeDeviceMotionUpdatesWithObj:self];
    }
    return self;
}
-(void)dealloc{
    [[TDMotionManager sharedInstance] unObserveDeviceMotionUpdatesWithObj:self];
}


-(void) tdLeftOverturnWithMotionManager:(id) manager{
    if (self.index == 0 && self.alphaLevel == 0) {
        return;
    }
    NSInteger newIndex;
    NSInteger newAlphaLevel;
    if (self.alphaLevel == 0) {
        newIndex = self.index - 1;
        newAlphaLevel = TDLookView_Alpha_Level_MAX;
    }else{
        newIndex = self.index;
        newAlphaLevel = self.alphaLevel - 1;
    }
    [self updateSelfWithNewIndex:newIndex alphaLevel:newAlphaLevel];
    self.index = newIndex;
    self.alphaLevel = newAlphaLevel;
}
-(void) tdRightOverturnWithMotionManager:(id) manager{
    if (self.index == (self.imageViews.count - 1) / (TDLookView_Alpha_Level_MAX + 1) && self.alphaLevel == 0) {
        return;
    }
    NSInteger newIndex;
    NSInteger newAlphaLevel;
    if (self.alphaLevel == TDLookView_Alpha_Level_MAX) {
        newIndex = self.index + 1;
        newAlphaLevel = 0;
    }else{
        newIndex = self.index;
        newAlphaLevel = self.alphaLevel + 1;
    }
    [self updateSelfWithNewIndex:newIndex alphaLevel:newAlphaLevel];
    self.index = newIndex;
    self.alphaLevel = newAlphaLevel;
}

-(void) updateSelfWithNewIndex:(NSInteger) index alphaLevel:(NSInteger) alphaLevel{
//    // 全部子view设置成透明
//    [self.imageViews[self.index] setAlpha:0];
//    if (self.index != self.imageViews.count - 1) {
//        [self.imageViews[self.index + 1] setAlpha:0];
//    }
//    // 设置透明度
//    [self.imageViews[index] setAlpha:(TDLookView_Alpha_Level_MAX - alphaLevel + 1)/(TDLookView_Alpha_Level_MAX + 1)];
//    if (index != self.imageViews.count - 1) {
//        [self.imageViews[index + 1] setAlpha:1];
//    }
    
    if (index != (self.imageViews.count - 1) / (TDLookView_Alpha_Level_MAX + 1)) {
        UIView* v1 = self.imageViews[(index + 1) * (TDLookView_Alpha_Level_MAX + 1)];
        [self bringSubviewToFront:v1];
    }
    UIView* v2 = self.imageViews[index * (TDLookView_Alpha_Level_MAX + 1) + alphaLevel];
    [self bringSubviewToFront:v2];
}

@end
