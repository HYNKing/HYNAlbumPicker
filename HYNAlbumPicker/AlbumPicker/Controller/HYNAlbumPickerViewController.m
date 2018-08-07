//
//  HYNAlbumPickerViewController.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNAlbumPickerViewController.h"
#import "HYNDelegateDataSource.h"
#import "HYNAlbum.h"
#import "HYNPickerButtomView.h"
#import "HYNAssetPreviewViewController.h"
static NSString * const kAlbumCellIdentifer = @"albumCellIdentifer";
static NSString * const kAlbumCatalogCellIdentifer = @"albumCatalogCellIdentifer";
//控制是否分批加载系统相册图片
#define kBatchLoadSystemPhotoAlbum 1
//#define kBatchLoadSystemPhotoAlbum 0
#define kUploadSelectAll 1
//#define kUploadSelectAll 0


#define cellSize 72
#define SPEEDBASE 20
#define numOfimg 20
#define kStatusBarHeight   (kDevice_Is_iPhoneX ? (44.0):(20.0))
#define kTopBarHeight      (44.f)
#define kBottomBarHeight   (kDevice_Is_iPhoneX ? (49.f+34.f):(49.f))
#define kBottomButtonHeight   (48.f)
#define kCellDefaultHeight (44.f)
#define ViewSize(view)  (view.frame.size)
#define kThumbnailLength    ([UIScreen mainScreen].bounds.size.width - 5*5)/4
#define kThumbnailSize      CGSizeMake(kThumbnailLength, kThumbnailLength)
#define DistanceFromTopGuiden(view) (view.frame.origin.y + view.frame.size.height)
#define DistanceFromLeftGuiden(view) (view.frame.origin.x + view.frame.size.width)

#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
#define kScreenHeight (kDevice_Is_iPhoneX ? ([[UIScreen mainScreen] bounds].size.height - 34.0):([[UIScreen mainScreen] bounds].size.height))
#define kScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define ViewSize(view)  (view.frame.size)
#define UIColorFromRGBBoth(rgbValue,a)    [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

@interface HYNAlbumPickerViewController () <UICollectionViewDelegate,HYNPickerButtomViewDelegate,HYNAssetPreviewDelegate>
{
    UIView *view;
    NSArray *myAssetsArray;
    NSUserDefaults *userDef;
    NSInteger num;
    __block NSUInteger _currentIndex;
    __block NSUInteger _targetCount;

    NSUInteger _assetCount;
    UIBarButtonItem *_rightItem;
    unsigned long long freeSpace;//剩余的空间
    unsigned long long addSpace;//不断选择添加的空间
    NSIndexPath  *lastAccessed;
    BOOL startScroll;
    float scrollSpeed;
    CGPoint scrollPoint;
    CGRect firstChooseCellRect;
    NSIndexPath *firstChooseCellIndexPath;
    NSIndexPath *secondChooseCellIndexPath;
    //第一个选择到的cell的选项，后面划到的cell的选择属性和其一致
    BOOL firstSelectedCellChoose;
    NSOperationQueue * scrollOperationQueue;
    BOOL isDealPanGesture;

}
@property (nonatomic,strong) UICollectionView *albumView;
@property (nonatomic,strong) HYNDelegateDataSource *albumDelegateDataSource;
@property (nonatomic,strong) NSMutableArray *albumAssets;
@property (nonatomic,strong) HYNPickerButtomView *pickerButtomView;
@property (nonatomic,strong) NSMutableArray *assetsSort;
@property (nonatomic,strong) NSMutableArray *selectedAssets;
@property (nonatomic)int selectNumbers;
@property (nonatomic, strong) NSMutableIndexSet* selectedIndexSet;

@end

@implementation HYNAlbumPickerViewController

-(UICollectionView *)albumView
{
    if (!_albumView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = kThumbnailSize;
        flowLayout.sectionInset = UIEdgeInsetsMake(5,5,5, 5);
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.minimumLineSpacing = 5;
        _albumView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, ViewSize(self.view).width, ViewSize(self.view).height-173) collectionViewLayout:flowLayout];
        _albumView.allowsMultipleSelection = YES;
        [_albumView registerClass:[HYNAlbumCell class] forCellWithReuseIdentifier:kAlbumCellIdentifer];
        _albumView.delegate = self;
        _albumView.dataSource = self.albumDelegateDataSource;
        _albumView.backgroundColor = [UIColor whiteColor];
        _albumView.alwaysBounceVertical = YES;
        //添加滑动选择手势
        UIPanGestureRecognizer *panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [panGes setMinimumNumberOfTouches:1];
        [panGes setMaximumNumberOfTouches:1];
        [self.view addGestureRecognizer:panGes];
    }
    return _albumView;
}


