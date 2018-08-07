//
//  HYNAssetPreviewItem.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
@protocol HYNAssetPreviewItemDelegate <NSObject>
-(void)hiddenBarControl;
@end
@interface HYNAssetPreviewItem : UIView
@property (nonatomic,strong) ALAsset *asset;
@property (nonatomic,weak) id<HYNAssetPreviewItemDelegate>delegate;
@end
