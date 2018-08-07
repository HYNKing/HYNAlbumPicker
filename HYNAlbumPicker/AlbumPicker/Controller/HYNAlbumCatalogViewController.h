//
//  HYNAlbumCatalogViewController.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HYNAlbumCatalogDelegate<NSObject>
-(void)AlbumDidFinishPick:(NSArray *)assets;
@end
@protocol HYNAlbumCatalogCanCompressImageDelegate <NSObject>

-(void)comPressImage:(BOOL)canCompress;

@end

typedef enum AlbumCatalogType{
    Photo,
    Video,
    Asset
}AlbumCatalogType;

@interface HYNAlbumCatalogViewController : UIViewController
//可以选择照片的最多数量，不显示视频资源
@property (nonatomic) NSInteger maximumNumberOfSelectionPhoto;
//可以选择媒体的最多数量，显示所有的资源
@property (nonatomic) NSInteger maximumNumberOfSelectionMedia;
@property (nonatomic,weak) id<HYNAlbumCatalogDelegate,HYNAlbumCatalogCanCompressImageDelegate>delegate;
@property(nonatomic,copy)NSString *gadgetId;
@property(nonatomic,copy)NSString *myAccessID;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *foldersName;
@property (nonatomic, assign) AlbumCatalogType type;

@end
