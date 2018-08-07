//
//  HYNDelegateDataSource.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNDelegateDataSource.h"
static NSString * const kAlbumCellIdentifer = @"albumCellIdentifer";
static NSString * const kAlbumCatalogCellIdentifer = @"albumCatalogCellIdentifer";
@implementation HYNDelegateDataSource
#pragma mark -UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.albumDataArray.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HYNAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAlbumCellIdentifer forIndexPath:indexPath];
    HYNAlbumModel *model = self.albumDataArray[indexPath.row];
    model.indexPath = indexPath;
    cell.model = model;
    cell.fatherController = self.fatherController;
    return cell;
}

#pragma mark -UITableViewDelegate


#pragma mark -UITabViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.albumCatalogDataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HYNAlbumCatalogCell *cell = [tableView dequeueReusableCellWithIdentifier:kAlbumCatalogCellIdentifer];
    if (cell == nil) {
        cell = [[HYNAlbumCatalogCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kAlbumCatalogCellIdentifer];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.indexPath = indexPath;
    if (self.dataSourceType == PhotoDataSource) {
        cell.cellType = PhotoCatalogCell;
    }else if (self.dataSourceType == VideoDataSource) {
        cell.cellType = VideoCatalogCell;
    }else{
        cell.cellType = AssetCatalogCell;
    }
    cell.group = self.albumCatalogDataArray[indexPath.row];
    return cell;
}
@end