- (void)handlePanGesture:(UIPanGestureRecognizer *)gestureRecognizer{
    float pointerX = [gestureRecognizer locationInView:self.albumView].x;
    float pointerY = [gestureRecognizer locationInView:self.albumView].y;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        isDealPanGesture = YES;
        self.isChooseMode = YES;
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        isDealPanGesture = YES;
        self.isChooseMode = NO;
    }
    NSLog(@"handlePanGesture isDealPanGesture =YES");
    if (isDealPanGesture) {
        NSLog(@"handlePanGesture  x=%f   y=%f",pointerX,pointerX);
        isDealPanGesture = NO;
        //点击刚开始
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
            //进入选择模式后，是否选择依赖tmpIsSelectd，因此要把原来的赋值给tmpIsSelected
            for (NSInteger i = 0; i < self.albumAssets.count; i ++) {
                HYNAlbumModel *model = self.albumAssets[i];
                model.tmpIsSelected = model.isSelect;
            }
        }
        [self dealWithPointX:pointerX pointY:pointerY];
        //点击结束
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded)
        {
            lastAccessed = nil;
            self.albumView.scrollEnabled = YES;
            [self stopScroll];

            //退出选择模式后，是否选择依赖isSelected，因此要把tmpIsSelected的赋值给isSelected
            for (NSInteger i = 0; i < self.albumAssets.count; i ++) {
                HYNAlbumModel *model = self.albumAssets[i];
                model.isSelect = model.tmpIsSelected;
            }
            [self.albumView reloadData];
            firstChooseCellRect = CGRectZero;
            firstChooseCellIndexPath = nil;
            secondChooseCellIndexPath = nil;
            return ;
        }
        scrollPoint = CGPointMake(pointerX, pointerY );
        if (pointerY - self.albumView.contentOffset.y >= self.albumView.bounds.size.height - 50) {
            //如果手指靠近上方，则向上滚动
            scrollSpeed = SPEEDBASE + (pointerY - self.albumView.contentOffset.y - self.albumView.bounds.size.height + 50);
            if (startScroll) {
                return ;
            }
            else {
                startScroll = YES;
                [self startScroll];
            }
        }
        else if (pointerY - self.albumView.contentOffset.y <= 50){
            //如果手指靠近下方，则向下滚动
            scrollSpeed = -SPEEDBASE - (50 - pointerY + self.albumView.contentOffset.y);
            if (startScroll) {
                return ;
            }
            else {
                startScroll = YES;
                [self startScroll];
            }
        }
        else {
            //否则不滚动
            [self stopScroll];
        }
    }else{
        NSLog(@"handlePanGesture isDealPanGesture =NO");
    }
}



