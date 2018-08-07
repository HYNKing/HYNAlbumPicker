//
//  HYNAssetPreviewViewController.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HYNAssetPreviewDelegate <NSObject>
-(void)AssetPreviewDidFinishPick:(NSArray *)assets;
@end
@interface HYNAssetPreviewViewController : UIViewController
@property (nonatomic,strong) NSArray *assets;
@property (nonatomic,strong) UICollectionView *AlbumCollection;
@property (nonatomic,weak) id <HYNAssetPreviewDelegate> delegate;
@end
