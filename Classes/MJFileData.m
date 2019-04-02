//
//  MJFileData.m
//  MJPlistView
//
//  Created by 刘鹏 on 2018/4/27.
//  Copyright © 2018年 musjoy. All rights reserved.
//

#import "MJFileData.h"

@implementation MJFileData
/// 读取文件（优先plist，再json）
+ (id)getFileData:(NSString *)aFileName
{
    id data = nil;
    data = [[self class] getPlistFileData:aFileName];
    if (data == nil) {
        data = [[self class] getJsonFileData:aFileName];
    }
    
    return data;
}

/// 读取Plist文件
+ (id)getPlistFileData:(NSString *)aPlistName
{
    NSString *fileName = [aPlistName stringByAppendingString:@".plist"];
    NSString *fileBundle = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [fileBundle stringByAppendingPathComponent:fileName];
    id aDic = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    return aDic;
}

/// 读取Json文件
+ (id)getJsonFileData:(NSString *)aJsonName
{
    NSString *fileName = [aJsonName stringByAppendingString:@".json"];
    NSString *fileBundle = [[NSBundle mainBundle] resourcePath];
    NSString *filePath = [fileBundle stringByAppendingPathComponent:fileName];
    NSData *data=[NSData dataWithContentsOfFile:filePath];
    id jsonObject=[NSJSONSerialization JSONObjectWithData:data
                                                  options:NSJSONReadingAllowFragments
                                                    error:nil];
    return jsonObject;
}
@end
