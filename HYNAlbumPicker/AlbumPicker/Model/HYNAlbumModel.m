//
//  HYNAlbumModel.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNAlbumModel.h"

@implementation HYNAlbumModel
-(instancetype)initAlbumModel:(ALAsset *)asset
{
    self = [super init];
    if (self) {
        _asset = asset;
        _isSelect = NO;
        _isUploaded = YES;
        _assetType = [asset valueForProperty:ALAssetPropertyType];
    }
    return self;
}

+(instancetype)AlbumModel:(ALAsset *)asset
{
    return [[HYNAlbumModel alloc] initAlbumModel:asset];
}
@end
