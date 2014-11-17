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
    TDLookView* lookview = [[TDLookView alloc] initWithImages:images];
    [next.view addSubview:lookview];
    [lookview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@84);
        make.left.equalTo(@20);
        make.right.equalTo(@-20);
        make.bottom.equalTo(@-20);
    }];
    
    
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
