//
//  NSObject+KVO.h
//  TT_KVO
//
//  Created by yxt on 2018/12/11.
//  Copyright © 2018年 yxt. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^TTObserverBlock)(id observer,id keyPath, id oldValue,id newValue);

@interface NSObject (KVO)

- (void)tt_addObserver:(NSObject *)observer keyPath:(NSString *)keyPath observerBlock:(TTObserverBlock)block;

- (void)tt_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
