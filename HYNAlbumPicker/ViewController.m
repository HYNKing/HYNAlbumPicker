//
//  ViewController.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "ViewController.h"
#import "HYNAlbumCatalogViewController.h"
#import "HYNNavigationController.h"
static int UploadImageMaxNum = 100000;
//static int UploadImageMaxNum = 9;
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"选择";
    [self setSubView];
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)setSubView{
    UIButton *photoButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width -80*2-50)/2, 250, 80, 30)];
    photoButton.tag = 1001;
    [photoButton setTitle:@"图片" forState:UIControlStateNormal];
    [photoButton setBackgroundColor:[UIColor redColor]];
    [photoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [photoButton addTarget:self action:@selector(gotoAlbumPickerView:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:photoButton];
    UIButton *videoButton = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width -80*2-50)/2 + 80 + 50, 250, 80, 30)];
     videoButton.tag = 1002;
    [videoButton setTitle:@"视频" forState:UIControlStateNormal];
    [videoButton setBackgroundColor:[UIColor redColor]];
    [videoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [videoButton addTarget:self action:@selector(gotoAlbumPickerView:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:videoButton];
}


-(void)gotoAlbumPickerView:(UIButton *)sender{
    __weak typeof(self) weakSelf = self;
     HYNAlbumCatalogViewController *albumCatalog = [[HYNAlbumCatalogViewController alloc] init];
     albumCatalog.maximumNumberOfSelectionMedia = UploadImageMaxNum;
     albumCatalog.delegate = weakSelf;
    if (sender.tag == 1001) {
        NSLog(@"图片");
        albumCatalog.type = Photo;
    }else{
        NSLog(@"视频");
        albumCatalog.type = Video;
    }
    [self.navigationController pushViewController:albumCatalog animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
