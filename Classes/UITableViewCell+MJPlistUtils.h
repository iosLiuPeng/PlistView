//
//  UITableViewCell+PlistUtils.h
//  ExtremeVPN
//
//  Created by 刘鹏 on 2017/11/28.
//  Copyright © 2017年 Musjoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (MJPlistUtils)
/// 配置cell
- (void)configCellWithData:(id)data;

/** 通用cell初始化方法 */
+ (nonnull instancetype)cellWithStyle:(UITableViewCellStyle)style reuseIdentifier:(nullable NSString *)reuseIdentifier;
@end
