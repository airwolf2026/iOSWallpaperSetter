//
//  ViewController.m
//  WallpaperSetter
//
//  Created by DingDang on 2016/12/22.
//  Copyright © 2016年 DingDang. All rights reserved.
//

#import "ViewController.h"

#import "SBSUIWallpaperPreviewViewController.h"   // for setAImageAsWallpaperMethod2

@import MobileCoreServices;
@import Darwin;

#define kPathSpringBoardUI      @"/System/Library/PrivateFrameworks/SpringBoardUI.framework/SpringBoardUI"

typedef BOOL (*SetImageAsWallpaperForLocations)(UIImage *image, NSUInteger location);
static SetImageAsWallpaperForLocations gSetImageAsWallpaperForLocations = NULL;

extern void GSSendAppPreferencesChanged(CFStringRef appID, CFStringRef key);

@interface ViewController () <UINavigationControllerDelegate , UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;


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

#pragma -mark Select a wallpaper

- (IBAction)selectAWallpaperAction:(id)sender {
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *lastChosenMediaType = info[UIImagePickerControllerMediaType];
    if ([lastChosenMediaType isEqual:(NSString *)kUTTypeImage])
    {
        UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
        self.imageView.image = chosenImage;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark set as wallpaper

- (IBAction)setAsHomeWallpaerAction:(id)sender {
    
    [self setAImageAsWallpaperMethod1:self.imageView.image wallpaperType:HomeScreen];
}

- (IBAction)setAsLockWallpaperAction:(id)sender {
    
    [self setAImageAsWallpaperMethod1:self.imageView.image wallpaperType:LockScreen];
}

- (IBAction)setAsHomeNLockWallpaperAction:(id)sender {
    
    [self setAImageAsWallpaperMethod2:self.imageView.image wallpaperType:Both];
}

typedef NS_ENUM(NSUInteger,WallpaperType)
{
    LockScreen = 1,
    HomeScreen = 2,
    Both = 3
};

/**
 call SBSUIWallpaperSetImageAsWallpaperForLocations function to set wallpaper

 @param aImage aImage to set as a wallpaper
 @param type WallpaperType
 @return TRUE Set succeed,other...
 */
- (BOOL)setAImageAsWallpaperMethod1:(UIImage *)aImage wallpaperType:(WallpaperType) type
{
    BOOL ret  = false;
    if (gSetImageAsWallpaperForLocations == NULL)
    {
        void *sbUI = dlopen([kPathSpringBoardUI UTF8String], RTLD_LAZY);
        gSetImageAsWallpaperForLocations = (SetImageAsWallpaperForLocations)dlsym(sbUI, "SBSUIWallpaperSetImageAsWallpaperForLocations");
        dlclose(sbUI);
    }
    
    if (gSetImageAsWallpaperForLocations)
    {
        ret = gSetImageAsWallpaperForLocations(aImage, (NSUInteger)type);
        
    }
    
    [self showResult:ret];
    
    return ret;
}


/**
 call SBSUIWallpaperPreviewViewController's function to set wallpaper

 @param aImage aImage to set as a wallpaper
 @param type WallpaperType
 @return <#return value description#>
 */
- (BOOL)setAImageAsWallpaperMethod2:(UIImage *)aImage wallpaperType:(WallpaperType) type
{
    BOOL ret  = false;
    if (gSetImageAsWallpaperForLocations == NULL)
    {
        void *sbUI = dlopen([kPathSpringBoardUI UTF8String], RTLD_LAZY);
        gSetImageAsWallpaperForLocations = (SetImageAsWallpaperForLocations)dlsym(sbUI, "SBSUIWallpaperSetImageAsWallpaperForLocations");
        dlclose(sbUI);
    }

    Class sbClass = NSClassFromString(@"SBSUIWallpaperPreviewViewController");
    // we create a view controller, but don't display it.
    //  just use it to load image and set wallpaper
    SBSUIWallpaperPreviewViewController *controller = (SBSUIWallpaperPreviewViewController*)[[sbClass alloc] initWithImage: aImage];
    ret = controller.wallpaperImage == nil ? false : true;

    [controller setWallpaperForLocations: 3];  // 3 -> set both for lock screen and home screen
    
    ret = controller.wallpaperImage == nil ? false : true;
    
    [self showResult:ret];

    return ret;
}

- (void) showResult:(BOOL)result
{
    NSString *msg = result ? @"设置壁纸成功" : @"设置壁纸失败";
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"壁纸设置"
                          message:msg
                          delegate:nil
                          cancelButtonTitle:@"确定"
                          otherButtonTitles:nil];
    
    [alert show];
}

@end
