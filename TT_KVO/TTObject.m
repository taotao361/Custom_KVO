//
//  TTObject.m
//  TT_KVO
//
//  Created by yxt on 2018/12/11.
//  Copyright © 2018年 yxt. All rights reserved.
//

#import "TTObject.h"

@implementation TTObject

- (void)setName:(NSString *)name {
    [self willChangeValueForKey:@"name"];//会调用 observeValueForKeyPath
    _name = name;
    [self didChangeValueForKey:@"name"];//会调用 observeValueForKeyPath
}

/**
 bool
 @param key 需要手动实现的 keypath
 @return 其他使用 [super automaticallyNotifiesObserversForKey:key]
 */
//+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
//    if ([key isEqualToString:@"name"]) {
//        return NO;
//    }
//    return [super automaticallyNotifiesObserversForKey:key];
//}



@end
