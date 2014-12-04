//
//  TDPopView.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-26.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "TDPopView.h"
#import "Masonry.h"
#import "BlocksKit+UIKit.h"

@interface TDPopView ()

@end

@implementation TDPopView

- (instancetype)initWithDelegate:(id<TDPopViewDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        CGRect frame = [[UIScreen mainScreen] bounds];
        frame.size.width = 260;
        frame.size.height = 120;
        __weak typeof(self) wself = self;
        // 弹框内容
        self.frame = frame;
        // 幽灵按钮
        UIButton* ghostButton = [[UIButton alloc] init];
        [self addSubview:ghostButton];
        [ghostButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
        }];
        UIImageView* ghostImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pop_ghost"]];
        [ghostButton addSubview:ghostImageView];
        [ghostImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0).offset(4);
            make.centerY.equalTo(@0);
            make.width.equalTo(@16);
            make.height.equalTo(@16);
        }];
        UILabel* ghostLabel = [[UILabel alloc] init];
        ghostLabel.textColor = [UIColor whiteColor];
        ghostLabel.text = @"阴影";
        [ghostButton addSubview:ghostLabel];
        [ghostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ghostImageView.mas_right).offset(8);
            make.centerY.equalTo(@0);
        }];
        [ghostButton bk_addEventHandler:^(id sender) {
            wself.isGhost = !wself.isGhost;
            if (wself.delegate && [wself.delegate respondsToSelector:@selector(popView:ghost:)]) {
                [wself.delegate popView:wself ghost:wself.isGhost];
            }
        } forControlEvents:UIControlEventTouchUpInside];
        // 前后相机转换按钮
        UIButton* frontBackButton = [[UIButton alloc] init];
        [self addSubview:frontBackButton];
        [frontBackButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(ghostButton.mas_bottom);
            make.width.equalTo(ghostButton.mas_width);
            make.height.equalTo(ghostButton.mas_height);
        }];
        UIImageView* frontBackImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pop_frontBack"]];
        [frontBackButton addSubview:frontBackImageView];
        [frontBackImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0).offset(4);
            make.centerY.equalTo(@0);
            make.width.equalTo(@16);
            make.height.equalTo(@16);
        }];
        UILabel* frontBackLabel = [[UILabel alloc] init];
        frontBackLabel.textColor = [UIColor whiteColor];
        frontBackLabel.text = @"前后";
        [frontBackButton addSubview:frontBackLabel];
        [frontBackLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(frontBackImageView.mas_right).offset(8);
            make.centerY.equalTo(@0);
        }];
        // 网格按钮
        UIButton* gridButton = [[UIButton alloc] init];
        [self addSubview:gridButton];
        [gridButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(frontBackButton.mas_bottom);
            make.width.equalTo(ghostButton.mas_width);
            make.height.equalTo(ghostButton.mas_height);
            make.bottom.equalTo(@0);
        }];
        UIImageView* gridImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pop_grid"]];
        [gridButton addSubview:gridImageView];
        [gridImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0).offset(4);
            make.centerY.equalTo(@0);
            make.width.equalTo(@16);
            make.height.equalTo(@16);
        }];
        UILabel* gridLabel = [[UILabel alloc] init];
        gridLabel.textColor = [UIColor whiteColor];
        gridLabel.text = @"网格";
        [gridButton addSubview:gridLabel];
        [gridLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(gridImageView.mas_right).offset(8);
            make.centerY.equalTo(@0);
        }];
        // 画质按钮
        UIButton* qualityButton = [[UIButton alloc] init];
        [self addSubview:qualityButton];
        [qualityButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.right.equalTo(@0);
            make.width.equalTo(ghostButton.mas_width).offset(60);
            make.bottom.equalTo(ghostButton.mas_bottom);
            make.left.equalTo(ghostButton.mas_right);
        }];
        UIImageView* qualityImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pop_quality"]];
        [qualityButton addSubview:qualityImageView];
        [qualityImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0).offset(4);
            make.centerY.equalTo(ghostImageView.mas_centerY);
            make.width.equalTo(@16);
            make.height.equalTo(@16);
        }];
        UILabel* qualityLabel = [[UILabel alloc] init];
        qualityLabel.textColor = [UIColor whiteColor];
        qualityLabel.text = @"画质";
        [qualityButton addSubview:qualityLabel];
        [qualityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(qualityImageView.mas_right).offset(8);
            make.centerY.equalTo(ghostImageView.mas_centerY);
        }];
        UILabel* qualityTitleLabel = [[UILabel alloc] init];
        qualityTitleLabel.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        qualityTitleLabel.font = [UIFont systemFontOfSize:10];
        qualityTitleLabel.text = @"高清";
        [qualityButton addSubview:qualityTitleLabel];
        [qualityTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(qualityLabel.mas_right).offset(20);
            make.bottom.equalTo(qualityLabel.mas_bottom);
        }];
        // 帧按钮 fps
        UIButton* fpsButton = [[UIButton alloc] init];
        [self addSubview:fpsButton];
        [fpsButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@0);
            make.top.equalTo(qualityButton.mas_bottom);
            make.width.equalTo(qualityButton.mas_width);
            make.height.equalTo(qualityButton.mas_height);
        }];
        UIImageView* fpsImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pop_fps"]];
        [fpsButton addSubview:fpsImageView];
        [fpsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0).offset(4);
            make.centerY.equalTo(@0);
            make.width.equalTo(@16);
            make.height.equalTo(@16);
        }];
        UILabel* fpsLabel = [[UILabel alloc] init];
        fpsLabel.textColor = [UIColor whiteColor];
        fpsLabel.text = @"连拍帧数";
        [fpsButton addSubview:fpsLabel];
        [fpsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(fpsImageView.mas_right).offset(8);
            make.centerY.equalTo(@0);
        }];
        UILabel* fpsTitleLabel = [[UILabel alloc] init];
        fpsTitleLabel.textColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1];
        fpsTitleLabel.font = [UIFont systemFontOfSize:10];
        fpsTitleLabel.text = @"15 fps";
        [fpsButton addSubview:fpsTitleLabel];
        [fpsTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(fpsLabel.mas_right).offset(20);
            make.bottom.equalTo(fpsLabel.mas_bottom);
        }];
        // 重置按钮
        UIButton* resetButton = [[UIButton alloc] init];
        [self addSubview:resetButton];
        [resetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@0);
            make.width.equalTo(qualityButton.mas_width);
            make.top.equalTo(fpsButton.mas_bottom);
            make.bottom.equalTo(@0);
        }];
        UIImageView* resetImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pop_reset"]];
        [resetButton addSubview:resetImageView];
        [resetImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0).offset(4);
            make.centerY.equalTo(@0);
            make.width.equalTo(@16);
            make.height.equalTo(@16);
        }];
        UILabel* resetLabel = [[UILabel alloc] init];
        resetLabel.textColor = [UIColor whiteColor];
        resetLabel.text = @"重置";
        [resetButton addSubview:resetLabel];
        [resetLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(resetImageView.mas_right).offset(8);
            make.centerY.equalTo(@0);
        }];
        
        // line
        UIView* Line1 = [[UIView alloc] init];
        Line1.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        [self addSubview:Line1];
        [Line1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(ghostButton.mas_bottom);
            make.height.equalTo(@1);
        }];
        UIView* Line2 = [[UIView alloc] init];
        Line2.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        [self addSubview:Line2];
        [Line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(frontBackButton.mas_bottom);
            make.height.equalTo(@1);
        }];
        UIView* Line3 = [[UIView alloc] init];
        Line3.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.3];
        [self addSubview:Line3];
        [Line3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.right.equalTo(ghostButton.mas_right);
            make.bottom.equalTo(@0);
            make.width.equalTo(@1);
        }];
    }
    return self;
}

-(void)setIsGhost:(BOOL)isGhost{
    _isGhost = isGhost;
    // 修改ui
    
}

@end
