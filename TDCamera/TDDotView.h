//
//  TDDotView.h
//  TDCameraSample
//
//  Created by WangYa on 14-11-11.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TDDotView : UIView
@property (nonatomic,readonly) NSInteger count;
@property (nonatomic) NSInteger index;

- (instancetype)initWithDotCount:(NSInteger)count;

@end
