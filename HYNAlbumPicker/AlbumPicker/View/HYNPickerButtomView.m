//
//  HYNPickerButtomView.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNPickerButtomView.h"
@interface HYNPickerButtomView ()
@property (nonatomic, strong) UILabel *previewLabel;
@property (nonatomic,strong) UIButton *previewButton;
@property (nonatomic,strong) HYNSendButton *sendButton;
@end
@implementation HYNPickerButtomView
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initPickerButtomView];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPickerButtomView];
    }
    return self;
}
-(void)initPickerButtomView
{
    [self setBackgroundColor: [UIColor whiteColor]];
    [self addSubview:self.previewLabel];
    [self addSubview:self.previewButton];
    [self addSubview:self.sendButton];
}

-(UILabel *)previewLabel
{
    if (!_previewLabel) {
        _previewLabel = [[UILabel alloc] init];
        _previewLabel.text = @"选择上传路径";
        _previewLabel.textColor = UIColorFromRGB(0x8f8f8f);
        _previewLabel.font = [UIFont systemFontOfSize:12];

    }
    return _previewLabel;
}


-(UIButton *)previewButton
{
    if (!_previewButton) {
        _previewButton = [[UIButton alloc] init];
        //        [_previewButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        //        [_previewButton setTitleColor:[UIColor colorWithRed:168/255.0 green:168/255.0 blue:168/255.0 alpha:1] forState:UIControlStateDisabled];
        //        [_previewButton setBackgroundImage:[UIImage imageNamed:@"path_btn440_d"] forState:UIControlStateNormal];
        [_previewButton setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        [_previewButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        [_previewButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        //设置边线
        [_previewButton.layer setCornerRadius:5.0]; //设置圆角半径
        [_previewButton.layer setBorderWidth:0.5]; //边框宽度
        [_previewButton.layer setMasksToBounds:YES];
        [_previewButton.layer setBorderColor:[UIColorFromRGB(0x8f8f8f) CGColor]];//边框颜色
        [_previewButton setBackgroundColor:[UIColor whiteColor]];

//        HCCWeakSelf
//        [Utils getGadgetNameWithGadgetID:self.gadgetId success:^(id  _Nullable result) {
//            [weakSelf.previewButton setTitle:result forState:UIControlStateNormal];
//        } failure:^(id  _Nullable error) {
//
//        }];

        [_previewButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _previewButton;
}
-(HYNSendButton *)sendButton
{
    if (!_sendButton) {
        _sendButton = [[HYNSendButton alloc] init];
        [_sendButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_sendButton setTitleColor:UIColorFromRGB(0x222222) forState:UIControlStateNormal];
        [_sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        //设置边线
        [_sendButton.layer setCornerRadius:5.0]; //设置圆角半径
        [_sendButton.layer setBorderWidth:0.5]; //边框宽度
        [_sendButton.layer setMasksToBounds:YES];
        [_sendButton.layer setBorderColor:[UIColorFromRGB(0x8f8f8f) CGColor]];//边框颜色
        [_sendButton setBackgroundColor:[UIColor whiteColor]];
        [_sendButton setTitle:@"上传" forState:UIControlStateNormal];
        //          [_sendButton setBackgroundImage:[UIImage imageNamed:@"path_btn440_d"] forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendButton;
}
-(void)buttonClick:(UIButton *)sender
{
    if (sender == self.previewButton) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(previewButtonClick)]) {
            [self.delegate previewButtonClick];
        }
    }
    else if (sender == self.sendButton){
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendButtonClick)]) {
            [self.delegate sendButtonClick];
        }
    }
}

-(void)setSendNumber:(int)number
{
    //    [self.sendButton setSendNumber:number];
    if (number == 0) {
        self.previewLabel.textColor = [UIColor grayColor];
        [self.previewButton setEnabled:NO];
        [self.sendButton setEnabled:NO];
        //        [self.previewButton setBackgroundImage:[UIImage imageNamed:@"path_btn440_d"] forState:UIControlStateNormal];
        //        [self.sendButton setBackgroundImage:[UIImage imageNamed:@"path_btn440_d"] forState:UIControlStateNormal];
        [self.sendButton setTitle:@"上传" forState:UIControlStateNormal];
    }else{
        [self.previewButton setEnabled:YES];
        [self.sendButton setEnabled:YES];
        self.previewLabel.textColor = [UIColor blackColor];
        //        [self.previewButton setBackgroundImage:[UIImage imageNamed:@"path_btn440"] forState:UIControlStateNormal];
        //        [self.sendButton setBackgroundImage:[UIImage imageNamed:@"path_btn440"] forState:UIControlStateNormal];
        NSString *upload = @"上传";
        if (number >9999) {
            [self.sendButton setTitle:[NSString stringWithFormat:@"%@(%@)",upload,@"9999⁺"] forState:UIControlStateNormal];
        }else{
            [self.sendButton setTitle:[NSString stringWithFormat:@"%@(%ld)",upload,(long)number] forState:UIControlStateNormal];
        }
    }
}

-(void)setPreviewButtonTitle:(NSString *)title{
    //    if (title != nil) {
    //        [self.previewButton setTitle:[NSString stringWithFormat:@"%@/%@", [IOTHZYUserChooseLanguageManager readTextByBundle:@"IOTLWRHCCCheckBoxPopView_我的存储"],title] forState:UIControlStateNormal];
    //    }
    if (title != nil) {
        [self.previewButton setTitle:[NSString stringWithFormat:@"%@",title] forState:UIControlStateNormal];
    }
    else{
//        __weak typeof(self) weakSelf = self;
//        [Utils getGadgetNameWithGadgetID:self.gadgetId success:^(id  _Nullable result) {
//            [weakSelf.previewButton setTitle:result forState:UIControlStateNormal];
//        } failure:^(id  _Nullable error) {
//
//        }];
        [self.previewButton setTitle:@"我的存储" forState:UIControlStateNormal];

    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    //    self.previewLabel.frame = CGRectMake(0, 0, 120, ViewSize(self).height/3);
    self.previewLabel.frame = CGRectMake(12*kScreenWidth/375, 16*kScreenHeight/667, 180*kScreenWidth/375, 12*kScreenHeight/667);
    //    [self.previewButton setFrame:CGRectMake(0, ViewSize(self).height/3, 160, ViewSize(self).height/2)];

    [self.previewButton setFrame:CGRectMake(12*kScreenWidth/375, 40*kScreenHeight/667 , 214*kScreenWidth/375, 40*kScreenHeight/667)];
    //    [self.sendButton setFrame:CGRectMake(ViewSize(self).width-80, 0, 80, ViewSize(self).height)];
    //    [self.sendButton setFrame:CGRectMake(160, 0,ViewSize(self).width-160, ViewSize(self).height)];
    //    self.sendButton.titleEdgeInsets=UIEdgeInsetsMake(0,ViewSize(self).width/2-120,0,-(ViewSize(self).width/2- 120));
    [self.sendButton setFrame:CGRectMake(238*kScreenWidth/375, 40*kScreenHeight/667, 125*kScreenWidth/375, 40*kScreenHeight/667)];

}
@end

/**
 LSYSendButton
 */
@interface HYNSendButton ()
@property (nonatomic,strong) UILabel *numbersLabel;
@property (nonatomic,strong) UIView *numbersView;
@end
@implementation HYNSendButton
-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initSendButton];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initSendButton];
    }
    return self;
}
-(void)initSendButton
{
    //    [self setTitleColor:[UIColor colorWithRed:9/255.0 green:187/255.0 blue:7/255.0 alpha:1] forState:UIControlStateNormal];
    //    [self setTitleColor:[UIColor colorWithRed:182/255.0 green:225/255.0 blue:187/255.0 alpha:1] forState:UIControlStateDisabled];


    //    [self addSubview:self.numbersView];
    //    [self addSubview:self.numbersLabel];
}
-(UIView *)numbersView
{
    if (!_numbersView) {
        _numbersView = [[UIView alloc] init];
        [_numbersView setFrame:CGRectMake(0, (ViewSize(self).height -20)/2, 20, 20)];
        [_numbersView setBackgroundColor:[UIColor colorWithRed:9/255.0 green:187/255.0 blue:7/255.0 alpha:1]];
        [_numbersView.layer setCornerRadius:10];
        [_numbersView setClipsToBounds:YES];
    }
    return _numbersView;
}
-(UILabel *)numbersLabel
{
    if (!_numbersLabel) {
        _numbersLabel = [[UILabel alloc] init];
        //        [_numbersLabel setTextColor:[UIColor whiteColor]];
        [_numbersLabel setTextColor:[UIColor colorWithRed:9/255.0 green:187/255.0 blue:7/255.0 alpha:1]];
        [_numbersLabel setTextAlignment:NSTextAlignmentCenter];
        [_numbersLabel setFont:[UIFont boldSystemFontOfSize:16]];
    }
    return _numbersLabel;
}

