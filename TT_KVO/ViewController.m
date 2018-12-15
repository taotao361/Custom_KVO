//
//  ViewController.m
//  TT_KVO
//
//  Created by yxt on 2018/12/11.
//  Copyright © 2018年 yxt. All rights reserved.
//

#import "ViewController.h"
#import "TTObject.h"
#import "NSObject+KVO.h"
#import <objc/runtime.h>
#import "TTPerson.h"

NSString * const KVOString = @"KVOString";

@interface ViewController ()
{
   NSString *_haha;
}
@property (nonatomic, strong) TTObject *obj;
@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) TTPerson *person;



@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.array = @[].mutableCopy;
    
//    self.person = [[TTPerson alloc] init];
//    [self.person addObserver:self forKeyPath:@"fullName" options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew context:nil];
    
    self.obj = [[TTObject alloc] init];
    self.obj.name = @"hhh";
//    [self.obj tt_addObserver:self keyPath:@"name" observerBlock:^(id  _Nonnull observer, id  _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
//        NSLog(@"------  %@ -------",newValue);
//    }];
//    [self.obj tt_addObserver:self keyPath:@"age" observerBlock:^(id  _Nonnull observer, id  _Nonnull keyPath, id  _Nonnull oldValue, id  _Nonnull newValue) {
//
//    }];

//    [self.obj addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    [self addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionNew context:nil];

    
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = CGRectMake(100, 100, 40, 30);
    [btn setTitle:@"click" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(didClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

//        NSLog(@"obj = %@ ",object_getClass(self.obj));
//    NSLog(@"obj = %@ ",object_getClass(self.obj));
//    [self addObserver:self forKeyPath:@"_haha" options:NSKeyValueObservingOptionNew context:nil];


int value = 0;
- (void)didClick {
    value++;
//    self.obj.age = [NSNumber numberWithInt:value];
    self.obj.name = [NSString stringWithFormat:@"%d",value];
//    self.person.firstName = [NSString stringWithFormat:@"%d",value];
//    self.person.lastName = [NSString stringWithFormat:@"%d",value+1];
        [[self mutableArrayValueForKey:@"array"] addObject:@(value)];
}

//    [self.obj willChangeValueForKey:@"name"];
//    self.obj.name = [NSString stringWithFormat:@"%d",value];
//    [self.obj didChangeValueForKey:@"name"];



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"name"]) {
        
    } else if ([keyPath isEqualToString:@"fullName"]){
        
    }else if ([keyPath isEqualToString:@"array"]){
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    NSLog(@"---- %@ ---- ",change);
}

- (void)dealloc {
    [self.obj removeObserver:self forKeyPath:@"name"];
    [self.obj tt_removeObserver:self forKeyPath:@"name"];
}

//[self.array removeObserver:self forKeyPath:@"array"];

@end
