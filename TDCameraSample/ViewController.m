//
//  ViewController.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-6.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "ViewController.h"
#import "TDCameraViewController.h"

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
    
}
- (void) dismissCamera:(id)cameraViewController{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