- (void)dealWithPointX:(float)pointerX pointY:(float)pointerY{
    if ([NSStringFromCGRect(firstChooseCellRect) isEqualToString:NSStringFromCGRect(CGRectZero)]) {
        //如果没有找到第一个选择的cell，则查找第一个选择的cell
        NSMutableArray *indexPathArr = [NSMutableArray arrayWithCapacity:0];
        for (UICollectionViewCell *cell in self.albumView.visibleCells) {
            float cellSX = cell.frame.origin.x;
            float cellEX = cell.frame.origin.x + cell.frame.size.width;
            float cellSY = cell.frame.origin.y;
            float cellEY = cell.frame.origin.y + cell.frame.size.height;
            if (pointerX >= cellSX && pointerX <= cellEX && pointerY >= cellSY && pointerY <= cellEY){
                NSIndexPath *touchOver = [self.albumView indexPathForCell:cell];
                if (lastAccessed != touchOver){
                    HYNAlbumModel *model = self.albumAssets[touchOver.item];
                    firstSelectedCellChoose = !model.tmpIsSelected;
                    model.tmpIsSelected = firstSelectedCellChoose;
                    model.isSelect = model.tmpIsSelected;
                    firstChooseCellRect = cell.frame;
                    firstChooseCellIndexPath = touchOver;
                    if (model.tmpIsSelected) {
                        if (![self.assetsSort containsObject:touchOver]) {
                            [self.assetsSort addObject:touchOver];}
                        if (![self.selectedAssets containsObject:model]) {
                            [self.selectedAssets addObject:model];}
                    }else{
                        [self.assetsSort removeObject:touchOver];
                        [self.selectedAssets removeObject:model];
                    }
                    self.selectNumbers = (int)self.selectedAssets.count;
                }
                lastAccessed = touchOver;
            }
        }
        //        NSArray *sortedIndexPaths = [indexPathArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        //            return [obj1 compare:obj2];
        //        }];
        //        [UIView performWithoutAnimation:^{
        //            [self.albumView reloadItemsAtIndexPaths:sortedIndexPaths];
        //        }];
        [self.albumView reloadData];
    }
    else {
        //如果已经找到第一个cell
        float firstCellSX = firstChooseCellRect.origin.x;
        float firstCellEX = firstChooseCellRect.origin.x + firstChooseCellRect.size.width;
        float firstCellSY = firstChooseCellRect.origin.y;
        float firstCellEY = firstChooseCellRect.origin.y + firstChooseCellRect.size.height;
        if (pointerY >= firstCellSY && pointerY <= firstCellEY) {
            //在同一行
            if (pointerX >= firstCellEX){
                //self.collectionView visibleCells还要排序
                NSArray *visibleCellIndex = [self.albumView visibleCells];
                NSArray *sortedIndexPaths = [visibleCellIndex sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSIndexPath *path1 = (NSIndexPath *)[self.albumView indexPathForCell:obj1];
                    NSIndexPath *path2 = (NSIndexPath *)[self.albumView indexPathForCell:obj2];
                    return [path1 compare:path2];
                }];
                //在右侧，顺序遍历当前显示的cell

                NSMutableArray *indexPathArr = [NSMutableArray arrayWithCapacity:0];
                for (NSInteger i = 0; i < sortedIndexPaths.count; i++) {
                    UICollectionViewCell *cell = sortedIndexPaths[i];
                    float cellSX = cell.frame.origin.x;
                    float cellSY = cell.frame.origin.y;
                    float cellEY = cell.frame.origin.y + cell.frame.size.height;
                    NSIndexPath *tmpIndexPath = [self.albumView indexPathForCell:cell];
                    if (lastAccessed != tmpIndexPath){
                        if (cellSX <= pointerX && firstCellEX <= cellSX  && cellSY <= pointerY && pointerY <= cellEY) {
                            //如果在选择范围内则记录位置
                            secondChooseCellIndexPath = tmpIndexPath;
                        }
                        else {
                            HYNAlbumModel *model = self.albumAssets[tmpIndexPath.item];
                            model.tmpIsSelected = model.isSelect;
                            if (model.tmpIsSelected) {
                                if (![self.assetsSort containsObject:tmpIndexPath]) {
                                    [self.assetsSort addObject:tmpIndexPath];
                                }
                                if (![self.selectedAssets containsObject:model]) {
                                    [self.selectedAssets addObject:model];
                                }
                            }else{
                                [self.assetsSort removeObject:tmpIndexPath];
                                [self.selectedAssets removeObject:model];
                            }
                            self.selectNumbers = (int)self.selectedAssets.count;
                        }
                        lastAccessed = tmpIndexPath;
                        //                        if (![indexPathArr containsObject:tmpIndexPath]) {
                        //                            [indexPathArr addObject:tmpIndexPath];
                        //                        }
                    }
                }
                //遍历完成后，将第一个cell和第二个cell之间的cell状态改变
                [self changeCellChooseStateFrom:firstChooseCellIndexPath to:secondChooseCellIndexPath andOtherIndexPatchArr:indexPathArr.copy];
            }
            else if (firstCellSX <= pointerX &&  pointerX <= firstCellEX){
                //在自己原来格子里
                //                 NSMutableArray *indexPathArr = [NSMutableArray arrayWithCapacity:0];
                for (NSInteger i = 0; i < self.albumView.visibleCells.count; i++) {
                    UICollectionViewCell *cell = self.albumView.visibleCells[i];
                    NSIndexPath *tmpIndexPath = [self.albumView indexPathForCell:cell];
                    HYNAlbumModel *model = self.albumAssets[tmpIndexPath.item];
                    model.tmpIsSelected = model.isSelect;
                    if (model.tmpIsSelected) {
                        if (![self.assetsSort containsObject:tmpIndexPath]) {
                            [self.assetsSort addObject:tmpIndexPath];
                        }
                        if (![self.selectedAssets containsObject:model]) {
                            [self.selectedAssets addObject:model];
                        }
                    }else{
                        [self.assetsSort removeObject:tmpIndexPath];
                        [self.selectedAssets removeObject:model];
                    }
                    self.selectNumbers = (int)self.selectedAssets.count;
                    lastAccessed = tmpIndexPath;
                    //                    if (![indexPathArr containsObject:tmpIndexPath]) {
                    //                        [indexPathArr addObject:tmpIndexPath];
                    //                    }
                }
                //                NSArray *sortedIndexPaths = [indexPathArr sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                //                    return [obj1 compare:obj2];
                //                }];
                //                [UIView performWithoutAnimation:^{
                //                    [self.albumView reloadItemsAtIndexPaths:sortedIndexPaths];
                //                }];
                [self.albumView reloadData];
            }
            else if (pointerX < firstCellSX){
                //在格子左侧
                NSArray *visibleCellIndex = [self.albumView visibleCells];
                NSArray *sortedIndexPaths = [visibleCellIndex sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                    NSIndexPath *path1 = (NSIndexPath *)[self.albumView indexPathForCell:obj1];
                    NSIndexPath *path2 = (NSIndexPath *)[self.albumView indexPathForCell:obj2];
                    return [path1 compare:path2];
                }];
                NSMutableArray *indexPathArr = [NSMutableArray arrayWithCapacity:0];
                for (NSInteger i = sortedIndexPaths.count -1; i >=0 ; i--) {
                    UICollectionViewCell *cell = sortedIndexPaths[i];
                    //                    float cellSX = cell.frame.origin.x;
                    float cellEX = cell.frame.origin.x + cell.frame.size.width;
                    float cellSY = cell.frame.origin.y;
                    float cellEY = cell.frame.origin.y + cell.frame.size.height;
                    NSIndexPath *tmpIndexPath = [self.albumView indexPathForCell:cell];
                    if (lastAccessed != tmpIndexPath){
                        if (cellEX <= firstCellSX && pointerX <= cellEX  && cellSY <= pointerY && pointerY <= cellEY) {
                            //如果在选择范围内则记录位置
                            secondChooseCellIndexPath = tmpIndexPath;
                        }else {
                            //不在选择状态内则还原状态
                            HYNAlbumModel *model = self.albumAssets[tmpIndexPath.item];
                            model.tmpIsSelected = model.isSelect;
                            if (model.tmpIsSelected) {
                                if (![self.assetsSort containsObject:tmpIndexPath]) {
                                    [self.assetsSort addObject:tmpIndexPath];
                                }
                                if (![self.selectedAssets containsObject:model]) {
                                    [self.selectedAssets addObject:model];
                                }
                            }else{
                                [self.assetsSort removeObject:tmpIndexPath];
                                [self.selectedAssets removeObject:model];
                            }
                            self.selectNumbers = (int)self.selectedAssets.count;
                        }
                        lastAccessed = tmpIndexPath;
                        //                        if (![indexPathArr containsObject:tmpIndexPath]) {
                        //                            [indexPathArr addObject:tmpIndexPath];
                        //                        }
                    }
                }
                //遍历完成后，将第一个cell和第二个cell之间的cell状态改变
                [self changeCellChooseStateFrom:secondChooseCellIndexPath to:firstChooseCellIndexPath andOtherIndexPatchArr:indexPathArr.copy];

            }
        }
        else if (pointerY <= firstCellSY){
            //在上方
            NSArray *visibleCellIndex = [self.albumView visibleCells];
            NSArray *sortedIndexPaths = [visibleCellIndex sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSIndexPath *path1 = (NSIndexPath *)[self.albumView indexPathForCell:obj1];
                NSIndexPath *path2 = (NSIndexPath *)[self.albumView indexPathForCell:obj2];
                return [path1 compare:path2];
            }];
            NSMutableArray *indexPathArr = [NSMutableArray arrayWithCapacity:0];
            for (NSInteger i = sortedIndexPaths.count -1; i >= 0 ; i--) {
                UICollectionViewCell *cell = sortedIndexPaths[i];
                //                float cellSX = cell.frame.origin.x;
                float cellEX = cell.frame.origin.x + cell.frame.size.width;
                //                float cellSY = cell.frame.origin.y;
                float cellEY = cell.frame.origin.y + cell.frame.size.height;
                NSIndexPath *tmpIndexPath = [self.albumView indexPathForCell:cell];
                if (lastAccessed != tmpIndexPath){
                    if (firstCellSY >= cellEY && pointerY <= cellEY && pointerX <= cellEX) {
                        //如果在选择范围内则记录位置
                        secondChooseCellIndexPath = tmpIndexPath;
                    }else {
                        //不在选择状态内则还原状态
                        HYNAlbumModel *model = self.albumAssets[tmpIndexPath.item];
                        model.tmpIsSelected = model.isSelect;
                        if (model.tmpIsSelected) {
                            if (![self.assetsSort containsObject:tmpIndexPath]) {
                                [self.assetsSort addObject:tmpIndexPath];
                            }
                            if (![self.selectedAssets containsObject:model]) {
                                [self.selectedAssets addObject:model];
                            }
                        }else{
                            [self.assetsSort removeObject:tmpIndexPath];
                            [self.selectedAssets removeObject:model];
                        }
                        self.selectNumbers = (int)self.selectedAssets.count;
                    }
                    lastAccessed = tmpIndexPath;
                    //                    if (![indexPathArr containsObject:tmpIndexPath]) {
                    //                        [indexPathArr addObject:tmpIndexPath];
                    //                    }
                }
            }

            //遍历完成后，将第一个cell和第二个cell之间的cell状态改变
            [self changeCellChooseStateFrom:secondChooseCellIndexPath to:firstChooseCellIndexPath andOtherIndexPatchArr:indexPathArr.copy];

        }
        else if (pointerY >= firstCellEY){
            //在下方
            NSArray *visibleCellIndex = [self.albumView visibleCells];
            NSArray *sortedIndexPaths = [visibleCellIndex sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSIndexPath *path1 = (NSIndexPath *)[self.albumView indexPathForCell:obj1];
                NSIndexPath *path2 = (NSIndexPath *)[self.albumView indexPathForCell:obj2];
                return [path1 compare:path2];
            }];
            NSMutableArray *indexPathArr = [NSMutableArray arrayWithCapacity:0];
            for (NSInteger i = 0 ; i < sortedIndexPaths.count ; i++) {
                UICollectionViewCell *cell = sortedIndexPaths[i];
                float cellSX = cell.frame.origin.x;
                //                float cellEX = cell.frame.origin.x + cell.frame.size.width;
                float cellSY = cell.frame.origin.y;
                //                float cellEY = cell.frame.origin.y + cell.frame.size.height;
                NSIndexPath *tmpIndexPath = [self.albumView indexPathForCell:cell];
                if (lastAccessed != tmpIndexPath){
                    if (firstCellEY <= cellSY && pointerY >= cellSY && pointerX >= cellSX) {
                        //如果在选择范围内则记录位置
                        secondChooseCellIndexPath = tmpIndexPath;
                    }else {
                        //不在选择状态内则还原状态
                        HYNAlbumModel *model = self.albumAssets[tmpIndexPath.item];
                        model.tmpIsSelected = model.isSelect;
                        if (model.tmpIsSelected) {
                            if (![self.assetsSort containsObject:tmpIndexPath]) {
                                [self.assetsSort addObject:tmpIndexPath];
                            }
                            if (![self.selectedAssets containsObject:model]) {
                                [self.selectedAssets addObject:model];
                            }
                        }else{
                            [self.assetsSort removeObject:tmpIndexPath];
                            [self.selectedAssets removeObject:model];
                        }
                        self.selectNumbers = (int)self.selectedAssets.count;
                    }
                    lastAccessed = tmpIndexPath;
                    //                    if (![indexPathArr containsObject:tmpIndexPath]) {
                    //                        [indexPathArr addObject:tmpIndexPath];
                    //                    }
                }
            }
            //遍历完成后，将第一个cell和第二个cell之间的cell状态改变
            [self changeCellChooseStateFrom:firstChooseCellIndexPath to:secondChooseCellIndexPath andOtherIndexPatchArr:indexPathArr.copy];
        }
    }
    isDealPanGesture = YES;
}

