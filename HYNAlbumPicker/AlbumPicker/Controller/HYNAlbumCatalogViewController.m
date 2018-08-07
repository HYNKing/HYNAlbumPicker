//
//  HYNAlbumCatalogViewController.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNAlbumCatalogViewController.h"
#import "HYNAlbum.h"
#import "HYNDelegateDataSource.h"
#import "HYNAlbumPickerViewController.h"
#define kStatusBarHeight   (kDevice_Is_iPhoneX ? (44.0):(20.0))
#define kTopBarHeight      (44.f)
#define kBottomBarHeight   (kDevice_Is_iPhoneX ? (49.f+34.f):(49.f))
#define kBottomButtonHeight   (48.f)
#define kCellDefaultHeight (44.f)

#define UIColorFromRGBBoth(rgbValue,a)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define kScreenHeight (kDevice_Is_iPhoneX ? ([[UIScreen mainScreen] bounds].size.height - 34.0):([[UIScreen mainScreen] bounds].size.height))
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ViewSize(view)  (view.frame.size)

@interface HYNAlbumCatalogViewController ()<UITableViewDelegate,HYNAlbumPickerDelegate,HYNAlbumpPickerIsCmpressDelegate>
@property (nonatomic,strong) UITableView *albumTabView;
@property (nonatomic,strong) HYNDelegateDataSource *albumDelegateDataSource;
@property (nonatomic,strong) NSMutableArray *dataArray;
@end

@implementation HYNAlbumCatalogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.type == Photo) {
        self.title = @"选择照片";
    }else if (self.type == Video) {
        self.title = @"选择视频";
    }else{
        self.title =@"选择照片";
    }
    [self creatNavBar];
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    imageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:imageView];

    CGFloat topY = kStatusBarHeight + kTopBarHeight;
    UIView *colorBackView = [[UIView alloc] initWithFrame:CGRectMake(0 , topY , imageView.frame.size.width , imageView.frame.size.height - topY )];
    colorBackView.backgroundColor = UIColorFromRGBBoth(0xeeeeee, 0.9);
    [imageView addSubview:colorBackView];


    //    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.albumTabView];

    HYNAlbum *album = [HYNAlbum sharedAlbum];
    if (self.type == Photo) {
        album.assstsFilter = [ALAssetsFilter allPhotos];
        self.albumDelegateDataSource.dataSourceType = PhotoDataSource;
    }
    else  if (self.type == Video) {
        album.assstsFilter = [ALAssetsFilter allVideos];
        self.albumDelegateDataSource.dataSourceType = VideoDataSource;
    }
    else{
        album.assstsFilter = [ALAssetsFilter allAssets];
        self.albumDelegateDataSource.dataSourceType = AssetDataSource;
    }
    [album setupAlbumGroups:^(NSMutableArray *groups) {
        self.dataArray = groups;
        self.albumDelegateDataSource.albumCatalogDataArray = groups;
        [self.albumTabView reloadData];
    }];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(backMainView)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];


}
-(void)creatNavBar{
    UIImage *leftButtonNormalImage = [UIImage imageNamed:@"back_01"];
    UIImage *leftButtonHighlightedImage = [UIImage imageNamed:@"more"];;
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:leftButtonNormalImage forState:UIControlStateNormal];
    [leftButton setBackgroundImage:leftButtonHighlightedImage forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(leftBarButtonItemAction) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButtonNormalImage.size.width, leftButtonNormalImage.size.height);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;

}
-(void)leftBarButtonItemAction{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)backMainView
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(UITableView *)albumTabView
{
    if (!_albumTabView) {
        _albumTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, ViewSize(self.view).width, ViewSize(self.view).height - 70) style:UITableViewStylePlain];
        _albumTabView.delegate = self;
        _albumTabView.dataSource = self.albumDelegateDataSource;
        _albumTabView.rowHeight = 70;
        _albumTabView.tableFooterView = [[UIView alloc] init];
    }
    return _albumTabView;
}
-(HYNDelegateDataSource *)albumDelegateDataSource
{
    if (!_albumDelegateDataSource) {
        _albumDelegateDataSource = [[HYNDelegateDataSource alloc] init];
    }
    return _albumDelegateDataSource;
}
#pragma mark -LSYAlbumPickerDelegate
-(void)AlbumPickerDidFinishPick:(NSArray *)assets
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlbumDidFinishPick:)]) {
        [self.delegate AlbumDidFinishPick:assets];
        //[self backMainView];
        [self compressIamge];


    }
}
-(void)canCompressImage:(BOOL)canCompres{

    if (self.delegate && [self.delegate respondsToSelector:@selector(comPressImage:)]) {
        [self.delegate comPressImage:canCompres];
    }


}
-(void)compressIamge{

    //上传完成之后跳转到压缩界面
    //    IOTLWRHCCCompressImageViewController *comPress = [[IOTLWRHCCCompressImageViewController alloc]init];
    //    [IOTHZYBasicViewController globalSetPush:self.navigationController pushTo:comPress];







}
#pragma mark -UITabViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    HYNAlbumPickerViewController *albumPicker = [[HYNAlbumPickerViewController alloc] init];
    albumPicker.gadgetId =self.gadgetId;
    ALAssetsGroup *group =  self.dataArray[indexPath.row];
    if (self.type == Photo) {
        //        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        albumPicker.pickerType = PhotoPicker;
    }else  if (self.type == Video){
        //        [group setAssetsFilter:[ALAssetsFilter allVideos]];
        albumPicker.pickerType = VideoPicker;
    }else{
        //        [group setAssetsFilter:[ALAssetsFilter allAssets]];
        albumPicker.pickerType = AssetPicker;
    }
    albumPicker.group = group;
    albumPicker.delegate = self;
    albumPicker.path = self.path;
    albumPicker.foldersName = self.foldersName;
    if (self.maximumNumberOfSelectionPhoto) {
        albumPicker.maxminumNumber = self.maximumNumberOfSelectionPhoto;
    }else if(self.maximumNumberOfSelectionMedia){
        albumPicker.maxminumNumber = self.maximumNumberOfSelectionMedia;
    }
    [self.navigationController pushViewController:albumPicker animated:YES];

    //进入下一页的时候将


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
-(void)setMaximumNumberOfSelectionMedia:(NSInteger)maximumNumberOfSelectionMedia
{
    _maximumNumberOfSelectionMedia = maximumNumberOfSelectionMedia;
    //    [LSYAlbum sharedAlbum].assstsFilter = [ALAssetsFilter allAssets];
}
-(void)setMaximumNumberOfSelectionPhoto:(NSInteger)maximumNumberOfSelectionPhoto
{
    _maximumNumberOfSelectionPhoto = maximumNumberOfSelectionPhoto;
    //    [LSYAlbum sharedAlbum].assstsFilter = [ALAssetsFilter allPhotos];
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

#pragma mark -设置tabbar隐藏

-(void)viewWillAppear:(BOOL)animated{
  
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
