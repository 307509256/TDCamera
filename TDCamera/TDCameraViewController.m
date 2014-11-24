//
//  TDCameraViewController.m
//  TDCameraSample
//
//  Created by WangYa on 14-11-6.
//  Copyright (c) 2014年 TD. All rights reserved.
//

#import "TDCameraViewController.h"
#import "TDCameraView.h"
#import "Masonry.h"
#import "BlocksKit+UIKit.h"
#import "TDDotView.h"
//#import "NYXImagesKit.h"
#import "DBCameraManager.h"

// 相机视图高度占屏幕的比率
#define TD_CAMERA_VIEW_HEIGHT_MULTIPLY 0.7
// 最多拍摄照片数量
#define TD_IMAGE_COUNT 24

@interface TDCameraViewController ()<DBCameraViewControllerDelegate>
@property (weak,nonatomic) id<TDCameraViewControllerDelegate> delegate_td;
@property (nonatomic) NSMutableArray* images;

@property (weak,nonatomic) TDDotView* dotView;

// 状态
@property BOOL statusBarHidden;
@property BOOL idleTimerDisabled;
@property BOOL navigationBarHidden;

@end

@implementation TDCameraViewController

-(instancetype)initWithDelegate:(id<TDCameraViewControllerDelegate>)delegate{
    CGSize size = [[UIScreen mainScreen] bounds].size;
    TDCameraView* cameraView = [TDCameraView initWithFrame:CGRectMake(0, 0, size.width, size.height*TD_CAMERA_VIEW_HEIGHT_MULTIPLY)];
    self = [super initWithDelegate:self cameraView:cameraView];
    if (self) {
        self.delegate_td = delegate;
        self.images = [NSMutableArray arrayWithCapacity:TD_IMAGE_COUNT];
        self.useCameraSegue = NO;
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 设置manager
    self.cameraManager.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
    
    // block weak
    __weak TDCameraViewController *wself = self;
    
    // 上部导航栏
    UIView* topBar = [[UIView alloc] init];
    [self.view addSubview:topBar];
    topBar.backgroundColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:0.5];
    [topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@0);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@44);
    }];
    // 取消按钮
    UIButton* cancelButton = [[UIButton alloc] init];
    [topBar addSubview:cancelButton];
    [cancelButton setImage:[UIImage imageNamed:@"cancel"] forState:UIControlStateNormal];
    [cancelButton bk_whenTapped:^{
        TDCameraViewController *sself = wself;
        if (sself) {
            [sself dismissCamera:sself];
        }else{
            NSLog(@"<self> dealloc before we could run this code.");
        }
    }];
    [cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topBar.mas_centerY);
        make.left.equalTo(@14);
    }];
    // 下一步按钮
    UIButton* nextButton = [[UIButton alloc] init];
    [topBar addSubview:nextButton];
    [nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    [nextButton bk_whenTapped:^{
        TDCameraViewController *sself = wself;
        if (sself) {
            if (sself.images.count == 0) {
                return;
            }
            if ([sself.delegate_td respondsToSelector:@selector(camera:didFinishWithImageArray:withMetadata:)] )
                [sself.delegate_td camera:sself didFinishWithImageArray:sself.images withMetadata:nil];
        }else{
            NSLog(@"<self> dealloc before we could run this code.");
        }
    }];
    [nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(topBar.mas_centerY);
        make.right.equalTo(@-14);
    }];
    // 下部设置,显示图片数量,撤销 栏
    UIView* bottomBar = [[UIView alloc] init];
    [self.view addSubview:bottomBar];
    bottomBar.backgroundColor = [UIColor colorWithRed:51/255.f green:51/255.f blue:51/255.f alpha:0.5];
    [bottomBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@([[UIScreen mainScreen] bounds].size.height * TD_CAMERA_VIEW_HEIGHT_MULTIPLY - 44));
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@44);
    }];
    // 设置按钮
    UIButton* settingButton = [[UIButton alloc] init];
    [bottomBar addSubview:settingButton];
    UIImage* settingImage = [UIImage imageNamed:@"setting"];
    [settingButton setImage:settingImage forState:UIControlStateNormal];
    [settingButton bk_whenTapped:^{
        TDCameraViewController *sself = wself;
        if (sself) {
            
        }else{
            NSLog(@"<self> dealloc before we could run this code.");
        }
    }];
    [settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomBar.mas_centerY);
        make.left.equalTo(@20);
        make.width.equalTo(@(settingImage.size.width));
        make.height.equalTo(@(settingImage.size.height));
    }];
    // 撤销按钮
    UIButton* backButton = [[UIButton alloc] init];
    [bottomBar addSubview:backButton];
    UIImage* backImage = [UIImage imageNamed:@"back"];
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton bk_whenTapped:^{
        TDCameraViewController *sself = wself;
        if (sself) {
            if (sself.images.count == 0) {
                return;
            }
            [sself.images removeLastObject];
            [sself updateDotView];
        }else{
            NSLog(@"<self> dealloc before we could run this code.");
        }
    }];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomBar.mas_centerY);
        make.right.equalTo(@-20);
        make.width.equalTo(@(backImage.size.width));
        make.height.equalTo(@(backImage.size.height));
    }];
    // 拍摄进度条
    TDDotView* dotContentView = [[TDDotView alloc] initWithDotCount:TD_IMAGE_COUNT];
    [bottomBar addSubview:dotContentView];
    [dotContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomBar.mas_centerY);
        make.left.equalTo(settingButton.mas_right).offset(20);
        make.right.equalTo(backButton.mas_left).offset(-20);
        make.height.equalTo(bottomBar.mas_height);
    }];
    dotContentView.backgroundColor = [UIColor clearColor];
    self.dotView = dotContentView;
    // 拍照按钮区域
    UIView* takePhotoView = [[UIView alloc] init];
    [self.view addSubview:takePhotoView];
    [takePhotoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bottomBar.mas_bottom);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.bottom.equalTo(@0);
    }];
    takePhotoView.backgroundColor = [UIColor colorWithRed:30/255.0 green:30/255.0 blue:30/255.0 alpha:1];
    // 拍照按钮
    UIButton* takePhotoButton = [[UIButton alloc] init];
    [takePhotoView addSubview:takePhotoButton];
    [takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.height.equalTo(@100);
        make.width.equalTo(takePhotoButton.mas_height);
    }];