- (void)stopScroll{
    startScroll = NO;
    scrollPoint = CGPointMake(0, 0);
    scrollSpeed = 0;
}

- (void)startScroll{
    if (!startScroll ) {
        return;
    }
    if (scrollOperationQueue.operationCount > 1) {
        return ;
    }
    __weak typeof(self) weakSelf = self;
    NSOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        if (weakSelf.albumView.contentOffset.y + weakSelf.albumView.frame.size.height + scrollSpeed >= weakSelf.albumView.contentSize.height && scrollSpeed > 0) {

            [UIView animateWithDuration:0.1 animations:^{
                weakSelf.albumView.contentOffset =  CGPointMake(weakSelf.albumView.contentOffset.x, weakSelf.albumView.contentSize.height -weakSelf.albumView.frame.size.height);
            }];

            [weakSelf stopScroll];
            return;
        }
        if (weakSelf.albumView.contentOffset.y + scrollSpeed  <= 0 && scrollSpeed < 0) {

            [UIView animateWithDuration:0.1 animations:^{
                weakSelf.albumView.contentOffset =  CGPointMake(weakSelf.albumView.contentOffset.x, 0);
            }];
            [weakSelf stopScroll];
            return;
        }
        [UIView animateWithDuration:0.1 animations:^{
            weakSelf.albumView.contentOffset =  CGPointMake(weakSelf.albumView.contentOffset.x, weakSelf.albumView.contentOffset.y +scrollSpeed);
        }];
        [weakSelf dealWithPointX:scrollPoint.x pointY:scrollPoint.y];
        scrollPoint = CGPointMake(scrollPoint.x, scrollPoint.y +scrollSpeed);
        [weakSelf performSelector:@selector(startScroll) withObject:nil afterDelay:0.1];
    }];
    [scrollOperationQueue addOperation:operation];
}

