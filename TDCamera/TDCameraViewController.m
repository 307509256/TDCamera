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
#import "CMPopTipView.h"
#import "TDPopView.h"
//#import "UIImage+fixOrientation.h"
#import "DBCameraGridView.h"

// 相机视图高度占屏幕的比率
#define TD_CAMERA_VIEW_HEIGHT_MULTIPLY 0.7
// 最多拍摄照片数量
#define TD_IMAGE_COUNT 24

NSString* const TD_CAMERA_KEY_IsGhost = @"TD_CAMERA_IsGhost";
NSString* const TD_CAMERA_KEY_IsFront = @"TD_CAMERA_KEY_IsFront";
NSString* const TD_CAMERA_KEY_HasGrid = @"TD_CAMERA_HasGrid";
NSString* const TD_CAMERA_KEY_QUALITY = @"TD_CAMERA_QUALITY";
NSString* const TD_CAMERA_KEY_FPS = @"TD_CAMERA_KEY_FPS";

@interface TDCameraViewController ()<DBCameraViewControllerDelegate,TDPopViewDelegate>
@property (weak,nonatomic) id<TDCameraViewControllerDelegate> delegate_td;
@property (nonatomic) NSMutableArray* images;

@property (weak,nonatomic) TDDotView* dotView;
@property (weak,nonatomic) UIButton* takePhotoButton;

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
    
    // 初始化配置
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TD_CAMERA_KEY_IsGhost] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TD_CAMERA_KEY_IsGhost];
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TD_CAMERA_KEY_IsFront];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TD_CAMERA_KEY_HasGrid] == nil) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:TD_CAMERA_KEY_HasGrid];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TD_CAMERA_KEY_QUALITY] == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:TD_CAMERA_QUALITY_NORMAL forKey:TD_CAMERA_KEY_QUALITY];
    }
    if ([[NSUserDefaults standardUserDefaults] objectForKey:TD_CAMERA_KEY_FPS] == nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:TD_CAMERA_FPS_7 forKey:TD_CAMERA_KEY_FPS];
    }
    
    // 设置manager
    self.cameraManager.captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    
    // 网格
    if ([[NSUserDefaults standardUserDefaults] boolForKey:TD_CAMERA_KEY_HasGrid]) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.cameraGridView.alpha = 1.0;
        } completion:NULL];
    }
    
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
        make.width.equalTo(@30);
        make.height.equalTo(@30);
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
    __weak UIButton* wSettingButton = settingButton;
    [bottomBar addSubview:settingButton];
    UIImage* settingImage = [UIImage imageNamed:@"setting"];
    [settingButton setImage:settingImage forState:UIControlStateNormal];
    [settingButton bk_whenTapped:^{
        TDCameraViewController *sself = wself;
        if (sself) {
//            [UIAlertView bk_showAlertViewWithTitle:@"敬请期待" message:@"功能未完善,请等待下一个版本吧!" cancelButtonTitle:@"确定" otherButtonTitles:nil handler:nil];
            
            TDPopView* popContent = [[TDPopView alloc] initWithDelegate:wself];
            popContent.isGhost = [[NSUserDefaults standardUserDefaults] boolForKey:TD_CAMERA_KEY_IsGhost];
            popContent.isFront = [[NSUserDefaults standardUserDefaults] boolForKey:TD_CAMERA_KEY_IsFront];
            popContent.hasGrid = [[NSUserDefaults standardUserDefaults] boolForKey:TD_CAMERA_KEY_HasGrid];
            popContent.quality = [[NSUserDefaults standardUserDefaults] integerForKey:TD_CAMERA_KEY_QUALITY];
            popContent.fps = [[NSUserDefaults standardUserDefaults] integerForKey:TD_CAMERA_KEY_FPS];
            
            CMPopTipView* popTipView = [[CMPopTipView alloc] initWithCustomView:popContent];
            popTipView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            popTipView.dismissTapAnywhere = YES;
            popTipView.has3DStyle = NO;
            popTipView.cornerRadius = 4.0;
            popTipView.sidePadding = 4.0f;
            popTipView.hasShadow = NO;
            [popTipView presentPointingAtView:wSettingButton inView:sself.view animated:YES];
        }else{
            NSLog(@"<self> dealloc before we could run this code.");
        }
    }];
    [settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomBar.mas_centerY);
        make.left.equalTo(@20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
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
            [sself updateGhost];
            [sself updateTakePhotoButton];
        }else{
            NSLog(@"<self> dealloc before we could run this code.");
        }
    }];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(bottomBar.mas_centerY);
        make.right.equalTo(@-20);
        make.width.equalTo(@30);
        make.height.equalTo(@30);
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
    self.takePhotoButton = takePhotoButton;
    [takePhotoView addSubview:takePhotoButton];
    [takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(@0);
        make.height.equalTo(@110);
        make.width.equalTo(takePhotoButton.mas_height);
    }];
    [takePhotoButton setImage:[UIImage imageNamed:@"camera_normal"] forState:UIControlStateNormal];
    [takePhotoButton setImage:[UIImage imageNamed:@"camera_down"] forState:UIControlStateHighlighted];
    [takePhotoButton setImage:[UIImage imageNamed:@"camera_disable"] forState:UIControlStateDisabled];
    [takePhotoButton bk_addEventHandler:^(id sender) {
        TDCameraViewController *sself = wself;
        if (sself) {
            [sself takePhoto];
        }else{
            NSLog(@"<self> dealloc before we could run this code.");
        }
    } forControlEvents:UIControlEventTouchUpInside];
    
    UILongPressGestureRecognizer *lpgr = [UILongPressGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        static NSTimer* timer = nil;
        
        if (state == UIGestureRecognizerStateBegan) {
            NSTimeInterval interval = 0;
            TD_CAMERA_FPS fps = [[NSUserDefaults standardUserDefaults] integerForKey:TD_CAMERA_KEY_FPS];
            switch (fps) {
                case TD_CAMERA_FPS_1:
                    interval = 1.0/1;
                    break;
                case TD_CAMERA_FPS_2:
                    interval = 1.0/2;
                    break;
                case TD_CAMERA_FPS_4:
                    interval = 1.0/4;
                    break;
                case TD_CAMERA_FPS_5:
                    interval = 1.0/5;
                    break;
                case TD_CAMERA_FPS_7:
                    interval = 1.0/7;
                    break;
                case TD_CAMERA_FPS_10:
                    interval = 1.0/10;
                    break;
                case TD_CAMERA_FPS_15:
                    interval = 1.0/15;
                    break;
                default:
                    break;
            }
            // 定时器
            timer = [NSTimer bk_scheduledTimerWithTimeInterval:interval block:^(NSTimer *timer) {
                [wself takePhoto];
            } repeats:YES];
            // 取消自动对焦
            wself.cameraManager.focusMode = AVCaptureFocusModeLocked;
        }
        if (state == UIGestureRecognizerStateEnded) {
            // 定时器
            if (timer) {
                [timer invalidate];
                timer = nil;
            }
            // 启动自动对焦
            wself.cameraManager.focusMode = AVCaptureFocusModeContinuousAutoFocus;
        }
        
    }];
    [takePhotoButton addGestureRecognizer:lpgr];

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
-(void) updateTakePhotoButton{
    if (self.images.count == TD_IMAGE_COUNT) {
        [self.takePhotoButton setEnabled:NO];
    }else{
        [self.takePhotoButton setEnabled:YES];
    }
}
-(void) updateGhost{
    // 清空幽灵
    NSMutableArray* views = [@[] mutableCopy];
    for (UIView* viewWith1Tag in [self.view subviews]) {
        if (viewWith1Tag.tag == 1) {
            [views addObject:viewWith1Tag];
        }
    }
    for (UIView* view in views) {
        [view removeFromSuperview];
    }
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:TD_CAMERA_KEY_IsGhost]) {
        return;
    }
    
    // 构建幽灵
    if (self.images.count != 0) {
        UIImage* image = self.images.lastObject;
        // 方向修正
        image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation: UIImageOrientationRight];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:TD_CAMERA_KEY_IsFront]) {
            image = [UIImage imageWithCGImage:image.CGImage
                                        scale:image.scale
                                  orientation:UIImageOrientationLeftMirrored];
        }

        UIImageView* imageView = [[UIImageView alloc] initWithImage:image];
        imageView.alpha = 0.3;
        imageView.tag = 1;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [imageView setClipsToBounds:YES];
        
        [self.view insertSubview:imageView atIndex:1];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            CGSize size = [[UIScreen mainScreen] bounds].size;
            make.height.equalTo(@(size.height*TD_CAMERA_VIEW_HEIGHT_MULTIPLY));
        }];
    }
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
    [self.images addObject:image];
    [self updateDotView];
    [self updateGhost];
    [self updateTakePhotoButton];
}
- (void) dismissCamera:(id)cameraViewController{
    if ([self.delegate_td respondsToSelector:@selector(dismissCamera:)]){
        [self.delegate_td dismissCamera:self];
        [cameraViewController restoreFullScreenMode];
    }
}
#pragma mark - TDPopViewDelegate
-(void) popView:(TDPopView*) popView ghost:(BOOL) isGhost{
    [[NSUserDefaults standardUserDefaults] setBool:isGhost forKey:TD_CAMERA_KEY_IsGhost];
    [self updateGhost];
}
-(void) popView:(TDPopView*) popView front:(BOOL) isFront{
    [[NSUserDefaults standardUserDefaults] setBool:isFront forKey:TD_CAMERA_KEY_IsFront];
    if ( [self.cameraManager hasMultipleCameras] )
        [self.cameraManager cameraToggle];
}
-(void) popView:(TDPopView*) popView hasGrid:(BOOL) hasGrid{
    [[NSUserDefaults standardUserDefaults] setBool:hasGrid forKey:TD_CAMERA_KEY_HasGrid];
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.cameraGridView.alpha = (hasGrid ? 1.0 : 0.0);
    } completion:NULL];
}
-(void) popView:(TDPopView*) popView quality:(TD_CAMERA_QUALITY) quality{
    [[NSUserDefaults standardUserDefaults] setInteger:quality forKey:TD_CAMERA_KEY_QUALITY];
    switch (quality) {
        case TD_CAMERA_QUALITY_NORMAL:
            self.cameraManager.captureSession.sessionPreset = AVCaptureSessionPresetMedium;
            break;
        case TD_CAMERA_QUALITY_HIGH:
            self.cameraManager.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
            break;
        default:
            break;
    }
}
-(void) popView:(TDPopView*) popView fps:(TD_CAMERA_FPS) fps{
    [[NSUserDefaults standardUserDefaults] setInteger:fps forKey:TD_CAMERA_KEY_FPS];
}
-(void) popViewReset:(TDPopView*) popView{
    [self.images removeAllObjects];
    [self updateDotView];
    [self updateGhost];
    [self updateTakePhotoButton];
}

@end
