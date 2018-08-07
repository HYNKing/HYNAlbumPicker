//
//  HYNAlbumCatalogCell.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
typedef enum HYNAlbumCatalogCellType{
    PhotoCatalogCell,
    VideoCatalogCell,
    AssetCatalogCell
}HYNAlbumCatalogCellType;

@interface HYNAlbumCatalogCell : UITableViewCell
@property (nonatomic,strong) ALAssetsGroup *group;
@property (nonatomic, copy) NSIndexPath *indexPath;
@property (nonatomic, assign) HYNAlbumCatalogCellType cellType;

@end