- (void)changeCellChooseStateFrom:(NSIndexPath *)firstIndexPath to:(NSIndexPath *)secondIndexPatch andOtherIndexPatchArr:(NSArray *)otherIndexPatchArr{
    if (secondChooseCellIndexPath == nil || firstIndexPath == nil) {
        return;
    }
    //    NSMutableArray *indexPathArr = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = firstIndexPath.row; i <= secondIndexPatch.row ; i ++) {
        HYNAlbumModel *model = self.albumAssets[i];
        model.tmpIsSelected = firstSelectedCellChoose;
        NSIndexPath *path = [NSIndexPath indexPathForItem:i inSection:firstIndexPath.section];
        if (model.tmpIsSelected) {
            if (![self.assetsSort containsObject:path]) {
                [self.assetsSort addObject:path];
            }
            if (![self.selectedAssets containsObject:model]) {
                [self.selectedAssets addObject :model];
            }
        }else{
            [self.assetsSort removeObject:path];
            [self.selectedAssets removeObject:self.albumAssets[i]];
        }
        self.selectNumbers = (int)self.selectedAssets.count;
        //        if (![indexPathArr containsObject:path]) {
        //            [indexPathArr addObject:path];
        //        }
        //        [self.albumView reloadData];
    }

    //    [indexPathArr addObjectsFromArray:otherIndexPatchArr];
    //    NSMutableArray *indexPathArrResult = [NSMutableArray arrayWithCapacity:0];
    //    for (NSIndexPath *path in indexPathArr) {
    //        if (![indexPathArrResult containsObject:path]) {
    //            [indexPathArrResult addObject:path];
    //        }
    //    }
    //    NSArray *sortedIndexPaths = [indexPathArrResult sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
    //        return [obj1 compare:obj2];
    //    }];
    //    //去除刷新动画
    //    [UIView performWithoutAnimation:^{
    //        [self.albumView reloadItemsAtIndexPaths:sortedIndexPaths];
    //    }];
    [self.albumView reloadData];
}


