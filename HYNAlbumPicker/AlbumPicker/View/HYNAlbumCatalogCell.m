//
//  HYNAlbumCatalogCell.m
//  HYNAlbumPicker
//
//  Created by King on 2018/8/7.
//  Copyright © 2018年 King. All rights reserved.
//

#import "HYNAlbumCatalogCell.h"

@implementation HYNAlbumCatalogCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {

    }
    return self;
}
-(void)setGroup:(ALAssetsGroup *)group
{
    _group = group;
    //    if (self.indexPath.row == 1) {
    //        [_group setAssetsFilter:[ALAssetsFilter allVideos]];
    //    }else{
    //        [_group setAssetsFilter:[ALAssetsFilter allAssets]];
    //    }
    self.imageView.image = [UIImage imageWithCGImage:group.posterImage];
    [self setupGroupTitle];

}
-(void)setupGroupTitle
{
    NSDictionary *groupTitleAttribute = @{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:17]};
    NSDictionary *numberOfAssetsAttribute = @{NSForegroundColorAttributeName:[UIColor grayColor],NSFontAttributeName:[UIFont systemFontOfSize:17]};
    NSString *groupTitle = [_group valueForProperty:ALAssetsGroupPropertyName];
    if (self.indexPath.row == 0) {
        if (self.cellType == PhotoCatalogCell) {
            groupTitle =  @"照片";
        }else if (self.cellType == VideoCatalogCell){
            groupTitle =  @"视频";
        }
    }
    long numberOfAssets = _group.numberOfAssets;
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@（%ld）",groupTitle,numberOfAssets] attributes:numberOfAssetsAttribute];
    [attributedString addAttributes:groupTitleAttribute range:NSMakeRange(0, groupTitle.length)];
    [self.textLabel setAttributedText:attributedString];

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
