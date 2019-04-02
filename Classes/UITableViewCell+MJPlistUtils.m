//
//  UITableViewCell+PlistUtils.m
//  ExtremeVPN
//
//  Created by 刘鹏 on 2017/11/28.
//  Copyright © 2017年 Musjoy. All rights reserved.
//

#import "UITableViewCell+MJPlistUtils.h"
#import "UIColor+MJUtils.h"

@implementation UITableViewCell (MJPlistUtils)
/// 配置cell
- (void)configCellWithData:(id)data
{
    // icon
    NSString *icon = data[@"icon"];
    if (icon.length) {
        [self.imageView setImage:[UIImage imageNamed:icon]];
    }
    
    // 标题
    NSString *title = data[@"titleKey"];
    self.textLabel.text = title? title: @"";
    
    // 副标题
    NSString *detailText = data[@"detailTextKey"];
    self.detailTextLabel.text = detailText? detailText: @"";
    
    // 默认是否显示箭头
    BOOL hideAccessory = [data[@"hideAccessory"] boolValue];
    if (hideAccessory) {
        self.accessoryType = UITableViewCellAccessoryNone;
    } else {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    //accessoryIcon
    NSString *accessoryIcon = data[@"accessoryIcon"];
    if (accessoryIcon.length) {
        //配置的图片,修改图片大小。加10的宽度，免得和detailText贴在一起
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:accessoryIcon]];
        CGRect bounds = imageView.bounds;
        bounds.size.width += 10;
        imageView.bounds = bounds;
        [imageView setContentMode:UIViewContentModeRight];
        [imageView setImage:[UIImage imageNamed:accessoryIcon]];
        self.accessoryView = imageView;
    } else {
        self.accessoryView = nil;
    }
    
    
    //因为cell会重用，所以当一个cell的某一项配置了颜色，其他cell此项必须配置颜色
    //主题颜色
    NSString *tintColor = data[@"tintColor"];
    if (tintColor.length) {
        self.tintColor = [UIColor colorFromHexRGB:tintColor];
    }
    
    //背景颜色
    NSString *normalBgColor = data[@"normalBgColor"];
    if (normalBgColor.length) {
        self.backgroundColor = [UIColor colorFromHexRGB:normalBgColor];
    }
    
    //选中颜色
    NSString *selectBgColor = data[@"selectBgColor"];
    if (selectBgColor.length) {
        self.selectedBackgroundView.backgroundColor = [UIColor colorFromHexRGB:selectBgColor];
    }
    
    //标题颜色
    NSString *titleColor = data[@"titleColor"];
    if (titleColor.length) {
        self.textLabel.textColor = [UIColor colorFromHexRGB:titleColor];
    }
    
    //副题颜色
    NSString *detailTextColor = data[@"detailTextColor"];
    if (detailTextColor.length) {
        self.detailTextLabel.textColor = [UIColor colorFromHexRGB:detailTextColor];
    }
}

+ (__kindof UITableViewCell *)cellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:NSStringFromClass([self class]) ofType:@"nib"];
    UITableViewCell *cell = nil;
    if (filePath.length > 0) {
        cell = [[self class] viewFromNib:cell];
        if (cell == nil) {
            cell = [[self alloc] init];
        }
    } else {
        cell = [[super alloc] initWithStyle:style reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

+ (instancetype)viewFromNib:(UIView *)view
{
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([view class]) owner:view  options:nil] objectAtIndex:0];
}
@end