-(HYNDelegateDataSource *)albumDelegateDataSource
{
    if (!_albumDelegateDataSource) {
        _albumDelegateDataSource = [[HYNDelegateDataSource alloc] init];
    }
    _albumDelegateDataSource.fatherController = self;
    return _albumDelegateDataSource;
}
-(HYNPickerButtomView *)pickerButtomView
{
    if (!_pickerButtomView) {
        _pickerButtomView = [[HYNPickerButtomView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 105*kScreenHeight/667, kScreenWidth, 105*kScreenHeight/667)];
        _pickerButtomView.delegate = self;
        _pickerButtomView.gadgetId = self.gadgetId;
        [_pickerButtomView setSendNumber:self.selectNumbers];
        [_pickerButtomView setPreviewButtonTitle:self.foldersName];
    }
    return _pickerButtomView;
}
- (void)viewDidLoad {

    UIImageView * imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    imageView.image = [UIImage imageNamed:@"bg"];
    [self.view addSubview:imageView];

    CGFloat topY = kStatusBarHeight + kTopBarHeight;
    UIView *colorBackView = [[UIView alloc] initWithFrame:CGRectMake(0 , topY , imageView.frame.size.width , imageView.frame.size.height - topY )];
    colorBackView.backgroundColor = UIColorFromRGBBoth(0xeeeeee, 0.9);
    [imageView addSubview:colorBackView];
    [super viewDidLoad];
    isDealPanGesture = YES;
    self.selectedIndexSet = [[NSMutableIndexSet alloc]init];
    [self creatNavBar];
    if ((self.pickerType == PhotoPicker)) {
        self.title = @"照片";
        [HYNAlbum sharedAlbum].assstsFilter = [ALAssetsFilter allPhotos];
    }else if ((self.pickerType == VideoPicker)) {
        self.title =  @"视频";
        [HYNAlbum sharedAlbum].assstsFilter = [ALAssetsFilter allVideos];
    }else{
        self.title = [self.group valueForProperty:ALAssetsGroupPropertyName];
        [HYNAlbum sharedAlbum].assstsFilter = [ALAssetsFilter allAssets];
    }
    self.assetsSort = [NSMutableArray array];
    self.selectedAssets=[NSMutableArray arrayWithCapacity:0];
    self.albumAssets=[NSMutableArray arrayWithCapacity:0];
    [self.view addSubview:self.albumView];
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - 109*kScreenHeight/667, kScreenWidth,4*kScreenHeight/667)];
    lineView.backgroundColor = UIColorFromRGBBoth(0x959595, 0.06);
    [self.view addSubview:lineView];
    [self.view addSubview:self.pickerButtomView];
    firstChooseCellRect = CGRectZero;
    scrollOperationQueue = [NSOperationQueue mainQueue];
    _assetCount = [self.group numberOfAssets];
    _targetCount = 480;
    _currentIndex = _assetCount - _targetCount;
