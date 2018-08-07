//
//  HYNAlbum.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNAlbum.h"
#import "HYNAlbumModel.h"
@implementation HYNAlbum
+(HYNAlbum *)sharedAlbum{
    static HYNAlbum *_album = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _album = [[HYNAlbum alloc] init];
        _album.assetsLibrary = [[ALAssetsLibrary alloc] init];
        _album.assstsFilter = [ALAssetsFilter allAssets];
    });
    return _album;
}
-(void)setupAlbumGroups:(albumGroupsBlock)albumGroups
{

    NSMutableArray *groups = @[].mutableCopy;
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group) {
            NSString *groupPropertyName = [group valueForProperty:@"ALAssetsGroupPropertyName"];
            NSString *groupPropertyType = [group valueForProperty:@"ALAssetsGroupPropertyType"];
            NSString *groupPropertyPersistentID = [group valueForProperty:@"ALAssetsGroupPropertyPersistentID"];
            NSString *groupPropertyURL = [group valueForProperty:@"ALAssetsGroupPropertyURL"];

            NSLog(@" ALAssetsGroup : groupPropertyName = %@  groupPropertyType = %@ groupPropertyPersistentID = %@ groupPropertyURL = %@" ,  groupPropertyName  , groupPropertyType , groupPropertyPersistentID , groupPropertyURL) ;

            [group setAssetsFilter:self.assstsFilter];
            NSInteger groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if (groupType == ALAssetsGroupSavedPhotos) {
                [groups insertObject:group atIndex:0];
                //+++添加视频分组
                //                ALAssetsGroup *videosGroup = group;
                //                [videosGroup setAssetsFilter:[ALAssetsFilter allVideos]];
                //                if (videosGroup.numberOfAssets>0) {
                //                    [groups insertObject:videosGroup atIndex:1];
                //                }

            }
            else
            {
                //                if (group.numberOfAssets>0) {
                //                    [groups addObject:group];
                //                }
                //这个地方注释掉 只需要显示所有照片的组和HCC下载的组 其他组不显示
                if ([groupPropertyName isEqualToString:@"联想智能存储"]){
                    if (group.numberOfAssets>0) {
                        [groups addObject:group];
                    }
                }
            }

        }
        else
        {
            _groups = groups;
            if (albumGroups) {
                albumGroups(groups);
            }

        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        _groups = groups;
        if (albumGroups) {
            albumGroups(groups);
        }
    };
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:resultBlock failureBlock:failureBlock];


}


-(void)setupAutomaticUploadAlbumGroups:(albumGroupsBlock)albumGroups
{

    NSMutableArray *groups = @[].mutableCopy;
    ALAssetsLibraryGroupsEnumerationResultsBlock resultBlock = ^(ALAssetsGroup *group, BOOL *stop){
        if (group) {
            NSString *groupPropertyName = [group valueForProperty:@"ALAssetsGroupPropertyName"];
            NSString *groupPropertyType = [group valueForProperty:@"ALAssetsGroupPropertyType"];
            NSString *groupPropertyPersistentID = [group valueForProperty:@"ALAssetsGroupPropertyPersistentID"];
            NSString *groupPropertyURL = [group valueForProperty:@"ALAssetsGroupPropertyURL"];

            NSLog(@" ALAssetsGroup : groupPropertyName = %@  groupPropertyType = %@ groupPropertyPersistentID = %@ groupPropertyURL = %@" ,  groupPropertyName  , groupPropertyType , groupPropertyPersistentID , groupPropertyURL) ;

            [group setAssetsFilter:self.assstsFilter];
            NSInteger groupType = [[group valueForProperty:ALAssetsGroupPropertyType] integerValue];
            if (groupType == ALAssetsGroupSavedPhotos) {
                [groups insertObject:group atIndex:0];
            }
            else
            {
                if ([groupPropertyName isEqualToString:@"联想智能存储"]) {
                    if (group.numberOfAssets>0) {
                        [groups addObject:group];
                    }
                }
            }
        }
        else
        {
            _groups = groups;
            if (albumGroups) {
                albumGroups(groups);
            }

        }
    };
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        _groups = groups;
        if (albumGroups) {
            albumGroups(groups);
        }
    };
    [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:resultBlock failureBlock:failureBlock];
}