-(void)setSendNumber:(int)number
{
    if (number == 0) {
        [self setEnabled:NO];
        [self isHiddenNumber:YES];
    }
    else{
        [self setEnabled:YES];
        [self isHiddenNumber:NO];
    }
    //    self.numbersLabel.text = [NSString stringWithFormat:@"(%d)",number];
    //    CGFloat labelWidth = [ALTextUtility getWidth:self.numbersLabel.text withFontSize:16];
    //    [self.numbersLabel setFrame:CGRectMake(ViewSize(self).width-70-labelWidth,(ViewSize(self).height -20)/2, labelWidth +20, 20)];
    //    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseIn|UIViewAnimationOptionAllowUserInteraction animations:^{
    //        self.numbersView.transform = CGAffineTransformMakeScale(0.1, 0.1);
    //    } completion:^(BOOL finished) {
    //        [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
    //            self.numbersView.transform = CGAffineTransformMakeScale(1.2, 1.2);
    //        } completion:^(BOOL finished) {
    //            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionCurveEaseOut|UIViewAnimationOptionAllowUserInteraction animations:^{
    //                self.numbersView.transform = CGAffineTransformIdentity;
    //            } completion:^(BOOL finished) {
    //
    //            }];
    //        }];
    //    }];
}
-(void)isHiddenNumber:(BOOL)hidden
{
    [self.numbersView setHidden:hidden];
    [self.numbersLabel setHidden:hidden];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    //    [self.numbersLabel setFrame:CGRectMake(0,(ViewSize(self).height -20)/2, 20, 20)];

}
@end