#if kBatchLoadSystemPhotoAlbum
    [[HYNAlbum sharedAlbum] setupAlbumAssets:self.group andWithCurrentIndex:_currentIndex andWithTargetCount:_targetCount withAssets:^(NSMutableArray *assets) {
        if (assets.count >0) {
            _targetCount =  120;
            _currentIndex = _currentIndex -_targetCount;
            [self.albumAssets addObjectsFromArray:assets];
            self.albumDelegateDataSource.albumDataArray = self.albumAssets;
            //            [self.albumView reloadData];
        }
    }];
//    self.albumView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
//        LogDebug(@"上拉加载更多。。。");
//        [[LSYAlbum sharedAlbum] setupAlbumAssets:self.group andWithCurrentIndex:_currentIndex andWithTargetCount:_targetCount withAssets:^(NSMutableArray *assets) {
//            if (assets.count >0) {
//                _currentIndex = _currentIndex - _targetCount;
//                if ([_rightItem.title isEqualToString:[IOTHZYUserChooseLanguageManager readTextByBundle:@"全不选"]]) {
//                    for (NSUInteger index = 0; index < assets.count; ++index) {
//                        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index + self.albumAssets.count inSection:0];
//                        LSYAlbumModel *model = assets[index];
//                        model.isSelect = YES;
//                        [self.assetsSort addObject:indexPath];
//                    }
//                    [self.albumAssets addObjectsFromArray:assets];
//                    [self.selectedAssets addObjectsFromArray:assets];
//                    int  number =  (int)self.albumAssets.count ;
//                    self.selectNumbers = number;
//                }else{
//                    [self.albumAssets addObjectsFromArray:assets];
//                }
//                self.albumDelegateDataSource.albumDataArray = self.albumAssets;
//                _albumView.dataSource = self.albumDelegateDataSource;
//            }
//            [self.albumView reloadData];
//            if (_albumView.mj_footer.isRefreshing) {
//                [_albumView.mj_footer endRefreshing];
//            }
//        }];
//
//    }];
#else
    [[HYNAlbum sharedAlbum] setupAlbumAssets:self.group withAssets:^(NSMutableArray *assets) {
        self.albumAssets = assets;
        self.albumDelegateDataSource.albumDataArray = assets;
        [self.albumView reloadData];
    }];
#endif
    // Do any additional setup after loading the view.

}
-(void)creatNavBar{

    UIImage *leftButtonNormalImage = [UIImage imageNamed:@"back_01"];
    UIImage *leftButtonHighlightedImage = [UIImage imageNamed:@"more"];
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setBackgroundImage:leftButtonNormalImage forState:UIControlStateNormal];
    [leftButton setBackgroundImage:leftButtonHighlightedImage forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:@selector(leftBarButtonItemAction) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, leftButtonNormalImage.size.width, leftButtonNormalImage.size.height);
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftBarItem;


#if kUploadSelectAll
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(rightBtn:)];
    [item1 setTintColor:[UIColor blackColor]];
    item1.tag = 8888;
    _rightItem = item1;
    self.navigationItem.rightBarButtonItems = @[item1];
#else

#endif

}


-(void)rightBtn:(UIBarButtonItem *)btn{
    NSLog(@"self.albumDelegateDataSource == %@",self.albumDelegateDataSource);
    NSLog(@"self.albumAssets == %@",self.albumAssets);
    if ([btn.title isEqualToString:@"全选"]) {
        [self.selectedAssets removeAllObjects];
        [self.assetsSort removeAllObjects];
        for (NSUInteger index = 0; index < self.albumAssets.count; ++index) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            HYNAlbumModel *model = self.albumAssets[index];
            model.isSelect = YES;
            [self.assetsSort addObject:indexPath];
        }
        [self.selectedAssets addObjectsFromArray:self.albumAssets];
        int  number =  (int)self.albumAssets.count ;
        //        [self.pickerButtomView setSendNumber:number];
        self.selectNumbers = number;
        [btn setTitle:@"全不选"];
        [_albumView reloadData];
    }else{
        for (HYNAlbumModel *model in self.albumAssets) {
            model.isSelect = NO;
        }
        [self.selectedAssets removeAllObjects];
        //        [self.pickerButtomView setSendNumber:0];
        self.selectNumbers = 0;
        [self.assetsSort removeAllObjects];
        [btn setTitle:@"全选"];
        [_albumView reloadData];
    }
}



