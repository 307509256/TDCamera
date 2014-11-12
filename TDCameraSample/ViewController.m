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
    [self presentViewController:[[TDCameraViewController alloc]initWithDelegate:self] animated:YES completion:nil];
}

#pragma mark - TDCameraViewControllerDelegate

- (void) camera:(id)cameraViewController didFinishWithImageArray:(NSArray *)images withMetadata:(NSDictionary *)metadata{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    UIViewController* next = [[UIViewController alloc] init];
    TDLookView* lookview = [[TDLookView alloc] initWithImages:images];
    [next.view addSubview:lookview];
    [lookview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(next.view.mas_centerX);
        make.centerY.equalTo(next.view.mas_centerY);
        make.width.equalTo(next.view.mas_width).multipliedBy(0.3);
        make.height.equalTo(next.view.mas_height).multipliedBy(0.3);
    }];
    [self.navigationController pushViewController:next animated:YES];
}
- (void) dismissCamera:(id)cameraViewController{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
