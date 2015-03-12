//
//  ViewController.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-6.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "ViewController.h"
#import "TDCameraViewController.h"
#import "TDLookView.h"
#import "Masonry.h"
#import "NYXImagesKit.h"
#import "TDBrowseView.h"

@interface ViewController ()<TDCameraViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)takePhoto:(UIButton *)sender {
    [self.navigationController pushViewController:[[TDCameraViewController alloc]initWithDelegate:self] animated:YES];
}

#pragma mark - TDCameraViewControllerDelegate

- (void) camera:(id)cameraViewController didFinishWithImageArray:(NSArray *)images withMetadata:(NSDictionary *)metadata{
    UIViewController* next = [[UIViewController alloc] init];
    // 图片压缩
    NSMutableArray* imagesNormal = [NSMutableArray arrayWithCapacity:images.count];
    for (UIImage* img in images) {
        // 裁剪成正放心
        UIImage* img_temp = [UIImage imageWithCGImage:img.CGImage scale:1.0 orientation:UIImageOrientationUp];
        CGFloat sideL = img_temp.size.width < img_temp.size.height ? img_temp.size.width : img_temp.size.height;
        img_temp = [img_temp cropToSize:CGSizeMake(sideL, sideL) usingMode:NYXCropModeCenter];
        
        // 旋转 90度
        img_temp = [UIImage imageWithCGImage:img_temp.CGImage scale:1.0 orientation:UIImageOrientationRight];
        
        // 缩放像素
        sideL = sideL < [UIScreen mainScreen].bounds.size.width ? sideL : [UIScreen mainScreen].bounds.size.width;
        img_temp = [img_temp scaleToFillSize:CGSizeMake(sideL, sideL)];
        
        
        [imagesNormal addObject:img_temp];
    }
    
    TDLookView* lookview = [[TDLookView alloc] initWithImages:imagesNormal];
    [next.view addSubview:lookview];
    [lookview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@84);
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.bottom.equalTo(@-20);
    }];
    
//    TDBrowseView* lookview = [[TDBrowseView alloc] initWithImages:imagesNormal];
//    lookview.contentMode = UIViewContentModeScaleAspectFit;
//    [next.view addSubview:lookview];
//    [lookview mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(@84);
//        make.left.equalTo(@20);
//        make.right.equalTo(@-20);
//        make.bottom.equalTo(@-20);
//    }];
    
    
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionReveal; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromBottom; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    
    [self.navigationController pushViewController:next animated:NO];
}
- (void) dismissCamera:(id)cameraViewController{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
