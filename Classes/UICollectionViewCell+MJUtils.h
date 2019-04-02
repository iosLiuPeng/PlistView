//
//  UICollectionViewCell+Utils.h
//  ExtremeVPN
//
//  Created by 刘鹏 on 2017/11/7.
//  Copyright © 2017年 Musjoy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UICollectionViewCell (MJUtils)
/**
 *	@brief	使用数据data来初始化cell
 *
 *	@param 	data 	初始化cell所需要的数据
 */
- (void)configItemWithData:(nullable id)data;
@end
