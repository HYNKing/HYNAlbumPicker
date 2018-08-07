//
//  HYNAssetPreviewView.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HYNAssetPreviewNavBarDelegate <NSObject>
-(void)selectButtonClick:(UIButton *)selectButton;
-(void)backButtonClick:(UIButton *)backButton;
@end
@protocol HYNAssetPreviewToolBarDelegate <NSObject>
-(void)sendButtonClick:(UIButton *)sendButton;
@end
@interface HYNAssetPreviewNavBar : UIView
@property (nonatomic,strong) UIButton *selectButton;
@property (nonatomic,weak) id <HYNAssetPreviewNavBarDelegate> delegate;
@end

@interface HYNAssetPreviewToolBar : UIView
@property (nonatomic,weak) id <HYNAssetPreviewToolBarDelegate> delegate;
-(void)setSendNumber:(int)number;
@end
