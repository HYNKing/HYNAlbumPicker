//
//  HYNDelegateDataSource.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYNAlbumPickerViewController.h"
#import "HYNAlbumCell.h"
#import "HYNAlbumCatalogCell.h"
#import "HYNAlbumModel.h"
typedef enum HYNDelegateDataSourceType{
    PhotoDataSource,
    VideoDataSource,
    AssetDataSource
}HYNDelegateDataSourceType;

@interface HYNDelegateDataSource : NSObject<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSArray *albumDataArray;
@property (nonatomic,strong) NSArray *albumCatalogDataArray;
@property (weak, nonatomic) HYNAlbumPickerViewController *fatherController;
@property (nonatomic, assign) HYNDelegateDataSourceType dataSourceType;

@end
