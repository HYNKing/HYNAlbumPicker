//
//  HYNAlbumPickerViewController.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CommonCrypto/CommonDigest.h>
@protocol HYNAlbumPickerDelegate<NSObject>
-(void)AlbumPickerDidFinishPick:(NSArray *)assets;
@end
@protocol HYNAlbumpPickerIsCmpressDelegate <NSObject>
-(void)canCompressImage:(BOOL)canCompres;
@end

typedef enum HYNAlbumPickerType{
    PhotoPicker,
    VideoPicker,
    AssetPicker
}HYNAlbumPickerType;

@interface HYNAlbumPickerViewController : UIViewController
@property (nonatomic,strong) ALAssetsGroup *group;
@property (nonatomic) NSInteger maxminumNumber;
@property (nonatomic,weak) id<HYNAlbumPickerDelegate,HYNAlbumpPickerIsCmpressDelegate>delegate;
-(void)sendButtonClick;
@property(nonatomic,copy)NSString *gadgetId;
@property(nonatomic,copy)NSString *myAccessID;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSString *foldersName;
/**
 是否是选择状态
 */
@property (nonatomic , assign) BOOL isChooseMode;
@property (nonatomic, assign) HYNAlbumPickerType pickerType;
@end