-(void)setupAlbumAssets:(ALAssetsGroup *)group withAssets:(albumAssetsBlock)albumAssets
{
    NSMutableArray *assets = @[].mutableCopy;
    [group setAssetsFilter:self.assstsFilter];

    NSString *groupPropertyName = [group valueForProperty:@"ALAssetsGroupPropertyName"];
    NSString *groupPropertyType = [group valueForProperty:@"ALAssetsGroupPropertyType"];
    NSString *groupPropertyPersistentID = [group valueForProperty:@"ALAssetsGroupPropertyPersistentID"];
    NSString *groupPropertyURL = [group valueForProperty:@"ALAssetsGroupPropertyURL"];

    NSLog(@" ALAssetsGroup : groupPropertyName = %@  groupPropertyType = %@ groupPropertyPersistentID = %@ groupPropertyURL = %@" ,  groupPropertyName  , groupPropertyType , groupPropertyPersistentID , groupPropertyURL) ;


    __block NSInteger modelErrorCount = 0 ;//用来记录model异常的时候的数值

    //相册内资源总数
    NSInteger assetCount = [group numberOfAssets];
    ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset) {

            //            extern NSString *const ALErrorInvalidProperty NS_DEPRECATED_IOS(4_0, 9_0, "Use PHAsset class properties from the Photos framework instead");
            //
            //            // Properties
            //            extern NSString *const ALAssetPropertyType NS_DEPRECATED_IOS(4_0, 9_0, "Use the mediaType property on a PHAsset from the Photos framework instead");             // An NSString that encodes the type of asset. One of ALAssetTypePhoto, ALAssetTypeVideo or ALAssetTypeUnknown.
            //            extern NSString *const ALAssetPropertyLocation NS_DEPRECATED_IOS(4_0, 9_0, "Use the location property on a PHAsset from the Photos framework instead");         // CLLocation object with the location information of the asset. Only available if location services are enabled for the caller.
            //            extern NSString *const ALAssetPropertyDuration NS_DEPRECATED_IOS(4_0, 9_0, "Use the duration property on a PHAsset from the Photos framework instead");         // Play time duration of a video asset expressed as a double wrapped in an NSNumber. For photos, kALErrorInvalidProperty is returned.
            //            extern NSString *const ALAssetPropertyOrientation NS_DEPRECATED_IOS(4_0, 9_0, "Use the orientation of the UIImage returned for a PHAsset via the PHImageManager from the Photos framework instead");      // NSNumber containing an asset's orientation as defined by ALAssetOrientation.
            //            extern NSString *const ALAssetPropertyDate NS_DEPRECATED_IOS(4_0, 9_0, "Use the creationDate property on a PHAsset from the Photos framework instead");             // An NSDate with the asset's creation date.
            //
            //            // Properties related to multiple photo representations
            //            extern NSString *const ALAssetPropertyRepresentations NS_DEPRECATED_IOS(4_0, 9_0, "Use PHImageRequestOptions with the PHImageManager from the Photos framework instead");  // Array with all the representations available for a given asset (e.g. RAW, JPEG). It is expressed as UTIs.
            //            extern NSString *const ALAssetPropertyURLs NS_DEPRECATED_IOS(4_0, 9_0, "Use PHImageRequestOptions with the PHImageManager from the Photos framework instead");             // Dictionary that maps asset representation UTIs to URLs that uniquely identify the asset.
            //            extern NSString *const ALAssetPropertyAssetURL NS_DEPRECATED_IOS(4_0, 9_0, "Use the localIdentifier property on a PHAsset (or to lookup PHAssets by a previously known ALAssetPropertyAssetURL use fetchAssetsWithALAssetURLs:options:) from the Photos framework instead");         // An NSURL that uniquely identifies the asset
            //
            //            // Asset types
            //            extern NSString *const ALAssetTypePhoto NS_DEPRECATED_IOS(4_0, 9_0, "Use PHAssetMediaTypeImage from the Photos framework instead");                // The asset is a photo
            //            extern NSString *const ALAssetTypeVideo NS_DEPRECATED_IOS(4_0, 9_0, "Use PHAssetMediaTypeVideo from the Photos framework instead");                // The asset is a video
            //            extern NSString *const ALAssetTypeUnknown NS_DEPRECATED_IOS(4_0, 9_0,

            //            - (id)valueForProperty:(NSString *)property NS_DEPRECATED_IOS(4_0, 9_0, "Use PHAsset class properties from the Photos framework instead");



            /* //临时注释掉，避免进入的时候卡顿，之前写是为了判断是否要上传

             NSString *property = [asset valueForProperty:@"ALErrorInvalidProperty"];
             NSString *propertyType = [asset valueForProperty:@"ALAssetPropertyType"];
             NSString *propertyLocation = [asset valueForProperty:@"ALAssetPropertyLocation"];
             NSString *propertyDuration = [asset valueForProperty:@"ALAssetPropertyDuration"];
             NSString *propertyOrientation = [asset valueForProperty:@"ALAssetPropertyOrientation"];
             NSString *propertyDate = [asset valueForProperty:@"ALAssetPropertyDate"];
             NSString *propertyRepresentations = [asset valueForProperty:@"ALAssetPropertyRepresentations"];
             NSString *propertyURLs = [asset valueForProperty:@"ALAssetPropertyURLs"];
             NSString *propertyAssetURL = [asset valueForProperty:@"ALAssetPropertyAssetURL"];

             LogDebug(@"ALAsset \n property = %@ \n propertyType = %@ \n propertyLocation = %@ \n propertyDuration = %@ \n propertyOrientation = %@ \n propertyDate = %@ \n propertyRepresentations = %@ \n propertyURLs = %@ \n propertyAssetURL = %@" , property , propertyType , propertyLocation , propertyDuration , propertyOrientation , propertyDate , propertyRepresentations , propertyURLs , propertyAssetURL) ;
             ALAssetRepresentation *representation = asset.defaultRepresentation;
             NSString *Uti = [representation UTI];
             NSString* filename = [representation filename];
             NSURL* url = [representation url];
             NSDictionary *metadata = [representation metadata];

             LogDebug(@"ALAssetRepresentation \n Uti = %@  \n filename = %@ \n url = %@ \n  metadata = %@ \n  " ,Uti, filename , url,metadata) ;
             */
            HYNAlbumModel *model = [[HYNAlbumModel alloc] initAlbumModel:asset];
            //排查如果 model出现异常 就不加了
            if (model == nil || [[model class] isKindOfClass:[NSNull class]]) {

                ALAssetRepresentation *representation = asset.defaultRepresentation;
                NSString* filename = [representation filename];

                NSLog(@" LSYAlbum model = nill  check Collection <__NSArrayM: 0x1c4e4de60> was mutated while being enumerated \n asset name = %@ " , filename);

                // FIXME: 如果出现上传文件缺少，来这里查找一下.
                modelErrorCount += 1;
                NSLog(@" upload lost file asset name = %@ modelErrorCount = %ld " , filename , modelErrorCount);


            } else {
                [assets addObject:model];
            }

            //            [assets addObject:model];

            NSString *assetType = [model.asset valueForProperty:ALAssetPropertyType];
            if ([assetType isEqualToString:ALAssetTypePhoto]) {

            }
            else if ([assetType isEqualToString:ALAssetTypeVideo]) {

            }
        }
        else if (assets.count+modelErrorCount >= assetCount) //需要处理modelErrorCount的情况
        {

            NSLog(@"  modelErrorCount = %ld assetCount = %ld"  , modelErrorCount , assetCount);

            _assets = assets;
            if (albumAssets) {
                albumAssets(assets);
            }

        };

        //        else if (assets.count >= assetCount)
        //        {
        //            _assets = assets;
        //            if (albumAssets) {
        //                albumAssets(assets);
        //            }
        //
        //        };
    };

    [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultBlock];
}