//    takePhotoButton.layer.cornerRadius = 50;
//    takePhotoButton.layer.borderColor = [UIColor whiteColor].CGColor;
//    takePhotoButton.layer.borderWidth = 5;
//    takePhotoButton.backgroundColor = [UIColor colorWithRed:0 green:204/255.0 blue:1 alpha:1];
    [takePhotoButton setImage:[UIImage imageNamed:@"camera_normal"] forState:UIControlStateNormal];
    [takePhotoButton setImage:[UIImage imageNamed:@"camera_down"] forState:UIControlStateHighlighted];
    [takePhotoButton bk_whenTapped:^{
        TDCameraViewController *sself = wself;
        if (sself) {
            [sself takePhoto];
        }else{
            NSLog(@"<self> dealloc before we could run this code.");
        }
    }];
    
//    UILongPressGestureRecognizer *lpgr = [UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
//        
//        static NSTimer* timer = nil;
//        
//        if (state == UIGestureRecognizerStateBegan) {
//            timer = [NSTimer bk_scheduledTimerWithTimeInterval:0.1 block:^(NSTimer *timer) {
//                [self takePhoto];
//            } repeats:YES];
//        }
//        if (state == UIGestureRecognizerStateEnded) {
//            if (timer) {
//                [timer invalidate];
//                timer = nil;
//            }
//        }
//        
//    }];
//    [takePhotoButton addGestureRecognizer:lpgr];

}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:self.statusBarHidden];
    [[UIApplication sharedApplication] setIdleTimerDisabled:self.idleTimerDisabled];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:self.navigationBarHidden];
    }
}
-(void)viewWillAppear:(BOOL)animated
{
    self.statusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    self.idleTimerDisabled = [UIApplication sharedApplication].idleTimerDisabled;
    if (self.navigationController) {
        self.navigationBarHidden = self.navigationController.navigationBarHidden;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}

#pragma mark - Private
- (void) takePhoto{
    if (self.images.count == TD_IMAGE_COUNT) {
        return;
    }
    [self performSelector:@selector(cameraViewStartRecording)];
}

-(void) updateDotView{
    self.dotView.index = self.images.count;
}

#pragma mark - 不可旋转
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
-(BOOL)shouldAutorotate{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}


#pragma mark - DBCameraViewControllerDelegate
- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata{
//    [self bk_performBlockInBackground:^(id obj) {
//        // 压缩
//        UIImage* imageTemp = [image scaleToFitSize:CGSizeMake(1024, 1024)];
//        [self bk_performBlock:^(id obj) {
//            [self.images addObject:imageTemp];
//            [self updateDotView];
//        } afterDelay:0];
//    } afterDelay:0];
    
    [self.images addObject:image];
    [self updateDotView];
}
- (void) dismissCamera:(id)cameraViewController{
    if ([self.delegate_td respondsToSelector:@selector(dismissCamera:)]){
        [self.delegate_td dismissCamera:self];
        [cameraViewController restoreFullScreenMode];
    }
}

@end
