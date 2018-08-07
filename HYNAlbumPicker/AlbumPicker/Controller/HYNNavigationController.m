//
//  HYNNavigationController.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNNavigationController.h"

@interface HYNNavigationController ()

@end

@implementation HYNNavigationController

-(instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    [self.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    [self.navigationBar setBarStyle:UIBarStyleDefault];
    [self.navigationBar setTintColor:[UIColor blackColor]];
    self.navigationItem.title = @"选择照片";

    [self creatNav];


}
-(void)creatNav{
    //    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:[IOTHZYUserChooseLanguageManager readTextByBundle:@"全选"] style:UIBarButtonItemStyleDone target:self action:@selector(rightBtn:)];
    //    [item1 setTintColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1]];
    //    item1.tag = 8888;
    //    self.navigationItem.rightBarButtonItems = @[item1];
}

-(void)rightBtn:(UIBarButtonItem *)btn{

}
-(void)viewWillAppear:(BOOL)animated{
//    ((UITabBarController *)[AppDelegate shareAppDelegate].window.rootViewController).tabBar.hidden = YES;
}
#pragma mark 屏幕旋转限制

- (BOOL)shouldAutorotate
{
    return NO;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {

    return UIInterfaceOrientationMaskPortrait;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {

    return UIInterfaceOrientationPortrait;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
@end
