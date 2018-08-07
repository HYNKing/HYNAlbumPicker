//
//  HYNAlbumCell.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYNAlbumPickerViewController.h"
#import "HYNAlbumModel.h"
@interface HYNAlbumCell : UICollectionViewCell
@property (nonatomic,strong) HYNAlbumModel *model;
@property (weak, nonatomic) HYNAlbumPickerViewController *fatherController;
@end

@interface HYNAlbumCellBottomView : UIView
@property (nonatomic) double interval;
@end