-(void)setupAutomaticUploadAlbumAssets:(NSMutableArray *)groups withAssets:(albumAssetsBlock)albumAssets
{
    NSMutableArray *assets = @[].mutableCopy;
    NSMutableArray *allAssets = @[].mutableCopy;
    NSMutableArray *hccAssets = @[].mutableCopy;
    NSInteger count = 0;
    for ( ALAssetsGroup* group in groups) {
        NSInteger number = group.numberOfAssets;
        count = count + number;
    }

    [groups enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ALAssetsGroup* group = (ALAssetsGroup*)obj;
        [group setAssetsFilter:self.assstsFilter];
        NSString *groupPropertyName = [group valueForProperty:@"ALAssetsGroupPropertyName"];
        NSString *groupPropertyType = [group valueForProperty:@"ALAssetsGroupPropertyType"];
        //相册内资源总数
        ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
            if (asset) {
                if ([groupPropertyName isEqualToString:@"联想智能存储"]) {
                    [hccAssets addObject:asset];
                }else{
                    [allAssets addObject:asset];
                }
                NSMutableArray *temporaryAssets = [NSMutableArray arrayWithArray:allAssets];
                if (allAssets.count + hccAssets.count >= count){
                    for ( ALAsset *assetAll in allAssets) {
                        ALAssetRepresentation *representationAll = assetAll.defaultRepresentation;
                        NSString* filenameAll = [representationAll filename];
                        for ( ALAsset *assetHcc in hccAssets) {
                            ALAssetRepresentation *representationHcc = assetHcc.defaultRepresentation;
                            NSString* filenameHcc = [representationHcc filename];
                            if ([filenameAll isEqualToString:filenameHcc]) {
                                [temporaryAssets removeObject:assetAll];
                            }
                        }
                    }
                    for ( ALAsset *asset in temporaryAssets) {
                        HYNAlbumModel *model = [[HYNAlbumModel alloc] initAlbumModel:asset];
                        ALAssetRepresentation *representation = asset.defaultRepresentation;
                        NSURL* url = [representation url];
//                        NSString *key = [NSString stringWithFormat:@"%@%@",uploadPrefixesKey,url];
//                        NSString *value = [dic valueForKey:key];
//                        //                        LogDebug(@"已上传key = %@  value=%@ " , key,value) ;
//                        if ([value isEqualToString:@"upload"]) {
//                            model.isUploaded = YES;
//                        }else{
//                            model.isUploaded = NO;
//                        }
                        [assets addObject:model];
                        NSString *assetType = [model.asset valueForProperty:ALAssetPropertyType];
                        if ([assetType isEqualToString:ALAssetTypePhoto]) {
                        }
                        else if ([assetType isEqualToString:ALAssetTypeVideo]) {
                        }
                    }
                    _assets = assets;
                    if (albumAssets) {
                        albumAssets(assets);
                    }
                }
            }
        };
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:resultBlock];
    }];
}


