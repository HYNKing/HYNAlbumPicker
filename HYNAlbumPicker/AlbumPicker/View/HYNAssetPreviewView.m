//
//  HYNAssetPreviewView.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNAssetPreviewView.h"
#import "HYNPickerButtomView.h"
@interface HYNAssetPreviewNavBar()
@property (nonatomic,strong) UIButton *backButton;

@end
@implementation HYNAssetPreviewNavBar
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initPreviewNavBar];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPreviewNavBar];
    }
    return self;
}
-(void)initPreviewNavBar
{
    [self addSubview:self.selectButton];
    [self addSubview:self.backButton];
}
-(UIButton *)selectButton
{
    if (!_selectButton) {
        _selectButton = [[UIButton alloc] init];
        [_selectButton setImage:[UIImage imageNamed:@"AlbumPicker.bundle/FriendsSendsPicturesSelectBigNIcon@2x"] forState:UIControlStateNormal];
        [_selectButton setImage:[UIImage imageNamed:@"AlbumPicker.bundle/FriendsSendsPicturesSelectBigYIcon@2x"] forState:UIControlStateSelected];
        [_selectButton setSelected:YES];
        [_selectButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectButton;
}
-(UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] init];
        [_backButton setImage:[UIImage imageNamed:@"AlbumPicker.bundle/barbuttonicon_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}
-(void)buttonClick:(UIButton *)sender
{
    if (sender == self.selectButton) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectButtonClick:)]) {
            [self.delegate selectButtonClick:sender];
        }
    }
    else if (sender == self.backButton){
        if (self.delegate && [self.delegate respondsToSelector:@selector(backButtonClick:)]) {
            [self.delegate backButtonClick:sender];
        }
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.selectButton setFrame:CGRectMake(ViewSize(self).width-60, (ViewSize(self).height-40)/2, 60, 40)];
    [self.backButton setFrame:CGRectMake(0, (ViewSize(self).height-40)/2, 40, 40)];
}

@end


/**
 assetPreViewToolBar
 */
@interface HYNAssetPreviewToolBar ()
@property (nonatomic,strong) HYNSendButton *sendButton;
@end
@implementation HYNAssetPreviewToolBar
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initPreviewToolBar];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initPreviewToolBar];
    }
    return self;
}
-(void)initPreviewToolBar
{
    [self addSubview:self.sendButton];
}
-(HYNSendButton *)sendButton
{
    if (!_sendButton) {
        _sendButton = [[HYNSendButton alloc] init];
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _sendButton;
}
-(void)buttonClick:(UIButton *)sender
{
    if (sender == self.sendButton) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(sendButtonClick:)]) {
            [self.delegate sendButtonClick:sender];
        }
    }

}
-(void)setSendNumber:(int)number
{
    [self.sendButton setSendNumber:number];
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.sendButton setFrame:CGRectMake(ViewSize(self).width-80, 0, 80, ViewSize(self).height)];
}
@end
