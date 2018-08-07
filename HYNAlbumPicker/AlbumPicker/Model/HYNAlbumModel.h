//
//  HYNAlbumModel.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
@interface HYNAlbumModel : NSObject
@property (nonatomic,strong) ALAsset *asset;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,strong,readonly) NSString *assetType;
@property (nonatomic) BOOL isSelect;
@property (nonatomic) BOOL isUploaded;
/**
 在滑动的时候用到的是否选择标志
 */
@property (nonatomic , assign) BOOL tmpIsSelected;
+(instancetype)AlbumModel:(ALAsset *)asset;
-(instancetype)initAlbumModel:(ALAsset *)asset;
@end
