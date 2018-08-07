//
//  HYNAssetPreviewViewController.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNAssetPreviewViewController.h"
#import "HYNAssetPreviewView.h"
#import "HYNAssetPreviewItem.h"
#import "HYNAlbumModel.h"
#define kScreenHeight (kDevice_Is_iPhoneX ? ([[UIScreen mainScreen] bounds].size.height - 34.0):([[UIScreen mainScreen] bounds].size.height))
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ViewSize(view)  (view.frame.size)
#define ScreenSize [UIScreen mainScreen].bounds.size
@interface HYNAssetPreviewViewController ()<UIScrollViewDelegate,HYNAssetPreviewNavBarDelegate,HYNAssetPreviewToolBarDelegate,HYNAssetPreviewItemDelegate>
@property (nonatomic,strong)UIScrollView *previewScrollView;
@property (nonatomic,strong) HYNAssetPreviewNavBar *previewNavBar;
@property (nonatomic,strong) HYNAssetPreviewToolBar *previewToolBar;
@property (nonatomic,strong) NSMutableArray *selectedAssets;
@end

@implementation HYNAssetPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setAutomaticallyAdjustsScrollViewInsets:NO];
    [self prefersStatusBarHidden];
    self.selectedAssets = [NSMutableArray arrayWithArray:self.assets];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view addSubview:self.previewScrollView];
    [self.view addSubview:self.previewToolBar];
    [self.view addSubview:self.previewNavBar];
    [self setAssets];
}
-(UIScrollView *)previewScrollView
{
    if (!_previewScrollView) {
        _previewScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0,ScreenSize.width, ScreenSize.height)];
        [_previewScrollView setBackgroundColor:[UIColor blackColor]];
        [_previewScrollView setPagingEnabled:YES];
        [_previewScrollView setDelegate:self];
        [_previewScrollView setShowsHorizontalScrollIndicator:NO];
        [_previewScrollView setShowsVerticalScrollIndicator:NO];

    }
    return _previewScrollView;
}
-(HYNAssetPreviewNavBar *)previewNavBar
{
    if (!_previewNavBar) {
        _previewNavBar = [[HYNAssetPreviewNavBar alloc] init];
        [_previewNavBar setBackgroundColor:[UIColor colorWithRed:19/255.0 green:19/255.0 blue:19/255.0 alpha:0.75]];
        _previewNavBar.delegate = self;
    }
    return _previewNavBar;
}
-(HYNAssetPreviewToolBar*)previewToolBar
{
    if (!_previewToolBar) {
        _previewToolBar = [[HYNAssetPreviewToolBar alloc] init];
        [_previewToolBar setBackgroundColor:[UIColor colorWithRed:19/255.0 green:19/255.0 blue:19/255.0 alpha:0.75]];
        _previewToolBar.delegate = self;
        [_previewToolBar setSendNumber:(int)self.AlbumCollection.indexPathsForSelectedItems.count];
    }
    return _previewToolBar;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}
-(void)setAssets
{
    [self.previewScrollView setContentSize:CGSizeMake(ScreenSize.width*self.assets.count, ScreenSize.height)];
    for (int i = 0; i<_assets.count; i++) {
        HYNAssetPreviewItem *previewItem = [[HYNAssetPreviewItem alloc] initWithFrame:CGRectMake(ScreenSize.width*i, 0, ScreenSize.width, ScreenSize.height)];
        previewItem.delegate = self;
        HYNAlbumModel *model = _assets[i];
        previewItem.asset = model.asset;
        [self.previewScrollView addSubview:previewItem];
    }
}
#pragma mark -UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int assetNumber = scrollView.contentOffset.x/ViewSize(self.view).width;
    HYNAlbumModel *model = self.assets[assetNumber];
    self.previewNavBar.selectButton.selected = model.isSelect;

}
#pragma mark -LSYAssetPreviewItemDelegate
-(void)hiddenBarControl
{
    _previewNavBar.hidden = !_previewNavBar.hidden;
    _previewToolBar.hidden = !_previewToolBar.hidden;
}
#pragma mark -LSYAssetPreviewNavBarDelegate
-(void)backButtonClick:(UIButton *)backButton
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)selectButtonClick:(UIButton *)selectButton
{
    if (self.previewScrollView.isDecelerating) {
        return;
    }
    int assetNumber = self.previewScrollView.contentOffset.x/ViewSize(self.view).width;
    HYNAlbumModel *model = self.assets[assetNumber];
    model.isSelect = !model.isSelect;
    self.previewNavBar.selectButton.selected = model.isSelect;
    if (model.isSelect) {
        [self.AlbumCollection selectItemAtIndexPath:model.indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        [self.selectedAssets addObject:model];
        [self.AlbumCollection.delegate collectionView:self.AlbumCollection didSelectItemAtIndexPath:model.indexPath];
    }
    else
    {
        [self.AlbumCollection deselectItemAtIndexPath:model.indexPath animated:NO];
        [self.selectedAssets removeObject:model];
        [self.AlbumCollection.delegate collectionView:self.AlbumCollection didDeselectItemAtIndexPath:model.indexPath];
    }
    [self.previewToolBar setSendNumber:(int)self.AlbumCollection.indexPathsForSelectedItems.count];
}
#pragma mark -LSYAssetPreviewToolBarDelegate
-(void)sendButtonClick:(UIButton *)sendButton
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(AssetPreviewDidFinishPick:)]) {
        NSMutableArray *assets = [NSMutableArray array];
        for (HYNAlbumModel *model in self.selectedAssets) {
            [assets addObject:model.asset];
        }
        [self.delegate AssetPreviewDidFinishPick:assets];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [_previewNavBar setFrame:CGRectMake(0, 0, ViewSize(self.view).width, 64)];
    [_previewToolBar setFrame:CGRectMake(0, ViewSize(self.view).height-44, ViewSize(self.view).width, 44)];
}
-(void)dealloc
{

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
/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


@end
