//
//  NSObject+KVO.m
//  TT_KVO
//
//  Created by yxt on 2018/12/11.
//  Copyright © 2018年 yxt. All rights reserved.
//

#import "NSObject+KVO.h"
#import <objc/runtime.h>
#import <objc/message.h>

static NSString * const TTKVOClassPrefix_ = @"TTKVONotifying_";
static NSString * const kTTKVOObserver = @"kTTKVOObserver";

@interface TTObserverInfo : NSObject
@property (nonatomic, weak) NSObject *observer;
@property (nonatomic, copy) NSString *keyPath;
@property (nonatomic, strong) TTObserverBlock observerBlock;
@end

@implementation TTObserverInfo

- (instancetype)initWithObserver:(NSObject *)observer keyPath:(NSString *)keyPath observerBlock:(TTObserverBlock)block {
    if (self = [super init]) {
        _observer = observer;
        _keyPath = keyPath;
        _observerBlock = block;
    }
    return self;
}

@end


@implementation NSObject (KVO)

- (void)tt_addObserver:(NSObject *)observer keyPath:(NSString *)keyPath observerBlock:(TTObserverBlock)block {
    //1、检查监听的对象key 有没有setter方法，没有就抛出异常
    SEL setter = NSSelectorFromString(setterWithGetter(keyPath));
    Method method = class_getInstanceMethod([self class], setter);
    if (!method) {
        NSString *reason = [NSString stringWithFormat:@"obj %@ do not have a setter for key(%@)",self,keyPath];
        NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil];
        @throw exception;
        return;
    }
    
    //2、检查被监听对象是不是一个KVO类，如果不是，创建一个继承于当前类的一个子类，并把isa指针指向当前类
    Class class = object_getClass(self);
    NSString *classStr = NSStringFromClass(class);
    if (![classStr containsString:TTKVOClassPrefix_]) {
        class = [self changeClass:classStr];
        object_setClass(self, class);//改变原对象的isa指针
    }
    
    //3、检查对象的KVO类有没有重写过setter方法，没有的话就重写
    if (![self hasSelector:setter]) {
        const char *types = method_getTypeEncoding(method);
        //给创建的kvo类添加setter方法
        class_addMethod(class, setter, (IMP)kvo_setter, types);
    }
    //4、添加这个观察者
    TTObserverInfo *info = [[TTObserverInfo alloc] initWithObserver:observer keyPath:keyPath observerBlock:block];
    NSMutableArray *observerArr = objc_getAssociatedObject(self, &kTTKVOObserver);
    if (!observerArr) {
        observerArr = @[].mutableCopy;
        objc_setAssociatedObject(self, &kTTKVOObserver, observerArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [observerArr addObject:info];
}

- (void)tt_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath {
    NSMutableArray *arr = objc_getAssociatedObject(self, &kTTKVOObserver);
    if (!arr) {
        return;
    }
    TTObserverInfo *inf = nil;
    for (TTObserverInfo *info in arr) {
        if ([info.keyPath isEqualToString:keyPath] && info.observer == observer) {
            inf = info;
            break;
        }
    }
    [arr removeObject:inf];
}


/**
 获取setter方法
 @param getter keypath
 @return setter
 */
NSString * setterWithGetter(NSString *getter) {
    if (getter.length <= 0 || getter == nil) {
        return nil;
    }
    NSString *uppterStr = [[getter substringToIndex:1] uppercaseString];
    NSString *remindStr = [getter substringFromIndex:1];
    return [NSString stringWithFormat:@"set%@%@:",uppterStr,remindStr];
}

- (Class)changeClass:(NSString *)originClassName {
    NSString *newClassStr = [TTKVOClassPrefix_ stringByAppendingString:originClassName];
    Class newClass = NSClassFromString(newClassStr);
    if (newClass) {//有新创建的类，直接返回
        return newClass;
    }

    Class originClass = object_getClass(self);
    //用带有KVO前缀的字符串 创建一个新类
    Class newClassCreate = objc_allocateClassPair(originClass, newClassStr.UTF8String, 0);
    
    //获取原对象的 class方法
    Method classMethod = class_getInstanceMethod(originClass, @selector(class));
    const char *types = method_getTypeEncoding(classMethod);
    //给新类添加 class 方法
    class_addMethod(newClassCreate, @selector(class), (IMP)kvo_class, types);
    
    //注册类
    objc_registerClassPair(newClassCreate);
    return newClassCreate;
}

//获取父类
static Class kvo_class(id self,SEL _cmd) {
    return class_getSuperclass(object_getClass(self));
}

static void kvo_setter(id self, SEL _cmd, id newValue) {
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getterForSetter(setterName);//获取getter字符串
    if (!getterName) {
        //get name 找不到
    }
    //获取旧值
    id oldValue = [self valueForKey:getterName];
    //调用原类的setter方法
    struct objc_super superClass = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    //调用super的 setXXX： 方法
    // 这里需要做个类型强转, 否则会报too many argument的错误
    ((void (*)(void *, SEL, id))objc_msgSendSuper)(&superClass, _cmd, newValue);
    
    NSMutableArray *arr = objc_getAssociatedObject(self, &kTTKVOObserver);
    for (TTObserverInfo *info in arr) {
        if ([info.keyPath isEqualToString:getterName]) {
            //异步调用
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                info.observerBlock(info.observer,getterName,oldValue,newValue);
            });
 
        }
    }
}

static NSString * getterForSetter(NSString *setter) {
    if (setter.length <= 0 || ![setter containsString:@"set"]) {
        return nil;
    }
    NSString *subStr = [[setter substringFromIndex:3] lowercaseString];
    NSString *getter = [subStr substringToIndex:subStr.length-1];
    return getter;
}

- (BOOL)hasSelector:(SEL)selector {
    Class class = object_getClass(self);
    unsigned int count;
    Method *methodList = class_copyMethodList(class, &count);
    for (unsigned int i = 0; i < count; i++) {
        SEL currSelector = method_getName(methodList[i]);
        if (currSelector == selector) {
            free(methodList);
            return YES;
        }
    }
    free(methodList);
    return NO;
}

@end
