//
//  MJFileData.h
//  MJPlistView
//
//  Created by 刘鹏 on 2018/4/27.
//  Copyright © 2018年 musjoy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJFileData : NSObject
/// 读取文件（优先plist，再json）
+ (id)getFileData:(NSString *)aFileName;

/// 读取Plist文件
+ (id)getPlistFileData:(NSString *)aPlistName;

/// 读取Json文件
+ (id)getJsonFileData:(NSString *)aJsonName;
@end
