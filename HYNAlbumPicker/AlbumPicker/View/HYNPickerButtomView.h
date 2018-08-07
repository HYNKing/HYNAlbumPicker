//
//  HYNPickerButtomView.h
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HYNPickerButtomViewDelegate <NSObject>
-(void)previewButtonClick;
-(void)sendButtonClick;
@end
@interface HYNPickerButtomView : UIView
@property (nonatomic,weak) id<HYNPickerButtomViewDelegate> delegate;
@property (nonatomic, copy) NSString *gadgetId;
-(void)setSendNumber:(int)number;
-(void)setPreviewButtonTitle:(NSString *)title;
@end

@interface HYNSendButton : UIButton
-(void)setSendNumber:(int)number;
@end
