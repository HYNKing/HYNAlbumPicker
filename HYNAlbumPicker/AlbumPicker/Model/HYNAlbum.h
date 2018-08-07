//
//  HYNAlbum.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
typedef void (^albumGroupsBlock)(NSMutableArray *groups);
typedef void (^albumAssetsBlock)(NSMutableArray *assets);

@interface HYNAlbum : NSObject
@property (nonatomic,strong) ALAssetsGroup *assetsGroup;
@property (nonatomic,strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic,strong) ALAssetsFilter *assstsFilter;
@property (nonatomic,strong) NSMutableArray *groups;
@property (nonatomic,strong) NSMutableArray *assets;
+(HYNAlbum *)sharedAlbum;
-(void)setupAlbumGroups:(albumGroupsBlock)albumGroups;

-(void)setupAutomaticUploadAlbumGroups:(albumGroupsBlock)albumGroups;
-(void)setupAlbumAssets:(ALAssetsGroup *)group withAssets:(albumAssetsBlock)albumAssets;
-(void)setupAlbumAssets:(ALAssetsGroup *)group andWithCurrentIndex:(NSInteger)currentIndex andWithTargetCount:(NSInteger)targetCount withAssets:(albumAssetsBlock)albumAssets;
-(void)setupAutomaticUploadAlbumAssets:(NSMutableArray *)groups withAssets:(albumAssetsBlock)albumAssets;
@end
