//
//  TDLookView.h
//  TDCameraSample
//
//  Created by WangYa on 14-11-12.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TDMotionManager.h"

@interface TDLookView : UIView<TDMotionManagerDelegate>
-(instancetype)initWithImages:(NSArray*)images;
@end
