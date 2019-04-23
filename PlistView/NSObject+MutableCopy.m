//
//  NSObject+MutableCopy.m
//  ExtremeVPN
//
//  Created by 刘鹏 on 2017/11/28.
//  Copyright © 2017年 Musjoy. All rights reserved.
//

#import "NSObject+MutableCopy.h"

@implementation NSObject (MutableCopy)
/// 集合的可变版本拷贝。可循环拷贝嵌套的每一层集合为可变版本，集合中实际元素不改变，只做容器的可变版本拷贝
- (id)loopMutableCopy
{
    id mucopy = nil;
    
    if ([self isKindOfClass:[NSDictionary class]]) {
        // 字典
        NSDictionary *data = (NSDictionary *)self;
        mucopy = [[NSMutableDictionary alloc] initWithCapacity:data.count];
        
        for (id key in data) {
            id value = data[key];
            id muValue = [value loopMutableCopy];
            [mucopy setValue:muValue forKey:key];
        }
    } else if ([self isKindOfClass:[NSArray class]]) {
        // 数组
        NSMutableArray *data = (NSMutableArray *)self;
        mucopy = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        for (id value in data) {
            id muValue = [value loopMutableCopy];
            [mucopy addObject:muValue];
        }
    } else if ([self isKindOfClass:[NSSet class]]) {
        // Set
        NSMutableSet *data = (NSMutableSet *)self;
        mucopy = [[NSMutableSet alloc] initWithCapacity:data.count];
        
        for (id value in data) {
            id muValue = [value loopMutableCopy];
            [mucopy addObject:muValue];
        }
    } else {
        // 其他非集合的元素，原样返回
        mucopy = self;
    }
    
    return mucopy;
}

@end