-(void)setupAlbumAssets:(ALAssetsGroup *)group andWithCurrentIndex:(NSInteger)currentIndex andWithTargetCount:(NSInteger)targetCount withAssets:(albumAssetsBlock)albumAssets
{
    NSMutableArray *assets = @[].mutableCopy;
    //    [group setAssetsFilter:self.assstsFilter];

    NSString *groupPropertyName = [group valueForProperty:@"ALAssetsGroupPropertyName"];
    NSString *groupPropertyType = [group valueForProperty:@"ALAssetsGroupPropertyType"];
    NSString *groupPropertyPersistentID = [group valueForProperty:@"ALAssetsGroupPropertyPersistentID"];
    NSString *groupPropertyURL = [group valueForProperty:@"ALAssetsGroupPropertyURL"];

    NSLog(@" ALAssetsGroup : groupPropertyName = %@  groupPropertyType = %@ groupPropertyPersistentID = %@ groupPropertyURL = %@" ,  groupPropertyName  , groupPropertyType , groupPropertyPersistentID , groupPropertyURL) ;

    //相册内资源总数
    NSInteger assetCount = [group numberOfAssets];
    if (currentIndex < 0) {
        targetCount = targetCount + currentIndex;
        currentIndex = 0;
        if (targetCount < 0) {
            targetCount = 0;
            currentIndex = 0;
        }
    }
    ALAssetsGroupEnumerationResultsBlock resultBlock = ^(ALAsset *asset, NSUInteger index, BOOL *stop) {
        if (asset) {

            //            extern NSString *const ALErrorInvalidProperty NS_DEPRECATED_IOS(4_0, 9_0, "Use PHAsset class properties from the Photos framework instead");
            //
            //            // Properties
            //            extern NSString *const ALAssetPropertyType NS_DEPRECATED_IOS(4_0, 9_0, "Use the mediaType property on a PHAsset from the Photos framework instead");             // An NSString that encodes the type of asset. One of ALAssetTypePhoto, ALAssetTypeVideo or ALAssetTypeUnknown.
            //            extern NSString *const ALAssetPropertyLocation NS_DEPRECATED_IOS(4_0, 9_0, "Use the location property on a PHAsset from the Photos framework instead");         // CLLocation object with the location information of the asset. Only available if location services are enabled for the caller.
            //            extern NSString *const ALAssetPropertyDuration NS_DEPRECATED_IOS(4_0, 9_0, "Use the duration property on a PHAsset from the Photos framework instead");         // Play time duration of a video asset expressed as a double wrapped in an NSNumber. For photos, kALErrorInvalidProperty is returned.
            //            extern NSString *const ALAssetPropertyOrientation NS_DEPRECATED_IOS(4_0, 9_0, "Use the orientation of the UIImage returned for a PHAsset via the PHImageManager from the Photos framework instead");      // NSNumber containing an asset's orientation as defined by ALAssetOrientation.
            //            extern NSString *const ALAssetPropertyDate NS_DEPRECATED_IOS(4_0, 9_0, "Use the creationDate property on a PHAsset from the Photos framework instead");             // An NSDate with the asset's creation date.
            //
            //            // Properties related to multiple photo representations
            //            extern NSString *const ALAssetPropertyRepresentations NS_DEPRECATED_IOS(4_0, 9_0, "Use PHImageRequestOptions with the PHImageManager from the Photos framework instead");  // Array with all the representations available for a given asset (e.g. RAW, JPEG). It is expressed as UTIs.
            //            extern NSString *const ALAssetPropertyURLs NS_DEPRECATED_IOS(4_0, 9_0, "Use PHImageRequestOptions with the PHImageManager from the Photos framework instead");             // Dictionary that maps asset representation UTIs to URLs that uniquely identify the asset.
            //            extern NSString *const ALAssetPropertyAssetURL NS_DEPRECATED_IOS(4_0, 9_0, "Use the localIdentifier property on a PHAsset (or to lookup PHAssets by a previously known ALAssetPropertyAssetURL use fetchAssetsWithALAssetURLs:options:) from the Photos framework instead");         // An NSURL that uniquely identifies the asset
            //
            //            // Asset types
            //            extern NSString *const ALAssetTypePhoto NS_DEPRECATED_IOS(4_0, 9_0, "Use PHAssetMediaTypeImage from the Photos framework instead");                // The asset is a photo
            //            extern NSString *const ALAssetTypeVideo NS_DEPRECATED_IOS(4_0, 9_0, "Use PHAssetMediaTypeVideo from the Photos framework instead");                // The asset is a video
            //            extern NSString *const ALAssetTypeUnknown NS_DEPRECATED_IOS(4_0, 9_0,

            //            - (id)valueForProperty:(NSString *)property NS_DEPRECATED_IOS(4_0, 9_0, "Use PHAsset class properties from the Photos framework instead");



            /*
             //临时注释掉，避免进入的时候卡顿，之前写是为了判断是否要上传

             NSString *property = [asset valueForProperty:@"ALErrorInvalidProperty"];
             NSString *propertyType = [asset valueForProperty:@"ALAssetPropertyType"];
             NSString *propertyLocation = [asset valueForProperty:@"ALAssetPropertyLocation"];
             NSString *propertyDuration = [asset valueForProperty:@"ALAssetPropertyDuration"];
             NSString *propertyOrientation = [asset valueForProperty:@"ALAssetPropertyOrientation"];
             NSString *propertyDate = [asset valueForProperty:@"ALAssetPropertyDate"];
             NSString *propertyRepresentations = [asset valueForProperty:@"ALAssetPropertyRepresentations"];
             NSString *propertyURLs = [asset valueForProperty:@"ALAssetPropertyURLs"];
             NSString *propertyAssetURL = [asset valueForProperty:@"ALAssetPropertyAssetURL"];

             LogDebug(@"ALAsset \n property = %@ \n propertyType = %@ \n propertyLocation = %@ \n propertyDuration = %@ \n propertyOrientation = %@ \n propertyDate = %@ \n propertyRepresentations = %@ \n propertyURLs = %@ \n propertyAssetURL = %@" , property , propertyType , propertyLocation , propertyDuration , propertyOrientation , propertyDate , propertyRepresentations , propertyURLs , propertyAssetURL) ;

             */


            HYNAlbumModel *model = [[HYNAlbumModel alloc] initAlbumModel:asset];

            if ([@"IMG_2135.JPG" isEqualToString:[asset.defaultRepresentation filename]]) {

            }

//            ALAssetRepresentation *representation = asset.defaultRepresentation;
//            NSURL* url = [representation url];
//            NSString *key = [NSString stringWithFormat:@"%@%@",uploadPrefixesKey,url];
//            NSString *value = [dic valueForKey:key];
//            //            LogDebug(@"已上传key = %@  value=%@ " , key,value) ;
//            if ([value isEqualToString:@"upload"]) {
//                model.isUploaded = YES;
//            }else{
//                model.isUploaded = NO;
//            }
            [assets addObject:model];
            NSString *assetType = [model.asset valueForProperty:ALAssetPropertyType];
            if ([assetType isEqualToString:ALAssetTypePhoto]) {

            }
            else if ([assetType isEqualToString:ALAssetTypeVideo]) {

            }
        }

        else if (assets.count >= targetCount)
        {
            _assets = assets;
            if (albumAssets) {
                albumAssets(assets);
            }

        };
    };
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(currentIndex,targetCount)];
    [group enumerateAssetsAtIndexes:indexSet options:NSEnumerationReverse usingBlock:resultBlock];
}
@end