-(void)leftBarButtonItemAction{
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)setSelectNumbers:(int)selectNumbers
{
    _selectNumbers = selectNumbers;
    if (_selectNumbers == self.albumAssets.count) {
        [_rightItem setTitle:@"全不选"];
    }else{
        [_rightItem setTitle:@"全选"];
    }
    [self.pickerButtomView setSendNumber:selectNumbers];
    //    LogDebug(@"_selectNumbers === %d",_selectNumbers);
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}
-(void)viewWillAppear:(BOOL)animated
{

    [super viewWillAppear:animated];
    if ((self.pickerType == PhotoPicker)) {
        [self promptView];
    }else if ((self.pickerType == VideoPicker)) {
    }else{
        [self promptView];
    }

}
-(void)promptView{
}
#pragma mark -LSYPickerButtomViewDelegate
-(void)previewButtonClick
{
    NSLog(@"我在这里进行的是选择路径的操作");
}

-(void)sendButtonClick
{
    NSLog(@"我在这里进行的是上传的操作");
}

#pragma mark -LSYAssetPreviewDelegate
-(void)AssetPreviewDidFinishPick:(NSArray *)assets
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(AlbumPickerDidFinishPick:)]){
        [self.delegate AlbumPickerDidFinishPick:assets];
    }
}

#pragma mark -UICollectionViewDelegate
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selectedAssets.count% ld",self.selectedAssets.count);
    if (self.maxminumNumber) {
        if (!(self.maxminumNumber > self.selectedAssets.count)) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最多只能选择9张照片" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];

            [alertView show];
            return NO;
        }
        return YES;
    }
    else
    return YES;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"selecte当前选择%@",indexPath);
    HYNAlbumModel *model = self.albumAssets[indexPath.item];
    model.isSelect = !model.isSelect;
    if (model.isSelect) {
        [self.assetsSort addObject:indexPath];
        [self.selectedAssets addObject:self.albumAssets[indexPath.item]];
    }else{
        [self.assetsSort removeObject:indexPath];
        [self.selectedAssets removeObject:self.albumAssets[indexPath.item]];
        //不让重新选择的时候来控制
        ALAsset *asset = model.asset;
        ALAssetRepresentation *representation = asset.defaultRepresentation;
        long long size = representation.size;
        addSpace = addSpace - size;
    }
    self.selectNumbers = (int)self.selectedAssets.count;
    NSArray *indexPathArr = [NSArray arrayWithObject:indexPath];
    [collectionView reloadItemsAtIndexPaths:indexPathArr];
    //    [collectionView reloadData];
    NSLog(@"self.selectedAssets  == %@",self.selectedAssets );
}

-(NSString *)fileMD5WithAsset:(ALAsset *)asset {
     if (!asset) {
         return nil;
     }

     ALAssetRepresentation *rep = [asset defaultRepresentation];
     unsigned long readStep = 256;
     uint8_t *buffer = calloc(readStep, sizeof(*buffer));
     unsigned long long offset = 0;
     unsigned long long bytesRead = 0;
     NSError *error = nil;
     unsigned long long fileSize = [rep size];
     int chunks = (int)((fileSize + readStep - 1)/readStep);
     unsigned long long lastChunkSize = fileSize%readStep;

     CC_MD5_CTX md5;
     CC_MD5_Init(&md5);
     BOOL isExp = NO;
     int currentChunk = 0;
     while(!isExp && currentChunk < chunks){

         @try {
             if(currentChunk < chunks - 1){
                 bytesRead = [rep getBytes:buffer fromOffset:offset length:(unsigned long)readStep error:&error];
             }else{
                 bytesRead = [rep getBytes:buffer fromOffset:offset length:(unsigned long)lastChunkSize error:&error];
             }
             NSData * fileData = [NSData dataWithBytesNoCopy:buffer length:(unsigned long)bytesRead freeWhenDone:NO];
             CC_MD5_Update(&md5, [fileData bytes], (CC_LONG)[fileData length]);
             offset += readStep;
         } @catch(NSException *exception) {
             isExp = YES;
             free(buffer);
         }
         currentChunk += 1;
     }
     unsigned char digest[CC_MD5_DIGEST_LENGTH];
     CC_MD5_Final(digest, &md5);
     NSString *s = [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                    digest[0], digest[1],
                    digest[2], digest[3],
                    digest[4], digest[5],
                    digest[6], digest[7],
                    digest[8], digest[9],
                    digest[10], digest[11],
                    digest[12], digest[13],
                    digest[14], digest[15]];
     return s;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectNumbers = (int)collectionView.indexPathsForSelectedItems.count;
    [self.assetsSort removeObject:indexPath];
    [self.selectedAssets removeObject:self.albumAssets[indexPath.item]];
    NSLog(@"self.selectedAssets  == %@",self.selectedAssets );

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
