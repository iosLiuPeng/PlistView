//
//  NSObject+MutableCopy.h
//  ExtremeVPN
//
//  Created by 刘鹏 on 2017/11/28.
//  Copyright © 2017年 Musjoy. All rights reserved.
//  可变版本拷贝

#import <Foundation/Foundation.h>

@interface NSObject (MutableCopy)
/// 集合的可变版本拷贝。可循环拷贝嵌套的每一层集合为可变版本，集合中实际元素不改变，只做容器的可变版本拷贝
- (id)loopMutableCopy;

/// 后续考虑添加包括集合中元素的可变拷贝
@end
