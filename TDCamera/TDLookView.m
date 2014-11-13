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


@interface TDLookView ()
@property (nonatomic) NSArray* images;
@property (nonatomic) NSMutableArray* imageViews;

@property (nonatomic) NSInteger index;

@end

@implementation TDLookView
-(instancetype)initWithImages:(NSArray*)images{
    self = [super init];
    if (self) {
        self.images = images;
        self.imageViews = [[NSMutableArray alloc] initWithCapacity:self.images.count];
        [self.images bk_all:^BOOL(id obj) {
            UIImageView* imageView = [[UIImageView alloc] initWithImage:obj];
            [self addSubview:imageView];
            [self.imageViews addObject:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(@0);
                make.left.equalTo(@0);
                make.right.equalTo(@0);
                make.bottom.equalTo(@0);
            }];
            return YES;
        }];
        self.index = 0;
        [self bringSubviewToFront:self.imageViews[self.index]];
        [[TDMotionManager sharedInstance] observeDeviceMotionUpdatesWithObj:self];
    }
    return self;
}
-(void)dealloc{
    [[TDMotionManager sharedInstance] unObserveDeviceMotionUpdatesWithObj:self];
}


-(void) tdLeftOverturnWithMotionManager:(id) manager{
    if (self.index > 0) {
        self.index--;
        [self bringSubviewToFront:self.imageViews[self.index]];
    }
}
-(void) tdRightOverturnWithMotionManager:(id) manager{
    if (self.index + 1< self.images.count) {
        self.index++;
        [self bringSubviewToFront:self.imageViews[self.index]];
    }
}

@end
